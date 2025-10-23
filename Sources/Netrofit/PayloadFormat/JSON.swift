import Foundation

extension JSONEncoder: HTTPBodyEncoder {
    public var contentType: String { "application/json" }
}

extension JSONDecoder: HTTPBodyDecoder {}

public extension PayloadFormat {
    static let JSON = PayloadFormat(encoder: JSONEncoder(), decoder: JSONDecoder())
}
