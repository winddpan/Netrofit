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

        let codec = attributes?.getCoderIdentifierType()
        let encoder = codec?.encoder ?? "JSONEncoder()"
        let decoder = codec?.decoder ?? "JSONDecoder()"

        let ifPublic = declaration.modifiers.contains(where: {
            $0.name.text == "public" || $0.name.text == "open"
        })

        let provider: DeclSyntax = """
        private let provider: Netrofit.NetrofitProvider

        \(raw: ifPublic ? "public init" : "init")(_ provider: Netrofit.NetrofitProvider) {
            self.provider = provider
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
