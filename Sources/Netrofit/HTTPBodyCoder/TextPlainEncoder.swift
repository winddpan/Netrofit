import Foundation

open class TextPlainEncoder: HTTPBodyEncoder {
    open var contentType: String {
        "text/plain"
    }

    open func encodeBody<E>(_ value: E) throws -> Data? where E: Encodable {
        fatalError()
    }

    public init() {}
}
