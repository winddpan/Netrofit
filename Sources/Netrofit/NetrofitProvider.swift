import Foundation

public protocol NetrofitInterceptor {
    typealias Next = (inout RequestBuilder) throws -> NetrofitTask
    func intercept(builder: inout RequestBuilder, next: Next) throws -> NetrofitTask
}

public enum NetrofitProviderError: Error {
    case badURL(String, String)
}

/// Makes URL requests.
public final class NetrofitProvider {
    public let baseURL: String
    public let session: NetrofitSession
    public var interceptors: [NetrofitInterceptor] = []

    public init(baseURL: String, session: NetrofitSession, interceptors: [NetrofitInterceptor] = []) {
        self.baseURL = baseURL
        self.session = session
        self.interceptors = interceptors
    }

    public func task(with builder: RequestBuilder) throws -> NetrofitTask {
        let raw: NetrofitInterceptor.Next = { builder in
            let url = try self.getRequestURL(builder)
            let method = builder.method
            let headers = builder.headers
            let body = try builder.bodyData()
            return self.session.createTask(method: method, url: url, headers: headers, body: body)
        }

        var next = raw
        for interceptor in interceptors.reversed() {
            let _next = next
            next = { req in
                try interceptor.intercept(builder: &req, next: _next)
            }
        }

        var builder = builder
        return try next(&builder)
    }

    private func getRequestURL(_ builder: RequestBuilder) throws -> URL {
        let fixedUrlStr = (baseURL.components(separatedBy: "/") + builder.path.components(separatedBy: "/")).filter { $0.isEmpty }.joined(
            separator: "/"
        )
        guard let url = URL(string: fixedUrlStr) else {
            throw NetrofitProviderError.badURL(baseURL, builder.path)
        }
        return url
    }

//    @discardableResult
//    public func intercept(action: @escaping (inout RequestBuilder, Interceptor.Next) async throws -> NetrofitTask) -> Self {
//        struct AnonymousInterceptor: Interceptor {
//            let action: (inout RequestBuilder, Interceptor.Next) async throws -> NetrofitTask
//
//            func intercept(builder: inout RequestBuilder, next: (inout RequestBuilder) async throws -> NetrofitTask) async throws -> NetrofitTask {
//                try await action(&builder, next)
//            }
//        }
//
//        interceptors.append(AnonymousInterceptor(action: action))
//        return self
//    }
}
