import Foundation

public protocol NetrofitPlugin: Sendable {
    func prepareRequest(_ requestBuilder: inout RequestBuilder) throws

    func processResponse(_ response: NetrofitResponse) -> NetrofitResponse
}
