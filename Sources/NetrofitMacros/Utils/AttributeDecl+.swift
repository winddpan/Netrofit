import SwiftSyntax

extension AttributeListSyntax {
    func findAttribute(named: String?) -> AttributeSyntax? {
        first(where: { element in element.as(AttributeSyntax.self)?.attributeName.as(IdentifierTypeSyntax.self)?.name.text == named })?.as(
            AttributeSyntax.self)
    }
}

extension AttributeSyntax {
    func findLabel(named: String?) -> LabeledExprListSyntax.Element? {
        let list = arguments?.as(LabeledExprListSyntax.self) ?? []
        for arg in list {
            if arg.label?.text == named {
                return arg
            }
        }
        return nil
    }
}
