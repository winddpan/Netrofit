import Foundation

open class URLEncodedFormEncoder: HTTPBodyEncoder {
    open var contentType: String {
        "application/x-www-form-urlencoded"
    }

    open func encode<E>(_ value: E) throws -> Data where E: Encodable {
        fatalError()
    }

    public init() {}
}

open class URLEncodedFormDecoder: HTTPBodyDecoder {
    open func decode<D>(_ type: D.Type, from: Data) throws -> D where D: Decodable {
        fatalError()
    }

    public init() {}
}

public extension PayloadFormat {
    static let FormUrlEncoded = PayloadFormat(encoder: URLEncodedFormEncoder(), decoder: URLEncodedFormDecoder())
}
