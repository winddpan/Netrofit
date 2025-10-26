@testable
import NetrofitMacros
import XCTest

final class MacroExpansionTests: XCTestCase {
    func testPath() {
//        assertMacro(["API": MethodMacro.self]) {
//            """
//            @GET("some/path")
//            func myQuery(id userId: String) async throws -> String
//            """
//        } expansion: {
//            """
//            protocol MyService {
//                @GET("some/path")
//                func myQuery(id userId: String) async throws -> String
//            }
//
//            struct MyServiceAPI: MyService {
//                private let provider: Papyrus.Provider
//
//                init(provider: Papyrus.Provider) {
//                    self.provider = provider
//                }
//
//                func myQuery(id userId: String) async throws -> String {
//                    var req = builder(method: "GET", path: "some/path")
//                    req.addQuery("userId", value: userId)
//                    let res = try await provider.request(&req)
//                    try res.validate()
//                    return try res.decode(String.self, using: req.responseBodyDecoder)
//                }
//
//                private func builder(method: String, path: String) -> Papyrus.RequestBuilder {
//                    provider.newBuilder(method: method, path: path)
//                }
//            }
//            """
//        }
    }
}
