import Foundation

struct _NetrofitResponse: NetrofitResponse {
    var request: URLRequest
    var body: Data?
    var headers: [String: String]?
    var statusCode: Int?
    var error: Error?

    init(request: URLRequest) {
        self.request = request
    }

    func decode<T: Decodable>(_ type: T.Type, using: HTTPBodyDecoder) throws -> T {
        fatalError()
    }

    func validate() throws {}
}
