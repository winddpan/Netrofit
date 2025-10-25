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

extension LabeledExprListSyntax.Element {
    var literalExprDescription: String? {
        let expr = expression
        if let stringLiteral = expr.as(StringLiteralExprSyntax.self) {
            return stringLiteral.segments
                .compactMap { segment -> String? in
                    if let seg = segment.as(StringSegmentSyntax.self) {
                        return seg.content.text
                    }
                    return nil
                }
                .joined()
        }
        if let intLiteral = expr.as(IntegerLiteralExprSyntax.self) {
            return intLiteral.literal.text
        }
        if let floatLiteral = expr.as(FloatLiteralExprSyntax.self) {
            return floatLiteral.literal.text
        }
        if let booleanLiteral = expr.as(BooleanLiteralExprSyntax.self) {
            return booleanLiteral.literal.text
        }
        if let _ = expr.as(NilLiteralExprSyntax.self) {
            return "nil"
        }
        return nil
    }
}
