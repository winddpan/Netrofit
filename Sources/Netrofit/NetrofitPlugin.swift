import Foundation

public protocol NetrofitPlugin {
    func prepareRequest(_ requestBuilder: inout RequestBuilder) throws

    func processResponse(_ response: NetrofitResponse) -> NetrofitResponse
}
