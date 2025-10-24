import CodableWrapper
import Foundation
import Netrofit

public struct UserModel: Codable {
    let id: String
    let name: String
}

@API
@Headers(["token": "a"])
@FormUrlEncoded
public struct GitHubAPI {
    @GET("123")
    @Headers(["a": "213", "b": "12"])
    public func user1(id: String = "winddpan") async throws -> UserModel

    @GET("123")
    @Headers(["a": "213", "b": "12"])
    public func user2(id: String = "winddpan") async throws -> (id: String?, name: String)

    @GET("123")
    @Headers(["a": "213", "b": "12"])
    public func user3(@Path id: String = "winddpan") async throws -> (id: String?, name: String)
}

let provider = Provider(baseURL: "https://www.github.com")

Task {
    do {
        let resp = try await GitHubAPI(provider).user2()
        resp.id
    }
}

typealias User = (id: String, name: String)
typealias Obj = (list: [(id: String, name: String)])
