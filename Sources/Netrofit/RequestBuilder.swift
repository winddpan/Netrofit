import Foundation

public enum NetrofitRequestError: Error {
    case badURL(String)
}

public enum PayloadFormat: String {
    case JSON
    case FormUrlEncoded
    case Multipart
    case EventStreaming
}

public struct RequestBuilder {
    public var path: String
    public var method: String
    public var encoder: HTTPBodyEncoder
    public var decoder: HTTPBodyDecoder
    public var headers: [String: String] = [:]
    public var queries: [String: String] = [:]
    public var body: Encodable?
    public var fields: [String: Encodable] = [:]
    public var parts: [NetrofitBodyPart] = []

    public var responseKeyPath: String?
    public var payloadFormat: PayloadFormat = .JSON

    public init(path: String, method: String, encoder: HTTPBodyEncoder, decoder: HTTPBodyDecoder, headers: [String: String]?) {
        self.path = path
        self.method = method
        self.encoder = encoder
        self.decoder = decoder
        self.headers = headers ?? [:]
    }

    public mutating func setResponseKeyPath(_ path: String) {
        responseKeyPath = path
    }

    public mutating func addHeaders(_ newHeaders: [String: String]?) {
        headers = headers.merging(newHeaders ?? [:], uniquingKeysWith: { _, new in new })
    }

    public mutating func addHeader(_ key: String, value: String?) {
        guard let value else { return }
        var headers = self.headers
        headers[key] = value
        self.headers = headers
    }

    public mutating func addQuery<T: CustomStringConvertible>(_ key: String, value: T?, encoded: Bool) {
        guard let value else { return }
        if let map = value as? [String: String] {
            for (key, value) in map {
                addQuery(key, value: value, encoded: encoded)
            }
            return
        }

        var stringValue = "\(value)"
        if !encoded {
            stringValue = stringValue.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? stringValue
        }
        queries = queries.merging([key: stringValue], uniquingKeysWith: { _, new in new })
    }

    public mutating func setBody<E: Encodable>(_ body: E?) {
        guard let body else { return }
        self.body = body
    }

    public mutating func addField<E: Encodable>(_ key: String, value: E?) {
        guard let value else { return }
        fields[key] = value
    }

    public mutating func addPart(_ name: String, value: String?, filename: String?, mimeType: String?) {
        guard let data = value?.data(using: .utf8) else { return }
        addPart(name, value: data, filename: filename, mimeType: mimeType)
    }

    public mutating func addPart(_ name: String, value: Data?, filename: String?, mimeType: String?) {
        guard let value else { return }
        parts.append(NetrofitBodyPart(name: name, data: value, filename: filename, mimeType: mimeType))
    }
}

extension RequestBuilder {
    public func fullURL(baseURL: String) throws -> URL {
        var baseURL = baseURL
        var path = path
        if baseURL.hasSuffix("/") {
            baseURL = String(baseURL.dropLast())
        }
        if path.hasPrefix("/") {
            path = String(baseURL.dropFirst())
        }
        let urlStr = "\(baseURL)/\(path)"

        var queryItems = [URLQueryItem]()
        for query in queries {
            queryItems.append(URLQueryItem(name: query.key, value: query.value))
        }

        var urlCompoments = URLComponents(string: urlStr)
        urlCompoments?.queryItems = queryItems.isEmpty ? nil : queryItems
        if let url = urlCompoments?.url {
            return url
        }
        throw NetrofitRequestError.badURL(urlStr)
    }

    public func bodyData() throws -> Data? {
        switch payloadFormat {
        case .JSON:
            try JSONPayloadData()
        case .FormUrlEncoded:
            try formUrlEncodedPayloadData()
        case .Multipart:
            try multipartPayloadData()
        case .EventStreaming:
            try streamingPayloadData()
        }
    }

    public func fullHeaders() -> [String: String] {
        let contentType = ["Content-Type": encoder.contentType]
        return contentType.merging(headers, uniquingKeysWith: { _, new in new })
    }

    private func JSONPayloadData() throws -> Data? {
        if let body {
            return try encoder.encodeBody(body)
        } else if !fields.isEmpty {
            var mappedFields = [String: _AnyEncodable]()
            for (key, value) in fields {
                mappedFields[key] = _AnyEncodable(value)
            }
            return try encoder.encodeBody(mappedFields)
        }
        return nil
    }

    private func streamingPayloadData() throws -> Data? {
        try JSONPayloadData()
    }

    private func formUrlEncodedPayloadData() throws -> Data? {
        var mappedFields = [String: String]()
        for (key, value) in fields {
            mappedFields[key] = "\(value)"
        }
        return try encoder.encodeBody(mappedFields)
    }

    private func multipartPayloadData() throws -> Data? {
        return try encoder.encodeBody(parts)
    }
}
