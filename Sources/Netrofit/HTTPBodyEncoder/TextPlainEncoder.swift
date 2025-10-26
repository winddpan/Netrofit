import Foundation

open class TextPlainEncoder: HTTPBodyEncoder {
    open var contentType: String {
        "text/plain"
    }

    open func encodeBody<E>(_ value: E) throws -> Data? where E: Encodable {
        if let data = value as? Data {
            return data
        }
        if let string = value as? String {
            return string.data(using: .utf8)
        }
        return "\(value)".data(using: .utf8)
    }

    public init() {}
}
