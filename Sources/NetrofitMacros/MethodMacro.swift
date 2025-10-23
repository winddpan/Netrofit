import SwiftDiagnostics
import SwiftSyntax
import SwiftSyntaxMacros

struct MethodMacro: BodyMacro {
    static func expansion(
        of node: AttributeSyntax,
        providingBodyFor declaration: some DeclSyntaxProtocol & WithOptionalCodeBlockSyntax,
        in context: some MacroExpansionContext
    ) throws -> [CodeBlockItemSyntax] {
        var codes = [CodeBlockItemSyntax]()

        let funcDecl = declaration.as(FunctionDeclSyntax.self)
        let method = node.attributeName.trimmedDescription
        let path = node.arguments?.description ?? ""
        let headers = funcDecl?.attributes.findAttribute(named: "Headers")?.arguments?.trimmedDescription

        var payloadFormat: String?
        if funcDecl?.attributes.findAttribute(named: "FormUrlEncoded") != nil {
            payloadFormat = "PayloadFormat.FormUrlEncoded"
        } else if funcDecl?.attributes.findAttribute(named: "Multipart") != nil {
            payloadFormat = "PayloadFormat.Multipart"
        }

        codes.append(
            """
            var builder = builder(path: \(raw: path), method: "\(raw: method)")
            builder.addHeaders(\(raw: headers ?? "nil"))
            """
        )

        if let payloadFormat {
            codes.append(
                """
                builder.payloadFormat = \(raw: payloadFormat)
                """
            )
        }

        codes.append(
            """
            let response = try await self.provider.request(builder)
            try response.validate()
            """
        )

        if let returnType = funcDecl?.signature.returnClause?.type, returnType.trimmedDescription != "Void" {
            if let c = returnType.as(TupleTypeSyntax.self) {
                let converted = convertTuple(c, context: context)
                codes.append(converted)
            } else {
                codes.append(
                    """
                    return try response.decode(\(raw: returnType).self, using: builder.payloadFormat)
                    """
                )
            }
        }

        return codes
    }

    private static func convertTuple(_ tuple: TupleTypeSyntax, context: some MacroExpansionContext) -> CodeBlockItemSyntax {
        let structName = context.makeUniqueName("Response")
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

        let codeBlock: CodeBlockItemSyntax = """
        struct \(raw: structName): Codable {
            \(raw: propertiesCode)
        }
        let responseData = try response.decode(\(raw: structName).self, using: builder.payloadFormat)
        return (\(raw: tupleCode))
        """

        return codeBlock
    }
}
