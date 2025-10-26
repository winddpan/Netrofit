import Foundation

open class URLEncodedFormEncoder: HTTPBodyEncoder {
    open var contentType: String {
        "application/x-www-form-urlencoded"
    }

    open func encodeBody<E>(_ value: E) throws -> Data? where E: Encodable {
        guard let queries = value as? [String: String], !queries.isEmpty else {
            return nil
        }
        var data = Data()
        for (key, value) in queries {
            if let line = "\(key)=\(value)".data(using: .utf8) {
                data.append(line)
            }
        }
        return data
    }

    public init() {}
}
