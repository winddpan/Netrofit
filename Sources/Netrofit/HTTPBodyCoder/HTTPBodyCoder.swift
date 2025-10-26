import Foundation

public protocol HTTPBodyEncoder {
    var contentType: String { get }
    func encodeBody<E: Encodable>(_ value: E) throws -> Data?
}

public protocol HTTPBodyDecoder {
    func decodeBody<D: Decodable>(_ type: D.Type, from data: Data) throws -> D
}
