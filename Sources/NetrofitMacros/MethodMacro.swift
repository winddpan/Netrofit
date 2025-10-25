import Foundation
import SwiftDiagnostics
import SwiftSyntax
import SwiftSyntaxMacros

struct MethodMacro: BodyMacro {
    static func expansion(
        of node: AttributeSyntax,
        providingBodyFor declaration: some DeclSyntaxProtocol & WithOptionalCodeBlockSyntax,
        in context: some MacroExpansionContext
    ) throws -> [CodeBlockItemSyntax] {
        try MethodMacroParser(node: node, declaration: declaration, context: context)
            .expansion()
    }
}

enum NetrofitError: Error {
    case contextError(String)
    case urlPathError(String)
    case bodyError(String)
    case headerError(String)
    case multipartError(String)
}

struct MethodMacroParser<D: DeclSyntaxProtocol & WithOptionalCodeBlockSyntax, C: MacroExpansionContext> {
    let node: AttributeSyntax
    let declaration: D
    let context: C
    let pathComps: [String]
    let funcDecl: FunctionDeclSyntax
    let method: String
    let contextPlayloadFormat: PayloadFormat?
    let playloadFormat: PayloadFormat?

    var runtimePayloadFormat: PayloadFormat {
        playloadFormat ?? contextPlayloadFormat ?? .JSON
    }

    var variblePathComps: [String] {
        pathComps
            .filter { part in part.hasPrefix("{") && part.hasSuffix("}") }
            .map { String($0.dropFirst().dropLast()) }
    }

    init(node: AttributeSyntax, declaration: D, context: C) throws {
        self.node = node
        self.declaration = declaration
        self.context = context
        let path = node.findLabel(named: nil)?.trimmedDescription ?? ""
        pathComps = path.trimmingQuotes().components(separatedBy: "/").filter { !$0.isEmpty }
        funcDecl = declaration.cast(FunctionDeclSyntax.self)
        method = node.attributeName.trimmedDescription

        if let structDecl = context.lexicalContext.first?.as(StructDeclSyntax.self) {
            contextPlayloadFormat = structDecl.attributes.payloadFormat
        } else if let classDecl = context.lexicalContext.first?.as(ClassDeclSyntax.self) {
            contextPlayloadFormat = classDecl.attributes.payloadFormat
        } else {
            throw NetrofitError.contextError("\(method) using in struct/class!")
        }
        playloadFormat = funcDecl.attributes.payloadFormat
    }

    func expansion() throws -> [CodeBlockItemSyntax] {
        let attributes = funcDecl.attributes
        let headers = funcDecl.attributes.findAttribute(named: "Headers")?.findLabel(named: nil)?.expression.trimmedDescription
        let responseKeyPath = funcDecl.attributes.findAttribute(named: "ResponseKeyPath")?.findLabel(named: nil)?.expression.trimmedDescription
        let flattedPath = try flatPath()

        let encoder: String?
        let decoder: String?
        if let attribute = attributes.findAttribute(named: "FormUrlEncoded") {
            encoder = attribute.findLabel(named: "encoder")?.expression.trimmedDescription ?? "URLEncodedFormEncoder()"
            decoder = attribute.findLabel(named: "decoder")?.expression.trimmedDescription ?? "URLEncodedFormDecoder()"
        } else if let attribute = attributes.findAttribute(named: "Multipart") {
            encoder = attribute.findLabel(named: "encoder")?.expression.trimmedDescription ?? "MultipartEncoder()"
            decoder = attribute.findLabel(named: "decoder")?.expression.trimmedDescription ?? "MultipartDecoder()"
        } else if let attribute = attributes.findAttribute(named: "JSON") {
            encoder = attribute.findLabel(named: "encoder")?.expression.trimmedDescription ?? "JSONEncoder()"
            decoder = attribute.findLabel(named: "decoder")?.expression.trimmedDescription ?? "JSONDecoder()"
        } else {
            encoder = nil
            decoder = nil
        }

        var codes = [CodeBlockItemSyntax]()
        codes.append(
            """
            var builder = builder(path: \(raw: flattedPath), method: "\(raw: method)")
            builder.playloadFormat = \(raw: runtimePayloadFormat.rawValue.addingQuotes())
            """
        )

        if let headers {
            codes.append(
                """
                builder.addHeaders(\(raw: headers))
                """
            )
        }
        if let headers = try getHeaders() {
            for header in headers {
                codes.append(
                    """
                    builder.addHeader(\(raw: header.key), value: \(raw: header.value))
                    """
                )
            }
        }
        if let headerMaps = try getHeaderMap() {
            for headerMap in headerMaps {
                codes.append(
                    """
                    builder.addHeaders(\(raw: headerMap))
                    """
                )
            }
        }

        if let encoder {
            codes.append(
                """
                builder.encoder = \(raw: encoder)
                """
            )
        }
        if let decoder {
            codes.append(
                """
                builder.decoder = \(raw: decoder)
                """
            )
        }
        if let responseKeyPath {
            codes.append(
                """
                builder.setResponseKeyPath(\(raw: responseKeyPath))
                """
            )
        }

        for query in try getQueries() {
            codes.append(
                """
                builder.addQuery(\(raw: query.key), value: \(raw: query.value), encoded: \(raw: query.encoded))
                """
            )
        }

        for part in try getMultiPart() {
            codes.append(
                """
                builder.addPart(\(raw: part.name), value: \(raw: part.value), filename: \(raw: part.filename), mimeType: \(raw: part.mimeType))
                """
            )
        }

        if let body = try getOneBody() {
            codes.append(
                """
                builder.setBody(\(raw: body))
                """
            )
        } else if let fileds = try getFileds() {
            for filed in fileds {
                codes.append(
                    """
                    builder.addField(\(raw: filed.key), value: \(raw: filed.value))
                    """
                )
            }
        }

        codes.append(
            """
            let response = try await self.provider.request(builder)
            try response.validate()
            """
        )

        if let returnType = funcDecl.signature.returnClause?.type, returnType.trimmedDescription != "Void" {
            if let tuple = returnType.as(TupleTypeSyntax.self) {
                codes.append("")
                let converted = convertOneTuple(tuple)
                codes.append(converted)
            } else if let array = returnType.as(ArrayTypeSyntax.self), let tuple = array.element.as(TupleTypeSyntax.self) {
                codes.append("")
                let converted = convertArrayTuple(tuple)
                codes.append(converted)
            } else {
                codes.append(
                    """
                    return try response.decode(\(raw: returnType).self, using: builder.decoder)
                    """
                )
            }
        }

        return codes
    }
}

extension MethodMacroParser {
    func flatPath() throws -> String {
        let funcArgs = funcDecl.parameterList
        var comps = pathComps
        for (idx, part) in comps.enumerated() {
            if part.hasPrefix("{") && part.hasSuffix("}") {
                let pathName = String(part.dropFirst().dropLast())
                var funcArg: FuncArg?
                var encoded = false

                // @Path("xxx") 里面有明确声明
                if let matchArg = funcArgs.first(where: {
                    if let attribute = $0.attributes.findAttribute(named: "Path"),
                       attribute.atSign.text == "@",
                       attribute.trimmedDescription.contains("\"\(pathName)\"")
                    {
                        return true
                    }
                    return false
                }) {
                    funcArg = matchArg
                }
                // 没有 @Path 或者 @Path 没有声明路径，参数名符合
                else if let matchArg = funcArgs.first(where: { $0.internalName == pathName }), matchArg.attributes.findAttribute(named: "Path")?.findLabel(named: nil) == nil {
                    funcArg = matchArg
                }
                if let funcArg {
                    if funcArg.attributes.first?.as(AttributeSyntax.self)?.findLabel(named: "encoded")?.expression.trimmedDescription == "true" {
                        encoded = true
                    }

                    let text: String
                    if encoded {
                        text = funcArg.internalName
                    } else {
                        text = #"String(describing: "\(\#(funcArg.internalName))".addingPercentEncoding(withAllowedCharacters: .urlPathAllowed))"#
                    }
                    comps[idx] = "\\(\(text))"
                } else {
                    throw NetrofitError.urlPathError(pathName)
                }
            }
        }
        return "\"" + comps.joined(separator: "/") + "\""
    }

    func getQueries() throws -> [(key: String, value: String, encoded: Bool)] {
        let funcArgs = funcDecl.parameterList

        var defaultAsQuery = false
        if runtimePayloadFormat != .Multipart, ["GET", "DELETE", "HEAD", "OPTIONS", "TRACE"].contains(method) {
            defaultAsQuery = true
        } else {
            defaultAsQuery = false
        }

        var datas: [(key: String, value: String, encoded: Bool)] = []
        let variblePathComps = self.variblePathComps
        for arg in funcArgs {
            if let query = arg.attributes.findAttribute(named: "Query"), query.atSign.text == "@" {
                let encoded = query.findLabel(named: "encoded")?.expression.trimmedDescription == "true"
                let key = query.findLabel(named: nil)?.expression.trimmedDescription ?? arg.externalName.addingQuotes()
                datas.append((key, arg.internalName, encoded))
            } else if arg.attributes.isEmpty, !variblePathComps.contains(arg.externalName), defaultAsQuery {
                datas.append((arg.externalName.addingQuotes(), arg.internalName, false))
            }
        }
        return datas
    }

    func getOneBody() throws -> String? {
        let funcArgs = funcDecl.parameterList
        let bodies = funcArgs.compactMap { arg in
            if let attribute = arg.attributes.findAttribute(named: "Body"), attribute.atSign.text == "@" {
                return arg
            }
            return nil
        }
        if bodies.count > 1 {
            throw NetrofitError.bodyError("can only have one @Body!")
        }
        if let body = bodies.first {
            if !funcArgs.filter({ $0.attributes.isEmpty }).isEmpty {
                throw NetrofitError.bodyError("can only have one @Body without other parameters!")
            }
            return body.internalName
        }

        // "POST", "PUT", "PATCH" 模式尝试使用第一个 '_' 参数作为 Body
        if runtimePayloadFormat != .Multipart,
           ["POST", "PUT", "PATCH"].contains(method),
           funcArgs.filter({ $0.attributes.isEmpty }).count == 1
        {
            if funcArgs[0].externalName == "_" {
                return funcArgs[0].internalName
            }
        }
        return nil
    }

    func getFileds() throws -> [(key: String, value: String)]? {
        let funcArgs = funcDecl.parameterList
        var defaultAsFiled = false
        if runtimePayloadFormat != .Multipart, ["POST", "PUT", "PATCH"].contains(method) {
            defaultAsFiled = true
        } else {
            defaultAsFiled = false
        }

        var datas: [(key: String, value: String)] = []
        let variblePathComps = self.variblePathComps
        for arg in funcArgs {
            if let filed = arg.attributes.findAttribute(named: "Field"), filed.atSign.text == "@" {
                let key = filed.findLabel(named: nil)?.expression.trimmedDescription ?? arg.externalName.addingQuotes()
                datas.append((key, arg.internalName))
            } else if arg.attributes.isEmpty, !variblePathComps.contains(arg.externalName), defaultAsFiled {
                datas.append((arg.externalName.addingQuotes(), arg.internalName))
            }
        }
        return datas
    }

    func getMultiPart() throws -> [(name: String, value: String, filename: String, mimeType: String)] {
        let funcArgs = funcDecl.parameterList
        var defaultAsPart = false
        if runtimePayloadFormat == .Multipart, ["POST", "PUT", "PATCH"].contains(method) {
            defaultAsPart = true
        } else {
            defaultAsPart = false
        }

        var datas: [(name: String, value: String, filename: String, mimeType: String)] = []
        let variblePathComps = self.variblePathComps
        for arg in funcArgs {
            if let filed = arg.attributes.findAttribute(named: "Part"), filed.atSign.text == "@" {
                let name = filed.findLabel(named: "name")?.expression.trimmedDescription ?? arg.externalName.addingQuotes()
                let filename = filed.findLabel(named: "filename")?.expression.trimmedDescription ?? "nil"
                let mimeType = filed.findLabel(named: "mimeType")?.expression.trimmedDescription ?? "nil"
                datas.append((name, arg.internalName, filename, mimeType))
            } else if arg.attributes.isEmpty, !variblePathComps.contains(arg.externalName), defaultAsPart {
                if arg.externalName == "_" {
                    throw NetrofitError.multipartError("underline '_' argument in @Multipart is not allowed!")
                }
                datas.append((arg.externalName.addingQuotes(), arg.internalName, "nil", "nil"))
            }
        }
        return datas
    }

    func getHeaders() throws -> [(key: String, value: String)]? {
        let funcArgs = funcDecl.parameterList
        var datas: [(key: String, value: String)] = []
        for arg in funcArgs {
            if let filed = arg.attributes.findAttribute(named: "Header"), filed.atSign.text == "@" {
                if arg.identifierType != "String", arg.identifierType != "String?", arg.identifierType != "String!" {
                    throw NetrofitError.headerError("@Header only applys String")
                }
                let key = filed.findLabel(named: nil)?.expression.trimmedDescription ?? arg.externalName.addingQuotes()
                datas.append((key, arg.internalName))
            }
        }
        return datas
    }

    func getHeaderMap() throws -> [String]? {
        let funcArgs = funcDecl.parameterList
        var datas: [String] = []
        for arg in funcArgs {
            if let filed = arg.attributes.findAttribute(named: "HeaderMap"), filed.atSign.text == "@" {
                let identifierType = arg.identifierType.replacingOccurrences(of: " ", with: "")
                if !identifierType.hasPrefix("[String:String]") {
                    throw NetrofitError.headerError("@HeaderMap only applys [String: String]")
                }
                datas.append(arg.internalName)
            }
        }
        return datas
    }
}

extension MethodMacroParser {
    private func convertOneTuple(_ tuple: TupleTypeSyntax) -> CodeBlockItemSyntax {
        let structName = "ResponseData"
        let structCode = makeTupleStructCode(tuple)
        let codeBlock: CodeBlockItemSyntax = """
        struct \(raw: structName): Codable {
            \(raw: structCode.propertiesCode)
        }
        let responseData = try response.decode(\(raw: structName).self, using: builder.decoder)
        return (\(raw: structCode.tupleCode))
        """
        return codeBlock
    }

    private func convertArrayTuple(_ tuple: TupleTypeSyntax) -> CodeBlockItemSyntax {
        let structName = "ResponseData"
        let structCode = makeTupleStructCode(tuple)
        let codeBlock: CodeBlockItemSyntax = """
        struct \(raw: structName): Codable {
            \(raw: structCode.propertiesCode)
        }
        let array = try response.decode([\(raw: structName)].self, using: builder.decoder)
        return array.map({ responseData in 
            (\(raw: structCode.tupleCode)) 
        })
        """
        return codeBlock
    }

    // TODO: 递归多层嵌套
    private func makeTupleStructCode(_ tuple: TupleTypeSyntax) -> (propertiesCode: String, tupleCode: String) {
        var properties: [String] = []
        var tupleElements: [String] = []

        for (index, element) in tuple.elements.enumerated() {
            let argIndex = index + 1
            let propertyName: String

            // 检查是否有标签
            if let firstName = element.firstName?.text {
                propertyName = firstName
            } else {
                propertyName = "arg\(argIndex)"
            }

            let typeDescription = element.type.trimmedDescription

            // 添加到属性列表
            properties.append("var \(propertyName): \(typeDescription)")

            // 添加到元组元素列表（用于构造返回的元组）
            if element.firstName != nil {
                tupleElements.append("\(propertyName): responseData.\(propertyName)")
            } else {
                tupleElements.append("responseData.\(propertyName)")
            }
        }

        let propertiesCode = properties.joined(separator: "\n    ")
        let tupleCode = tupleElements.joined(separator: ", ")

        return (propertiesCode, tupleCode)
    }
}
