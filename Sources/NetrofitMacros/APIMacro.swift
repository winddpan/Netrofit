import SwiftDiagnostics
import SwiftSyntax
import SwiftSyntaxMacros

struct APIMacro: MemberMacro {
    static func expansion(of node: AttributeSyntax, providingMembersOf declaration: some DeclGroupSyntax, in context: some MacroExpansionContext) throws -> [DeclSyntax] {
        var attributes: AttributeListSyntax?
        if let declaration = declaration.as(StructDeclSyntax.self) {
            attributes = declaration.attributes
        } else if let declaration = declaration.as(ClassDeclSyntax.self) {
            attributes = declaration.attributes
        }
        let headers = attributes?.findAttribute(named: "Headers")?.arguments?.trimmed.description
        let payloadFormat: String
        if attributes?.findAttribute(named: "FormUrlEncoded") != nil {
            payloadFormat = "PayloadFormat.FormUrlEncoded"
        } else if attributes?.findAttribute(named: "Multipart") != nil {
            payloadFormat = "PayloadFormat.Multipart"
        } else {
            payloadFormat = "PayloadFormat.JSON"
        }

        let ifPublic = declaration.modifiers.contains(where: {
            $0.name.text == "public" || $0.name.text == "open"
        })

        let provider: DeclSyntax = """
        private let provider: Netrofit.Provider

        \(raw: ifPublic ? "public init": "init")(_ provider: Netrofit.Provider) {
            self.provider = provider
        }

        private var headers: [String: String]? { 
            \(raw: headers ?? "nil") 
        }

        private func builder(path: String, method: String) -> RequestBuilder {
            var builder = RequestBuilder(path: path, method: method, payloadFormat: \(raw: payloadFormat))
            builder.addHeaders(headers)
            return builder
        }
        """

        return [provider]
    }
}
