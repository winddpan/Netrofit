import Foundation

enum NetrofitResponseError: Error {
    case decodingEmptyDataError
    case statusCodeError(Int)
}

struct _NetrofitResponse: NetrofitResponse {
    var request: URLRequest
    var body: Data?
    var headers: [String: String]?
    var statusCode: Int?
    var error: Error?

    init(request: URLRequest) {
        self.request = request
    }

    func decode<T: Decodable>(_ type: T.Type, using decoder: HTTPBodyDecoder) throws -> T {
        guard let body else {
            throw NetrofitResponseError.decodingEmptyDataError
        }
        return try decoder.decodeBody(type, from: body, contentType: headers?["Content-Type"])
    }

    func validate() throws {
        if let error { throw error }
        if !(200 ..< 300).contains(statusCode ?? -1) {
            throw NetrofitResponseError.statusCodeError(statusCode ?? -1)
        }
    }
}
