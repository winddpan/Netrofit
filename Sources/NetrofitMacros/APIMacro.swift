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
        let headers = attributes?.findAttribute(named: "Headers")?.arguments?.trimmed.description ?? "nil"

        let encoder: String
        let decoder: String
        if let attribute = attributes?.findAttribute(named: "FormUrlEncoded") {
            encoder = attribute.findLabel(named: "encoder")?.trimmedDescription ?? "URLEncodedFormEncoder()"
            decoder = attribute.findLabel(named: "decoder")?.trimmedDescription ?? "URLEncodedFormDecoder()"
        } else if let attribute = attributes?.findAttribute(named: "Multipart") {
            encoder = attribute.findLabel(named: "encoder")?.trimmedDescription ?? "MultipartEncoder()"
            decoder = attribute.findLabel(named: "decoder")?.trimmedDescription ?? "MultipartDecoder()"
        } else if let attribute = attributes?.findAttribute(named: "JSON") {
            encoder = attribute.findLabel(named: "encoder")?.trimmedDescription ?? "JSONEncoder()"
            decoder = attribute.findLabel(named: "decoder")?.trimmedDescription ?? "JSONDecoder()"
        } else {
            encoder = "JSONEncoder()"
            decoder = "JSONDecoder()"
        }

        let ifPublic = declaration.modifiers.contains(where: {
            $0.name.text == "public" || $0.name.text == "open"
        })

        let provider: DeclSyntax = """
        private let provider: Netrofit.Provider

        \(raw: ifPublic ? "public init" : "init")(_ provider: Netrofit.Provider) {
            self.provider = provider
        }

        private var headers: [String: String]? { 
            \(raw: headers) 
        }

        private func builder(path: String, method: String) -> RequestBuilder {
            RequestBuilder(
                path: path, 
                method: method, 
                encoder: \(raw: encoder), 
                decoder: \(raw: decoder), 
                headers: \(raw: headers)
            )
        }
        """

        return [provider]
    }
}
