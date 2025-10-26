import Foundation

extension JSONEncoder: HTTPBodyEncoder {
    public func encodeBody<E>(_ value: E) throws -> Data? where E: Encodable {
        try encode(value)
    }

    public var contentType: String { "application/json" }
}
