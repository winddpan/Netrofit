import Foundation

open class EventStreamingEncoder: HTTPBodyEncoder {
    open var contentType: String {
        "text/event-stream"
    }

    open func encodeBody<E>(_ value: E) throws -> Data? where E: Encodable {
        fatalError()
    }

    public init() {}
}
