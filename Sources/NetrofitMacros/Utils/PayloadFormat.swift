import SwiftSyntax

enum PayloadFormat: String {
    case JSON
    case FormUrlEncoded
    case Multipart
    case EventStreaming
}

extension AttributeListSyntax {
    var payloadFormat: PayloadFormat? {
        if let _ = findAttribute(named: "JSON") {
            return .JSON
        } else if let _ = findAttribute(named: "FormUrlEncoded") {
            return .FormUrlEncoded
        } else if let _ = findAttribute(named: "Multipart") {
            return .Multipart
        } else if let _ = findAttribute(named: "EventStreaming") {
            return .EventStreaming
        }
        return nil
    }
}
