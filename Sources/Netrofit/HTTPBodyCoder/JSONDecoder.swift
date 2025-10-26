import Foundation

extension JSONDecoder: HTTPBodyDecoder {
    public func decodeBody<D>(_ type: D.Type, from data: Data) throws -> D where D: Decodable {
        try decode(type, from: data)
    }
}
