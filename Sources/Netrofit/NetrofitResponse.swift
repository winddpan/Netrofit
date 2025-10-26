import Foundation

public enum NetrofitResponseError: Error {
    case decodingEmptyDataError
    case statusCodeError(Int)
}

public struct NetrofitResponse {
    public var request: URLRequest
    public var body: Data?
    public var headers: [String: String]?
    public var statusCode: Int?
    public var error: Error?

    public init(request: URLRequest) {
        self.request = request
    }

    public func validate() throws {
        if let error { throw error }
        if !(200 ..< 300).contains(statusCode ?? -1) {
            throw NetrofitResponseError.statusCodeError(statusCode ?? -1)
        }
    }
}
