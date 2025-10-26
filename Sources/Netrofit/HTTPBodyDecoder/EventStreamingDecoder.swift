import Foundation

public enum EventStreamingDecoderError: Error {
    case emptyResponseData
    case unexpectedResponseData
}

open class EventStreamingDecoder: HTTPBodyDecoder {
    open func decodeBody<D>(_ type: D.Type, from data: Data, contentType: String?) throws -> D where D: Decodable {
        guard var line = String(data: data, encoding: .utf8) else {
            throw EventStreamingDecoderError.emptyResponseData
        }
        if line.hasPrefix("data:") {
            line = String(line.dropFirst(5).trimmingCharacters(in: .whitespacesAndNewlines))
        }
        if type == String.self {
            return line as! D
        }

        // if return type is not String, try JSON decode
        guard let fixedData = line.data(using: .utf8) else {
            throw EventStreamingDecoderError.unexpectedResponseData
        }
        return try JSONDecoder().decode(type, from: fixedData)
    }

    public init() {}
}
