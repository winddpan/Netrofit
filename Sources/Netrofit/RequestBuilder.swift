import Foundation

public struct RequestBuilder {
    public var path: String
    public var method: String
    public var payloadFormat: PayloadFormat
    public var headers: [String: String]?

    public init(path: String, method: String, payloadFormat: PayloadFormat) {
        self.path = path
        self.method = method
        self.payloadFormat = payloadFormat
    }

    public mutating func addHeaders(_ newHeaders: [String: String]?) {
        if let headers {
            self.headers = headers.merging(newHeaders ?? [:], uniquingKeysWith: { _, new in new })
        } else {
            headers = newHeaders
        }
    }
}
