import Foundation

enum NetrofitTaskError: Error {
    case multipleStreamsUnsupported
    case unexpectedDecodingError(Error)
    case unexpectedError(Error)
}

final class _NetrofitTask: NetrofitTask, Hashable {
    enum StreamingState {
        case idle
        case streaming
    }

    private enum ContinuationKind {
        case response(CheckedContinuation<any NetrofitResponse, Never>)
        case stream(StreamWrapper)
        case throwingStream(ThrowingStreamWrapper)
    }

    private struct StreamWrapper {
        let decoder: any HTTPBodyDecoder
        let yield: (Data) -> Void
        let finish: () -> Void
    }

    private struct ThrowingStreamWrapper {
        let decoder: any HTTPBodyDecoder
        let yield: (Result<Data, Error>) -> Void
        let finish: (Result<Void, Error>) -> Void
    }

    let uuid = UUID()
    let urlSession: URLSession
    let request: URLRequest

    var urlResponse: URLResponse?
    private(set) var responseData = Data()
    private(set) var dataTask: URLSessionDataTask?

    private var state: StreamingState = .idle
    private var continuations: [ContinuationKind] = []

    init(urlSession: URLSession, request: URLRequest) {
        self.urlSession = urlSession
        self.request = request
    }

    func resume() {
        guard dataTask == nil else { return }
        let task = urlSession.dataTask(with: request)
        task.resume()
        dataTask = task
    }

    func waitUntilFinished() async -> any NetrofitResponse {
        await withCheckedContinuation { continuation in
            continuations.append(.response(continuation))
        }
    }

    func connectStream<T>(
        _ type: T.Type,
        using decoder: any HTTPBodyDecoder
    ) throws -> AsyncStream<T> where T: Decodable {
        guard state == .idle else {
            throw NetrofitTaskError.multipleStreamsUnsupported
        }

        state = .streaming

        return AsyncStream<T> { continuation in
            let wrapper = StreamWrapper(
                decoder: decoder,
                yield: { chunk in
                    do {
                        let value = try decoder.decode(T.self, from: chunk)
                        continuation.yield(value)
                    } catch {
                        continuation.finish()
                    }
                },
                finish: {
                    continuation.finish()
                }
            )
            continuations.append(.stream(wrapper))
        }
    }

    func connectThrowingStream<T>(
        _ type: T.Type,
        using decoder: any HTTPBodyDecoder
    ) throws -> AsyncThrowingStream<T, Error> where T: Decodable {
        guard state == .idle else {
            throw NetrofitTaskError.multipleStreamsUnsupported
        }

        state = .streaming

        return AsyncThrowingStream(T.self, bufferingPolicy: .unbounded) { continuation in
            let wrapper = ThrowingStreamWrapper(
                decoder: decoder,
                yield: { result in
                    switch result {
                    case let .success(chunk):
                        do {
                            let value = try decoder.decode(T.self, from: chunk)
                            continuation.yield(value)
                        } catch {
                            continuation.finish(throwing: NetrofitTaskError.unexpectedDecodingError(error))
                        }
                    case let .failure(error):
                        continuation.finish(throwing: NetrofitTaskError.unexpectedError(error))
                    }
                },
                finish: { result in
                    switch result {
                    case .success:
                        continuation.finish()
                    case let .failure(error):

                        continuation.finish(throwing: NetrofitTaskError.unexpectedError(error))
                    }
                }
            )
            continuations.append(.throwingStream(wrapper))
        }
    }

    func didReceiveData(_ data: Data) {
        responseData.append(data)
        for continuation in continuations {
            switch continuation {
            case let .stream(wrapper):
                wrapper.yield(data)
            case let .throwingStream(wrapper):
                wrapper.yield(.success(data))
            case .response:
                break
            }
        }
    }

    func didCompleteWithError(_ error: (any Error)?) {
        dataTask = nil

        let httpResponse = urlResponse as? HTTPURLResponse
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

        continuations.removeAll { element in
            switch element {
            case let .response(continuation):
                continuation.resume(returning: response)
                return true
            case let .stream(wrapper):
                if error == nil {
                    wrapper.finish()
                } else {
                    wrapper.finish()
                }
                return true
            case let .throwingStream(wrapper):
                if let error {
                    wrapper.finish(.failure(error))
                } else {
                    wrapper.finish(.success(()))
                }
                return true
            }
        }

        state = .idle
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(uuid)
    }

    static func == (lhs: _NetrofitTask, rhs: _NetrofitTask) -> Bool {
        lhs.hashValue == rhs.hashValue
    }
}
