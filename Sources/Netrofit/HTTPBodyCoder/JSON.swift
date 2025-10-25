import Foundation

extension JSONEncoder: HTTPBodyEncoder {
    public var contentType: String { "application/json" }
}

extension JSONDecoder: HTTPBodyDecoder {}
