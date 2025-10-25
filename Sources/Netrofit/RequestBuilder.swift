import Foundation

public struct RequestBuilder {
    public var path: String
    public var method: String
    public var encoder: HTTPBodyEncoder
    public var decoder: HTTPBodyDecoder
    public var headers: [String: String]?
    public var playloadFormat: String = "JSON"

    public init(path: String, method: String, encoder: HTTPBodyEncoder, decoder: HTTPBodyDecoder, headers: [String: String]? = nil) {
        self.path = path
        self.method = method
        self.encoder = encoder
        self.decoder = decoder
        self.headers = headers
    }


    public mutating func setResponseKeyPath(_ path: String) {

    }


    public mutating func addHeaders(_ newHeaders: [String: String]?) {
        if let headers {
            self.headers = headers.merging(newHeaders ?? [:], uniquingKeysWith: { _, new in new })
        } else {
            headers = newHeaders
        }
    }


    public mutating func addHeader(_ key: String, value: String?) {

    }

    public mutating func addQuery(_ newHeaders: [String: String]?) {
        if let headers {
            self.headers = headers.merging(newHeaders ?? [:], uniquingKeysWith: { _, new in new })
        } else {
            headers = newHeaders
        }
    }

    public mutating func addQuery<T: CustomStringConvertible>(_ key: String, value: T?, encoded: Bool) {
        guard let value else { return }

    }

    public mutating func setBody<T: Encodable>(_ body: T?) {


    }

    public mutating func addField<E: Encodable>(_ key: String, value: E) {

    }


    public mutating func addPart<E: Encodable>(_ name: String, value: E, filename: String?, mimeType: String?) {

    }


}
