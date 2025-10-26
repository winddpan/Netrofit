import Foundation

public struct NetrofitBodyPart: Encodable {
    public let name: String
    public let data: Data
    public let fileName: String?
    public let mimeType: String?
}

open class MultipartEncoder: HTTPBodyEncoder {
    open var contentType: String {
        "multipart/form-data; boundary=\(boundary)"
    }

    public let boundary: String
    public let crlf = "\r\n"

    public init(boundary: String? = nil) {
        self.boundary = boundary ?? .randomMultipartBoundary()
    }

    open func encodeBody<E>(_ value: E) throws -> Data? where E: Encodable {
        guard let parts = value as? [NetrofitBodyPart] else {
            return nil
        }
        let initialBoundary = Data("--\(boundary)\(crlf)".utf8)
        let middleBoundary = Data("\(crlf)--\(boundary)\(crlf)".utf8)
        let finalBoundary = Data("\(crlf)--\(boundary)--\(crlf)".utf8)

        var body = Data()
        for part in parts {
            body += body.isEmpty ? initialBoundary : middleBoundary
            body += partHeaderData(part)
            body += part.data
        }

        return body + finalBoundary
    }

    private func partHeaderData(_ part: NetrofitBodyPart) -> Data {
        var disposition = "form-data; name=\"\(part.name)\""
        if let fileName = part.fileName {
            disposition += "; filename=\"\(fileName)\""
        }

        var headers = ["Content-Disposition": disposition]
        if let mimeType = part.mimeType {
            headers["Content-Type"] = mimeType
        }

        let string = headers.map { "\($0): \($1)\(crlf)" }.sorted().joined() + crlf
        return Data(string.utf8)
    }
}

private extension String {
    static func randomMultipartBoundary() -> String {
        let first = UInt32.random(in: UInt32.min ... UInt32.max)
        let second = UInt32.random(in: UInt32.min ... UInt32.max)
        return String(format: "netrofit.boundary.%08x%08x", first, second)
    }
}
