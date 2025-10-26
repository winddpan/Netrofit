import Foundation

open class URLEncodedFormEncoder: HTTPBodyEncoder {
    open var contentType: String {
        "application/x-www-form-urlencoded"
    }

    open func encodeBody<E>(_ value: E) throws -> Data? where E: Encodable {
        guard let queries = value as? [String: String], !queries.isEmpty else {
            return nil
        }

        var hasPrev = false
        var data = Data()
        for (key, value) in queries {
            if hasPrev {
                data.append("&".data(using: .utf8)!)
            }
            if let seg = "\(key)=\(value)".data(using: .utf8) {
                data.append(seg)
                hasPrev = true
            }
        }
        return data
    }

    public init() {}
}
