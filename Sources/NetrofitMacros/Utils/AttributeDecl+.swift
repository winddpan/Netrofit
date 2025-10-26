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

extension AttributeListSyntax {
    func getCoderIdentifierType() -> (encoder: String?, decoder: String?) {
        var encoder: String?
        var decoder: String?
        if let attribute = findAttribute(named: "FormUrlEncoded") {
            encoder = attribute.findLabel(named: "encoder")?.expression.trimmedDescription ?? "URLEncodedFormEncoder()"
            decoder = attribute.findLabel(named: "decoder")?.expression.trimmedDescription ?? "DynamicContentTypeDecoder()"
        } else if let attribute = findAttribute(named: "Multipart") {
            encoder = attribute.findLabel(named: "encoder")?.expression.trimmedDescription ?? "MultipartEncoder()"
            decoder = attribute.findLabel(named: "decoder")?.expression.trimmedDescription ?? "DynamicContentTypeDecoder()"
        } else if let attribute = findAttribute(named: "JSON") {
            encoder = attribute.findLabel(named: "encoder")?.expression.trimmedDescription ?? "JSONEncoder()"
            decoder = attribute.findLabel(named: "decoder")?.expression.trimmedDescription ?? "JSONDecoder()"
        } else if let attribute = findAttribute(named: "EventStreaming") {
            encoder = attribute.findLabel(named: "encoder")?.expression.trimmedDescription ?? "EventStreamingEncoder()"
            decoder = attribute.findLabel(named: "decoder")?.expression.trimmedDescription ?? "DynamicContentTypeDecoder()"
        }
        return (encoder, decoder)
    }
}
