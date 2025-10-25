import Foundation
import Netrofit

public struct Group: Codable {
    let id: String
    let name: String
}

public struct User: Codable {
    let id: String
    let name: String
}

@API
struct PathTest {
    @GET("/group/{id}/users")
    func groupList1(id: Int) async throws -> [User]
    // GET /group/{id}/users

    @GET("/group/{gid}/users")
    func groupList2(@Path("gid") gid: Int) async throws -> [User]
    // GET /group/{gid}/users

    @GET("/group/{gid}/users")
    func groupList3(@Path("gid") groupId: Int) async throws -> [User]
    // GET /group/{gid}/users

    @GET("/group/{gid}/users")
    func groupList4(@Path(encoded: true) gid: Int) async throws -> [User]
    // GET /group/{gid}/users

    @GET("/group/{gid}/users")
    func groupList5(@Path("gid", encoded: true) groupId: Int) async throws -> [User]
    // GET /group/{gid}/users
}

@API
struct QueryTest {
    @GET("/group")
    func groupList(id: String) async throws -> [Group]
    // GET /group?id=...

    @GET("/group/{id}/users")
    func groupList(id: Int, sort: String) async throws -> [User]
    // GET /group/42/users?sort=...

    @GET("/search")
    func searchUsers(filters: [String: String]) async throws -> [User]
    // GET /search?name=...&age=...

    @GET("/search")
    func searchUsers(@Query("q") keyword: String, two: Int?) async throws -> [User]
    // GET /search?q=...

    @GET("/search")
    func searchUsers2(@Query(encoded: true) keyword: String) async throws -> [User]
    // GET /search?q=...

    @GET("/search")
    func searchUsers3(@Query("q", encoded: true) keyword: String) async throws -> [User]
    // GET /search?q=...

    @POST("/search")
    @DecodePath("data.list")
    func searchUsers4(@Query(encoded: true) keyword: String) async throws -> [User]
    // GET /search?q=...
}

@API
struct BodyTest {
    @POST("/users/new")
    func createUser(name: String, id: String) async throws -> User
    // POST /users/new (body: {"name": ..., "id": ...})

    @POST("/users/new")
    func createUser(_ user: User) async throws -> User
    // POST /users/new (body: {"name": ..., "id": ...})

    @POST("/users/new")
    func createUser(user: User) async throws -> User
    // POST /users/new (body: {"user": {"name": ..., "id": ...}}})

    @POST("/items")
    func addItem(@Body user: User, @Query("notify") notify: Bool = true) async throws -> User
    // POST /items?notify=true (body: {"name": ..., "id": ...})
}

@API
struct FieldTest {
    @POST("/users/new")
    func createUser(user: User) async throws -> User
    // POST /users/new (body: {"user": User})

    @POST("/users/new")
    func createUser(name: String, id: String) async throws -> User
    // POST /users/new (body: {"name": ..., "id": ...})

    @POST("/users/new")
    func createUser2(@Field("new_name") name: String, id: String) async throws -> User
    // POST /users/new (body: {"n": ..., "id": ...})

    @POST("/users/new")
    @FormUrlEncoded
    func createUser3(@Field("new_name") name: String, id: String) async throws -> User
    // POST /users/new (body: {"n": ..., "id": ...})
}
