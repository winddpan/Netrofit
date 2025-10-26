import Foundation

public protocol HTTPBodyDecoder {
    func decodeBody<D: Decodable>(_ type: D.Type, from data: Data, contentType: String?) throws -> D
}
