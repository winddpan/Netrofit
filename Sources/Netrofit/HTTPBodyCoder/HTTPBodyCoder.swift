import Foundation

public protocol HTTPBodyEncoder {
    var contentType: String { get }
    func encode<E: Encodable>(_ value: E) throws -> Data
}

public protocol HTTPBodyDecoder {
    func decode<D: Decodable>(_ type: D.Type, from: Data) throws -> D
}
