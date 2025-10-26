import Foundation

public enum TextPlainDecoderError: Error {
    case unexpectedReturnType
}

open class TextPlainDecoder: HTTPBodyDecoder {
    open func decodeBody<D>(_ type: D.Type, from data: Data, contentType: String?, deocdeKeyPath: String?) throws -> D where D: Decodable {
        if type == String.self {
            return String(data: data, encoding: .utf8) as! D
        }
        throw TextPlainDecoderError.unexpectedReturnType
    }

    public init() {}
}
