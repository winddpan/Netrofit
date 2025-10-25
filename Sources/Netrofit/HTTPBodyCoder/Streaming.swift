import Foundation

open class StreamingEncoder: HTTPBodyEncoder {
    open var contentType: String {
        "text/event-stream"
    }

    open func encode<E>(_ value: E) throws -> Data where E: Encodable {
        fatalError()
    }

    public init() {}
}

open class StreamingDecoder: HTTPBodyDecoder {
    open func decode<D>(_ type: D.Type, from: Data) throws -> D where D: Decodable {
        fatalError()
    }

    public init() {}
}
