import Foundation

public struct NetrofitResponse {
//    let request: PapyrusRequest? { get }
//    let body: Data? { get }
//    let headers: [String: String]? { get }
//    let statusCode: Int? { get }
//    let error: Error? { get }

    public func validate() throws {

    }

    public func decode<T: Decodable>(_ type: T.Type, using: HTTPBodyDecoder) throws -> T {
        fatalError()
    }

    public func asyncStreaming<T: Decodable>(_ type: T.Type, using: HTTPBodyDecoder) throws -> AsyncStream<T> {
        fatalError()
    }

    public func asyncThrowingStreaming<T: Decodable, E: Error>(_ type: T.Type, errorType: E.Type, using: HTTPBodyDecoder) throws -> AsyncThrowingStream<T, E> {
        fatalError()
    }
}
