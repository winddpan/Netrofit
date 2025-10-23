import SwiftSyntax

extension AttributeListSyntax {
    func findAttribute(named: String) -> AttributeSyntax? {
        first(where: { element in element.as(AttributeSyntax.self)?.attributeName.as(IdentifierTypeSyntax.self)?.name.text == named })?.as(
            AttributeSyntax.self)
    }
}
