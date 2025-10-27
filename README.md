# Netrofit

A Swift version of Retrofit, inspired by Retrofit's API design and enhanced with Swift's type inference capabilities.
Automatically recognizes scenarios **without extra annotations**.

### Special Features
* Response KeyPath Parsing (nested)
* Tuple Returns (nested)
* Request and Response Interceptor
* SSE (Server-Sent Events)

### Example
```swift
@API
@Headers(["token": "Bearer JWT_TOKEN"])
struct UsersAPI {
    @GET("/user")
    func getUser(id: String) async throws -> User
    // GET /user?id=...

    @POST("/user")
    func createUser(email: String, password: String) async throws -> (id: String, name: String)
    // POST /user (body: {"email": String, "password": String}})

    @GET("/users/{username}/todos")
    @ResponseKeyPath("data.list")
    func getTodos(username: String) async throws -> [Todo]
    // GET /users/john/todos

    @POST("/chat/completions")
    @Headers(["Authorization": "Bearer ..."])
    @EventStreaming
    func completions(model: String, messages: [Message], stream: Bool = true) async throws -> AsyncStream<String>
    // POST /chat/completions (body: {"model": String, "messages": [Message], stream: true}})
}

let provider = Provider(baseURL: "https://www.example.com")
let api = UsersAPI(provider)

let resp = try await api.getUser(id: "john")
for await event in try await api.completions(model: "gpt-5", messages: ...) {
    print(event)
}

```

---
### Installation
Swift Package Manager

```
.package(url: "https://github.com/winddpan/Netrofit", from: "0.1.0")
```

```
.product(name: "Netrofit", package: "Netrofit")
```
---

### 1. Basic Request Methods

Supported HTTP methods:

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
func partialUpdateUser(id: Int, _ fields: [String: String]) async throws -> User
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

### 2. URL Path Parameters

- Parameters with the same name as `{placeholder}` in the URL are automatically mapped without annotation
- Use `@Path` to explicitly specify when parameter names differ

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

### 3. Query Parameters

- Simple type parameters are automatically mapped to query parameters (except those matched with @Path)
- Dictionary is automatically expanded to `&key=value`
- Use `@Query` to override parameter names or for non-GET requests like POST

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

- In POST/PUT/PATCH, unnamed parameters (parameter label is `_`) are automatically used as Body
- Use `@Body` to explicitly specify or for non-standard requests like GET

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

- In POST/PUT/PATCH, object parameters not used for `@Query`/`@Path`/`@Header`/`@Body` are automatically used as Body Fields
- Use `@Field` to explicitly specify field names or for non-standard requests like GET

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
// POST /users/new (form body: new_name=...&id=...})
```

---

### 6. JSON

- JSON is the default body encoding for `application/json`
- Supports custom encoder and decoder

```swift
@POST("/users/new")
func createUser(_ user: User) async throws -> User
// POST /users/new (json body: User)

@JSON
@POST("/users/new")
func createUser(id: String, name: String) async throws -> User
// POST /users/new (json body: {"id": String, "name": String})

// Supports custom encoder and decoder
@JSON(encoder: JSONEncoder(), decoder: DynamicContentTypeDecoder())
@POST("/data")
func createData(user: User) async throws -> User
// POST /data (json body: {"user": User})
```

---

### 7. Form-encoded

For `application/x-www-form-urlencoded`, supports custom encoder and decoder.

```swift
@FormUrlEncoded
@POST("/user/edit")
func updateUser(firstName: String, lastName: String) async throws -> User
// POST /user/edit (form body: firstName=...&lastName=...)

@FormUrlEncoded
@POST("/user/edit")
func updateUser(@Field("first") firstName: String, @Field("last") lastName: String) async throws -> User
// POST /user/edit (form body: first=...&last=...)

// Supports custom encoder and decoder
@FormUrlEncoded(encoder: URLEncodedFormEncoder(), decoder: JSONDecoder())
@POST("/form")
func submitForm(data: FormData) async throws
// POST /form (form body: ...=...&....=...&...=...)
```

---

### 8. Multipart

For file uploads or rich media content, supports custom encoder and decoder.

```swift
@Multipart
@PUT("/user/photo")
func updateUser(
    @Part(name: "photo", filename: "avatar.jpg", mimeType: "image/jpeg") photo: Data,
    @Part(name: "desc") description: String
) async throws -> User
// PUT /user/photo (multipart: photo, description)
// @Part supports custom name, filename, mimeType

// Supports custom encoder and decoder
@Multipart(encoder: MultipartEncoder(), decoder: JSONDecoder())
@POST("/upload")
func uploadFile(file: URL, meta: [String: String]) async throws -> UploadResponse
// POST /upload (multipart: file,meta)
```

---

### 9. Header Operations

#### Static Headers
```swift
@Headers([
    "Cache-Control": "max-age=640000",
    "Accept": "application/vnd.github.v3.full+json"
])
@GET("/users/{username}")
func getUser(username: String) async throws -> User
// GET /users/johne
```

#### Dynamic Headers
```swift
@GET("/user")
func getUser(@Header("Authorization") token: String) async throws -> User
// GET /user (header: {"Authorization": ...})

@GET("/user")
func getUser(@HeaderMap headers: [String: String]) async throws -> User
// GET /user (header {...})
```

---

### 10. Response KeyPath Parsing

Use `@ResponseKeyPath` to parse a KeyPath in JSON, supports multi-level nesting.

```swift
@GET("/users")
@ResponseKeyPath("data.list")
func listUsers() async throws -> [User]
// GET /users (response: {"data": {"list": [...]}})
```

---

### 11. Tuple Return Values (Including Multi-level Nesting)

Supports tuple return values with nested tuples. Tuple elements map response data in order.

```swift
@GET("/user")
func getUser(id: Int) async throws -> (id: String, name: String)
// GET /user?id=...

@GET("/users")
func getUserList() async throws -> (list: [(id: String, name: String)], count: Int)
// GET /users
```

---

### 12. EventStreaming (AsyncStream)

- `@EventStreaming` is for Server-Sent Events continuous streaming scenarios
- Returns `AsyncStream` or `AsyncThrowingStream`, consume events with `for await`

```swift
@EventStreaming
@GET("/events/stream")
func listenEvents(roomID: String) async throws -> AsyncStream<String>
// GET /events/stream?roomID=... continuous event streaming

@EventStreaming
@GET("/events/stream")
func listenEventsThrowing(roomID: String) async throws -> AsyncThrowingStream<String, Error>
// GET /events/stream?roomID=... continuous event streaming

for await event in try await api.listenEvents(roomID: "chat") {
    print("Received event:", event)
}
```

---

### 13. Auto-Inference Rules

1. **Automatic Path Parameter Matching**
   - `{placeholder}` in URL paths automatically matches parameters with the same name
   - Only need explicit `@Path` when names don't match

2. **Automatic Query Parameter Inference**
   - Except for Path parameters, simple types (String, Int, Bool, etc.) are automatically mapped to query parameters
   - Dictionary is automatically expanded to multiple query items

3. **Automatic Field Parameter Inference**
   - In `@FormUrlEncoded` methods, basic type parameters are automatically mapped to form fields
   - Parameter name is used as field name unless `@Field` specifies an alias
   - In POST/PUT/PATCH, object parameters not used for `@Query`/`@Path`/`@Header`/`@Body` are automatically used as Body Fields

4. **Automatic Body Parameter Inference**
   - In POST/PUT/PATCH, unnamed parameters (parameter label is `_`) are automatically used as Body

5. **Default Encoding Rules**
   - JSON (`application/json`) is the default body encoding
   - URL Encoding is the default query parameter encoding


---

### 14. Additional Support

- **TODO: Async & Combine**: Supports `async/await` and `Publisher`
- **Global Interceptors**: Supports registering header, logging, and auth interceptors

---

## Acknowledgements

Heavily inspired by [Rapyrus](https://github.com/joshuawright11/papyrus), [Retrofit](https://github.com/square/retrofit).
