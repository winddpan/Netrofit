import CodableWrapper
import Foundation
import Netrofit

public struct User: Codable {
    let id: String
    let name: String
}

@API
@Headers(["token": "testn"])
public struct TestAPI {
    @GET("/group/{id}/users")
    func groupList(id: Int) async throws -> [User]

    @GET("/search")
    func searchUsers(@Query("q") keyword: String) async throws -> [User]

    @GET("/search")
    func searchUsersByTuple(@Query("q") keyword: String) async throws -> [(id: String, name: String)]
}

 let provider = Provider(baseURL: "https://www.github.com")
 Task {
    do {
        let resp = try await TestAPI(provider).searchUsersByTuple(keyword: "w")
    }
 }
