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

@API
struct JSONTest {
    @POST("/users/new")
    func createUser(_ user: User) async throws -> User
    // POST /users/new (json body: User)

    @POST("/users/new")
    @JSON
    func createUser(id: String, name: String) async throws -> User
    // POST /users/new (json body: {"id": String, "name": String})

    // 支持自定义 encoder 和 decoder
    @POST("/data")
    @JSON(encoder: JSONEncoder(), decoder: JSONDecoder())
    func createUser(user: User) async throws -> User
    // POST /users/new (json body: {"user": User})
}

@API
struct FormUrlEncodedTest {
    @FormUrlEncoded
    @POST("/user/edit")
    func updateUser(firstName: String, lastName: String) async throws -> User
    // POST /user/edit (form body: firstName=...&lastName=...)

    @FormUrlEncoded
    @POST("/user/edit")
    func updateUser2(@Field("first") firstName: String, @Field("last") lastName: String) async throws -> User
    // POST /user/edit (form body: first=...&last=...)

    class MyURLEncodedFormEncoder: URLEncodedFormEncoder {}
    class MyURLEncodedFormDecoder: URLEncodedFormDecoder {}

    // 支持自定义 encoder 和 decoder
    @FormUrlEncoded(encoder: MyURLEncodedFormEncoder(), decoder: MyURLEncodedFormDecoder())
    @POST("/form")
    func submitForm3(data: User) async throws
    // POST /form (form body: ...=...&....=...&...=...)
}

@API
@Multipart
struct MultipartTest {
    @Multipart
    @PUT("/user/photo")
    func updateUser(
        @Part(name: "photoName", filename: "avatar.jpg", mimeType: "image/jpeg") photo: Data,
        @Part(name: "desc") description: String
    ) async throws -> User
    // PUT /user/photo (multipart: photo,description)
    // @Part 支持自定义 name、filename、mimeType。

    @PUT("/user/photo")
    func updateUser2(
        photo: Data,
        description: String
    ) async throws -> User
    // PUT /user/photo (multipart: photo,description)
    // @Part 支持自定义 name、filename、mimeType。

    // 支持自定义 encoder 和 decoder
    @Multipart(encoder: MultipartEncoder(), decoder: MultipartDecoder())
    @POST("/upload")
    func uploadFile(file: URL, meta: [String: String]) async throws
    // POST /upload (multipart: file,meta)
}

@API
@Headers([
    "Cache-Control": "max-age=140000",
])
struct HeaderTest {
    static let varHeaders = [
        "Cache-Control": "max-age=640000",
        "Accept": "application/vnd.github.v3.full+json",
    ]

    @Headers(HeaderTest.varHeaders)
    @GET("/users/{username}")
    func getUser(username: String) async throws -> User

    @GET("/user")
    func getUser(@Header("Authorization") token: String?) async throws -> User
    // GET /user (header: {"Authorization": ...})

    @GET("/user")
    func getUser2(@Header token: String, @Header name: String, age: Int?) async throws -> User
    // GET /user (header: {"token": ...})

    @GET("/user")
    func getUser(@HeaderMap headers: [String: String]?) async throws -> User
    // GET /user (header {...})
}

@API
struct ResponseKeyPathTest {
    @ResponseKeyPath("data.list")
    @GET("/users")
    func listUsers() async throws -> [User]
    // GET /users (response key path: data.list)
}
