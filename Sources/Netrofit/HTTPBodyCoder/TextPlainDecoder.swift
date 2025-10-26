import Foundation

enum TextPlainDecoderError: Error {
    case unexcptedReturnType
}

open class TextPlainDecoder: HTTPBodyDecoder {
    open func decodeBody<D>(_ type: D.Type, from data: Data) throws -> D where D: Decodable {
        if type == String.self {
            return String(data: data, encoding: .utf8) as! D
        }
        throw TextPlainDecoderError.unexcptedReturnType
    }

    public init() {}
}
