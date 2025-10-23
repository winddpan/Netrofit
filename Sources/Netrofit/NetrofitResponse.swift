import Foundation

public struct NetrofitResponse {
//    let request: PapyrusRequest? { get }
//    let body: Data? { get }
//    let headers: [String: String]? { get }
//    let statusCode: Int? { get }
//    let error: Error? { get }

    public func validate() throws {

    }

    public func decode<T: Decodable>(_ type: T.Type, using: PayloadFormat) throws -> T {
        fatalError()
    }
}
