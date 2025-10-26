import Foundation

public protocol HTTPBodyEncoder {
    var contentType: String { get }
    func encodeBody<E: Encodable>(_ value: E) throws -> Data?
}
