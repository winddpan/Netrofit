# Netrofit

Swift 版本 Retrofit，参考 Retrofit API 设计，结合 Swift 的类型推断能力，
自动识别的场景**无需额外注解**，并增强 Swift 专属特性（tuple 返回、嵌套 tuple）。
支持SSE。

```swift
@API
@Headers(["token": "Bearer JWT_TOKEN"])
struct UsersAPI {
    @GET("/user")
    func getUser(@Query("identifier") id: String) async throws -> User
    // GET /user?identifier=...

    @POST("/user")
    func createUser(email: String, password: String) async throws -> (id: String, name: String)
    // POST /user (body: {"email": String, "password": String}})

    @GET("/users/{username}/todos")
    func getTodos(username: String) async throws -> [Todo]
    // GET /users/johne/todos

    @POST("/chat/completions")
    @EventStreaming
    @Headers(["Authorization": "Bearer ..."])
    func completions(model: String, messages: [Message], stream: Bool = true) async throws -> AsyncStream<String>
}

let provider = Provider(baseURL: "https://www.example.com")
let resp = try await UsersAPI(provider).getUser(id: "johne")

```

---

### 1. 基本请求方法

支持的 HTTP 方法：

```swift
@GET("/users/list")
func listUsers() async throws -> [User]
// GET /users/list

@POST("/users/new")
func createUser(_ user: User) async throws -> User
// POST /users/new (body: User)

@PUT("/users/{id}")
func updateUser(id: Int, _ user: User) async throws -> User
// PUT /users/{id} (body: User)

@PATCH("/users/{id}")
func partialUpdateUser(id: Int, _ fields: [String: Any]) async throws -> User
// PATCH /users/{id} (body: fields)

@DELETE("/users/{id}")
func deleteUser(id: Int) async throws -> Void
// DELETE /users/{id}

@OPTIONS("/meta")
func options() async throws -> MetaInfo
// OPTIONS /meta

@HEAD("/resource/{id}")
func checkResource(id: Int) async throws -> HTTPHeaders
// HEAD /resource/{id}
```

---

### 2. URL 路径参数

- 参数名与 URL 中 `{placeholder}` 相同时，自动映射，无需标注
- 参数名不同时，使用 `@Path` 显式指定

```swift
@GET("/group/{id}/users")
func groupList(id: Int) async throws -> [User]
// GET /group/{id}/users

@GET("/group/{gid}/users")
func groupList(@Path("gid") gid: Int) async throws -> [User]
// GET /group/{gid}/users

@GET("/group/{gid}/users")
func groupList(@Path("gid") groupId: Int) async throws -> [User]
// GET /group/{gid}/users

@GET("/group/{gid}/users")
func groupList(@Path(encoded: true) gid: Int) async throws -> [User]
// GET /group/{gid}/users

@GET("/group/{gid}/users")
func groupList(@Path("gid", encoded: true) groupId: Int) async throws -> [User]
// GET /group/{gid}/users
```

---

### 3. Query 参数

- 简单类型参数自动映射为 query 参数（已匹配 @Path 的除外）
- Dictionary 自动展开为 `&key=value`
- 使用 `@Query` 可覆盖参数名或用于 POST 等非 GET 请求

```swift
@GET("/transactions")
func getTransactions(merchant: String) async throws -> [Transaction]
// GET /transactions?merchant=...

@GET("/group/{id}/users")
func groupList(id: Int, sort: String) async throws -> [User]
// GET /group/42/users?sort=...

@GET("/search")
func searchUsers(filters: [String: String]) async throws -> [User]
// GET /search?name=...&age=...

@GET("/search")
func searchUsers(keyword: String) async throws -> [User]
// GET /search?keyword=...

@GET("/search")
func searchUsers(q keyword: String) async throws -> [User]
// GET /search?q=...

@GET("/search")
func searchUsers(@Query("q") keyword: String) async throws -> [User]
// GET /search?q=...

@GET("/search")
func searchUsers(@Query(encoded: true) keyword: String) async throws -> [User]
// GET /search?q=...

@POST("/search")
func searchUsers(@Query("q", encoded: true) keyword: String) async throws -> [User]
// POST /search?q=...
```

---

### 4. Request Body

- POST/PUT/PATCH 中，未命名参数（参数标签为 `_`）自动作为 Body
- 使用 `@Body` 可显式指定或用于 GET 等非标准请求

```swift
@POST("/users/new")
func createUser(_ user: User) async throws -> User
// POST /users/new (body: User)

@POST("/items")
func addItem(item: Item, @Query("notify") notify: Bool) async throws -> Item
// POST /items?notify=true (body: {"item": Item})

@POST("/items")
func addItem(@Body item: Item, @Query("notify") notify: Bool) async throws -> Item
// POST /items?notify=true (body: Item)
```

---

### 5. Field

- POST/PUT/PATCH 中，除已用于 `@Query`/`@Path`/`@Header`/`@Body` 的参数外，对象参数自动作为 Body Field
- 使用 `@Field` 可显式指定字段名或用于 GET 等非标准请求

```swift
@POST("/users/new")
func createUser(user: User) async throws -> User
// POST /users/new (body: {"user": User})

@POST("/users/new")
func createUser(name: String, id: String) async throws -> User
// POST /users/new (body: {"name": String, "id": String})

@POST("/users/new")
func createUser(@Field("new_name") name: String, id: String) async throws -> User
// POST /users/new (body: {"new_name": String, "id": String})


@POST("/users/new")
@FormUrlEncoded
func createUser(@Field("new_name") name: String, id: String) async throws -> User
// POST /users/new (form body: {"new_name": String, "id": String})
```

---

### 6. JSON

- JSON 为默认 body 编码，适用于 `application/json`
- 支持自定义 encoder 和 decoder

```swift
@POST("/users/new")
func createUser(_ user: User) async throws -> User
// POST /users/new (json body: User)

@JSON
@POST("/users/new")
func createUser(id: String, name: String) async throws -> User
// POST /users/new (json body: {"id": String, "name": String})

// 支持自定义 encoder 和 decoder
@JSON(encoder: JSONEncoder(), decoder: DynamicContentTypeDecoder())
@POST("/data")
func createData(user: User) async throws -> User
// POST /data (json body: {"user": User})
```

---

### 7. Form-encoded

适用于 `application/x-www-form-urlencoded`，支持自定义 encoder 和 decoder。

```swift
@FormUrlEncoded
@POST("/user/edit")
func updateUser(firstName: String, lastName: String) async throws -> User
// POST /user/edit (form body: firstName=...&lastName=...)

@FormUrlEncoded
@POST("/user/edit")
func updateUser(@Field("first") firstName: String, @Field("last") lastName: String) async throws -> User
// POST /user/edit (form body: first=...&last=...)

// 支持自定义 encoder 和 decoder
@FormUrlEncoded(encoder: URLEncodedFormEncoder(), decoder: JSONDecoder())
@POST("/form")
func submitForm(data: FormData) async throws
// POST /form (form body: ...=...&....=...&...=...)
```

---

### 8. Multipart

适用于文件上传或富媒体内容，支持自定义 encoder 和 decoder。

```swift
@Multipart
@PUT("/user/photo")
func updateUser(
    @Part(name: "photo", filename: "avatar.jpg", mimeType: "image/jpeg") photo: Data,
    @Part(name: "desc") description: String
) async throws -> User
// PUT /user/photo (multipart: photo, description)
// @Part 支持自定义 name、filename、mimeType

// 支持自定义 encoder 和 decoder
@Multipart(encoder: MultipartEncoder(), decoder: JSONDecoder())
@POST("/upload")
func uploadFile(file: URL, meta: [String: String]) async throws -> UploadResponse
// POST /upload (multipart: file,meta)
```

---

### 9. Header 操作

#### 静态 Header
```swift
@Headers([
    "Cache-Control": "max-age=640000",
    "Accept": "application/vnd.github.v3.full+json"
])
@GET("/users/{username}")
func getUser(username: String) async throws -> User
// GET /users/johne
```

#### 动态 Header
```swift
@GET("/user")
func getUser(@Header("Authorization") token: String) async throws -> User
// GET /user (header: {"Authorization": ...})

@GET("/user")
func getUser(@HeaderMap headers: [String: String]) async throws -> User
// GET /user (header {...})
```

---

### 10. 返回值解析 KeyPath

使用 `@ResponseKeyPath` 可解析 JSON 中的 KeyPath，支持多级嵌套。

```swift
@GET("/users")
@ResponseKeyPath("data.list")
func listUsers() async throws -> [User]
// GET /users (response key path: data.list)
```

---

### 11. 返回值支持 tuple（包括多级嵌套）

支持返回值为 tuple，tuple 可嵌套。tuple 元素按顺序映射响应数据部分。

```swift
@GET("/user")
func getUser(id: Int) async throws -> (id: String, name: String)
// GET /user?id=...

@GET("/users")
func getUserList() async throws -> (list: [(id: String, name: String)], count: Int)
// GET /users
```

---

### 12. EventStreaming（AsyncStream）

- `@EventStreaming` 用于 Server-Sent Events 持续推送的场景
- 返回 `AsyncStream` 或 `AsyncThrowingStream`，配合 `for await` 逐条消费事件

```swift
@EventStreaming
@GET("/events/stream")
func listenEvents(roomID: String) async throws -> AsyncStream<String>
// GET /events/stream?roomID=... 持续推送 Event

@EventStreaming
@GET("/events/stream")
func listenEventsThrowing(roomID: String) async throws -> AsyncThrowingStream<String, Error>
// GET /events/stream?roomID=... 持续推送 Event

for await event in try await api.listenEvents(roomID: "chat") {
    print("收到事件:", event)
}
```

---

### 13. 自动推断规则

1. **Path 参数自动匹配**
   - URL 路径中的 `{placeholder}` 自动匹配同名参数
   - 仅在不匹配时需显式使用 `@Path`

2. **Query 参数自动推断**
   - 除 Path 参数外，简单类型（String、Int、Bool 等）自动映射为 query 参数
   - Dictionary 自动展开为多个 query 项

3. **Field 参数自动推断**
   - `@FormUrlEncoded` 方法中，基础类型参数自动映射为表单字段
   - 参数名作为字段名，除非使用 `@Field` 指定别名
   - POST/PUT/PATCH 中，除已用于 `@Query`/`@Path`/`@Header`/`@Body` 的参数外，对象参数自动作为 Body Field

4. **Body 参数自动推断**
   - POST/PUT/PATCH 中，未命名参数（参数标签为 `_`）自动作为 Body

5. **默认编码规则**
   - JSON（`application/json`）为默认 body 编码
   - URL Encoding 为默认 query 参数编码


---

### 14. 额外支持

- **TODO: Async & Combine**：支持 `async/await` 和 `Publisher`
- **Global Interceptors**：支持注册 header、logging、auth 拦截器

---

## Acknowledgements

Heavily inspired by [Rapyrus](https://github.com/joshuawright11/papyrus), [Retrofit](https://github.com/square/retrofit).
