import Netrofit
import XCTest

let provider = NetrofitProvider(baseURL: "https://jsonplaceholder.typicode.com")

struct PostItem: Codable {
    let id: Int
    let userId: Int
    let title: String
    let body: String
}

struct CommentItem: Codable {
    let id: Int
    let postId: Int
    let name: String
    let email: String
    let body: String
}

@API
struct ExampleAPI {
    @GET("/posts")
    func posts() async throws -> [PostItem]

    @GET("/posts")
    func postsTuple() async throws -> [(id: Int, title: String)]

    @GET("/posts/{id}")
    func post(id: Int) async throws -> PostItem

    @GET("/posts/{id}")
    func postTuple(id: Int) async throws -> (id: Int, title: String)

    @GET("comments")
    @FormUrlEncoded
    func comment(postId: Int) async throws -> [(id: Int, name: String)]
}

final class RequestTests: XCTestCase {
    func testPosts() async throws {
        let resp = try await ExampleAPI(provider).posts()
        print(resp)

        let resp2 = try await ExampleAPI(provider).postsTuple()
        print(resp2)
    }

    func test1Post() async throws {
        let random = Int.random(in: 1 ... 100)
        let resp = try await ExampleAPI(provider).post(id: random)
        print(resp)

        let resp2 = try await ExampleAPI(provider).postTuple(id: random)
        print(resp2)
    }

    func test1Comment() async throws {
        let resp = try await ExampleAPI(provider).comment(postId: 1)
        print(resp)
    }
}
