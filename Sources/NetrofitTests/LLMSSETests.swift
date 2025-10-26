import Netrofit
import XCTest

private let provider = NetrofitProvider(baseURL: "https://open.bigmodel.cn")

struct Message: Codable {
    let role: String
    let content: String
}

@API
@Headers(["Authorization": "Bearer f6447b8b2b434dcbbd237ec8d7f56180.HXWdENeBbinRuuSP"])
struct LLMAPI {
    @POST("api/paas/v4/chat/completions")
    @EventStreaming
    func completions(model: String, messages: [Message], stream: Bool = true) async throws -> AsyncStream<String>
}

final class LLMSSETests: XCTestCase {
    let api = LLMAPI(provider)

    func testCompletions() async throws {
        let messages = [Message(role: "user", content: "hello, who are you?")]
        let stream = try await api.completions(model: "GLM-4.5-Flash", messages: messages)

        var matchKeyword = false
        for try await event in stream {
            print("Received event:", event)
            if event.contains("glm") {
                matchKeyword = true
            }
        }
        XCTAssertTrue(matchKeyword)
    }
}
