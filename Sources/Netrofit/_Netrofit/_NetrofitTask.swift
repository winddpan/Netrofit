import Foundation

enum NetrofitTaskError: Error {
    case multipleStreamsUnsupported
    case unexpectedDecodingError(Error)
    case unexpectedError(Error)
}

final class _NetrofitTask: NetrofitTask, Hashable {
    enum EventStreamingState {
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

    private var state: EventStreamingState = .idle
    private var continuations: [ContinuationKind] = []
    private var lineBuffer = Data() // Buffer for accumulating incomplete lines in SSE streaming

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
                yield: { [weak self] chunk in
                    do {
                        let contentType = (self?.urlResponse as? HTTPURLResponse)?.allHeaderFields["Content-Type"] as? String
                        let value = try decoder.decodeBody(T.self, from: chunk, contentType: contentType)
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

        return AsyncThrowingStream(T.self) { continuation in
            let wrapper = ThrowingStreamWrapper(
                decoder: decoder,
                yield: { [weak self] result in
                    switch result {
                    case let .success(chunk):
                        do {
                            let contentType = (self?.urlResponse as? HTTPURLResponse)?.allHeaderFields["Content-Type"] as? String
                            let value = try decoder.decodeBody(T.self, from: chunk, contentType: contentType)
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

        // For streaming scenarios, accumulate data and process line by line (SSE format)
        guard state == .streaming else { return }

        lineBuffer.append(data)

        // Find all complete lines (separated by \n or \r\n)
        let newline = UInt8(ascii: "\n")
        var startIndex = lineBuffer.startIndex

        while let newlineIndex = lineBuffer[startIndex...].firstIndex(of: newline) {
            // Extract the complete line (including the newline)
            let lineData = lineBuffer[startIndex ... newlineIndex]

            var yield = true
            if lineData.isEmpty {
                yield = false
            }
            if lineData.count == 1, lineData.first == newline {
                yield = false
            }
            if yield {
                // Yield the complete line to all stream continuations
                for continuation in continuations {
                    switch continuation {
                    case let .stream(wrapper):
                        wrapper.yield(Data(lineData))
                    case let .throwingStream(wrapper):
                        wrapper.yield(.success(Data(lineData)))
                    case .response:
                        break
                    }
                }
            }

            startIndex = lineBuffer.index(after: newlineIndex)
        }

        // Keep the remaining incomplete data in buffer
        if startIndex < lineBuffer.endIndex {
            lineBuffer = Data(lineBuffer[startIndex...])
        } else {
            lineBuffer.removeAll(keepingCapacity: true)
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

        // Process any remaining buffered data before finishing stream
        if state == .streaming && !lineBuffer.isEmpty {
            for continuation in continuations {
                switch continuation {
                case let .stream(wrapper):
                    wrapper.yield(lineBuffer)
                case let .throwingStream(wrapper):
                    wrapper.yield(.success(lineBuffer))
                case .response:
                    break
                }
            }
            lineBuffer.removeAll()
        }

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
