import Netrofit

struct LogInterceptors: NetrofitPlugin {
    func prepareRequest(_ requestBuilder: inout RequestBuilder) throws {
        print("LogInterceptors Request", requestBuilder.path, requestBuilder.method)
    }

    func processResponse(_ response: NetrofitResponse) -> NetrofitResponse {
        print("LogInterceptors Response", response.statusCode ?? -1, response.request.url?.absoluteString ?? "", )
        return response
    }
}
