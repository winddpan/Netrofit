import Foundation

public enum DynamicContentTypeError: Error {
    case undetectContentType(String?)
}

open class DynamicContentTypeDecoder: HTTPBodyDecoder {
    open func decodeBody<D>(_ type: D.Type, from data: Data, contentType: String?) throws -> D where D: Decodable {
        let mainType = contentType?
            .split(separator: ";", maxSplits: 1, omittingEmptySubsequences: true)
            .first?
            .trimmingCharacters(in: .whitespacesAndNewlines)
            .lowercased()

        switch mainType {
        case "text/plain":
            return try TextPlainDecoder().decodeBody(type, from: data, contentType: contentType)
        case "application/json":
            return try JSONDecoder().decodeBody(type, from: data, contentType: contentType)
        case "text/event-stream":
            return try EventStreamingDecoder().decodeBody(type, from: data, contentType: contentType)
        default:
            throw DynamicContentTypeError.undetectContentType(contentType)
        }
    }

    public init() {}
}
