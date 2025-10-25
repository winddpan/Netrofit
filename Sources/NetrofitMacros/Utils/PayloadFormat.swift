import SwiftSyntax

enum PayloadFormat: String {
    case JSON
    case FormUrlEncoded
    case Multipart
}

extension AttributeListSyntax {
    var payloadFormat: PayloadFormat? {
        if let _ = findAttribute(named: "JSON") {
            return .JSON
        } else if let _ = findAttribute(named: "FormUrlEncoded") {
            return .FormUrlEncoded
        } else if let _ = findAttribute(named: "Multipart") {
            return .Multipart
        }
        return nil
    }
}
