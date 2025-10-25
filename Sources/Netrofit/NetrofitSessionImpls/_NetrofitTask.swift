import Foundation

class _NetrofitTask: NetrofitTask, Hashable {
    let uuid = UUID()
    let urlSession: URLSession
    let request: URLRequest
    var responseData = Data()
    var urlResponse: URLResponse?
    private(set) var dataTask: URLSessionDataTask?
    private var continuations: [CheckedContinuation<any NetrofitResponse, Never>] = []

    init(urlSession: URLSession, request: URLRequest) {
        self.urlSession = urlSession
        self.request = request
    }

    func resume() {
        let task = urlSession.dataTask(with: request)
        task.resume()
        dataTask = task
    }

    func waitUntilFinished() async -> any NetrofitResponse {
        await withCheckedContinuation { continuation in
            self.continuations.append(continuation)
        }
    }

    func connectStream<T>(_ type: T.Type, using: any HTTPBodyDecoder) throws -> AsyncStream<T> where T: Decodable {
        fatalError()
    }

    func connectThrowingStream<T, E>(_ type: T.Type, errorType: E.Type, using: any HTTPBodyDecoder) throws -> AsyncThrowingStream<T, E> where T: Decodable, E: Error {
        fatalError()
    }

    func didCompleteWithError(_ error: (any Error)?) {
        dataTask = nil

        let httpResponse = (urlResponse as? HTTPURLResponse)
        let headers = httpResponse?.allHeaderFields.compactMap { key, value -> (String, String)? in
            guard let k = key as? String,
                  let v = value as? String
            else {
                return nil
            }
            return (k, v)
        }.reduce(into: [String: String]()) { $0[$1.0] = $1.1 }

        var response = _NetrofitResponse(request: request)
        response.error = error
        response.body = responseData
        response.headers = headers
        response.statusCode = httpResponse?.statusCode

        self.continuations.forEach { continuation in
            continuation.resume(returning: response)
        }
        self.continuations.removeAll()
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(uuid)
    }

    static func == (lhs: _NetrofitTask, rhs: _NetrofitTask) -> Bool {
        lhs.hashValue == rhs.hashValue
    }
}
