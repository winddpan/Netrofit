import Foundation

public final class NetrofitProvider {
    public let baseURL: String
    public let session: NetrofitSession
    public var plugins: [NetrofitPlugin] = []

    public init(baseURL: String, session: NetrofitSession, plugins: [NetrofitPlugin] = []) {
        self.baseURL = baseURL
        self.session = session
        self.plugins = plugins
    }

    public func task(with builder: RequestBuilder) throws -> NetrofitTask {
        var builder = builder
        for plugin in plugins {
            try plugin.prepareRequest(&builder)
        }

        let url = try builder.fullURL(baseURL: baseURL)
        let headers = builder.fullHeaders()
        let body = try builder.bodyData()
        let method = builder.method

        return session.createTask(
            method: method,
            url: url,
            headers: headers,
            body: body,
            plugins: plugins
        )
    }
}
