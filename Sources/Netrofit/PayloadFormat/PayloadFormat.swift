import Foundation

public protocol HTTPBodyEncoder {
    var contentType: String { get }
    func encode<E: Encodable>(_ value: E) throws -> Data
}

public protocol HTTPBodyDecoder {
    func decode<D: Decodable>(_ type: D.Type, from: Data) throws -> D
}

public struct PayloadFormat {
    public let encoder: HTTPBodyEncoder
    public let decoder: HTTPBodyDecoder

    public init(encoder: HTTPBodyEncoder, decoder: HTTPBodyDecoder) {
        self.encoder = encoder
        self.decoder = decoder
    }
}
