import Foundation

public extension PayloadFormat {
    static let Multipart = PayloadFormat(encoder: MultipartEncoder(), decoder: MultipartDecoder())
}

open class MultipartEncoder: HTTPBodyEncoder {
    open var contentType: String { "multipart/form-data; boundary=\(boundary)" }
    public let boundary: String
    public let crlf = "\r\n"

    public func encode<E>(_ value: E) throws -> Data where E: Encodable {
        fatalError()
    }

    public init(boundary: String? = nil) {
        self.boundary = boundary ?? .randomMultipartBoundary()
    }
//
//    open func encode(_ value: some Encodable) throws -> Data {
//        guard let parts = value as? [String: Part] else {
//            preconditionFailure("Can only encode `[String: Part]` with `MultipartEncoder`. Got \(type(of: value)) instead")
//        }
//
//        let initialBoundary = Data("--\(boundary)\(crlf)".utf8)
//        let middleBoundary = Data("\(crlf)--\(boundary)\(crlf)".utf8)
//        let finalBoundary = Data("\(crlf)--\(boundary)--\(crlf)".utf8)
//
//        var body = Data()
//        for (key, part) in parts.sorted(by: { $0.key < $1.key }) {
//            body += body.isEmpty ? initialBoundary : middleBoundary
//            body += partHeaderData(part, key: key)
//            body += part.data
//        }
//
//        return body + finalBoundary
//    }
//
//    private func partHeaderData(_ part: Part, key: String) -> Data {
//        var disposition = "form-data; name=\"\(key)\""
//        if let fileName = part.fileName {
//            disposition += "; filename=\"\(fileName)\""
//        }
//
//        var headers = ["Content-Disposition": disposition]
//        if let mimeType = part.mimeType {
//            headers["Content-Type"] = mimeType
//        }
//
//        let string = headers.map { "\($0): \($1)\(crlf)" }.sorted().joined() + crlf
//        return Data(string.utf8)
//    }
}

open class MultipartDecoder: HTTPBodyDecoder {
    public let boundary: String

    public init(boundary: String? = nil) {
        self.boundary = boundary ?? .randomMultipartBoundary()
    }

    public func decode<D>(_ type: D.Type, from: Data) throws -> D where D: Decodable {
        fatalError("multipart decoding isn't supported, yet")
    }
}

private extension String {
    static func randomMultipartBoundary() -> String {
        let first = UInt32.random(in: UInt32.min ... UInt32.max)
        let second = UInt32.random(in: UInt32.min ... UInt32.max)
        return String(format: "papyrus.boundary.%08x%08x", first, second)
    }

    static let crlf = "\r\n"
}
