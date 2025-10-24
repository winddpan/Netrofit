# Netrofit

> Swift 版本 Retrofit，参考 Retrofit Java API，结合 Swift 的自动推断能力，
> 对可以自动识别的场景**不要求额外注解**，同时增强了 Swift 专属特性（tuple 返回、嵌套 tuple）。

---

### 1. 基本请求方法

支持的 HTTP 方法注解：

```swift
@GET("/users/list")
func listUsers() async throws -> [User]

@POST("/users/new")
func createUser(_ user: User) async throws -> User

@PUT("/users/{id}")
func updateUser(id: Int, _ user: User) async throws -> User

@PATCH("/users/{id}")
func partialUpdateUser(id: Int, _ fields: [String: Any]) async throws -> User

@DELETE("/users/{id}")
func deleteUser(id: Int) async throws -> Void

@OPTIONS("/meta")
func options() async throws -> MetaInfo

@HEAD("/resource/{id}")
func checkResource(id: Int) async throws -> HTTPHeaders
```

---

### 2. URL 路径参数

- 自动推断：方法参数名与 URL 中 `{placeholder}` 对应时，不需要额外标注。
- 如果参数名不同，则使用 `@Path` 指定。

```swift
@GET("/group/{id}/users")
func groupList(id: Int) async throws -> [User]

@GET("/group/{gid}/users")
func groupList(@Path("gid") groupId: Int) async throws -> [User]
```

---

### 3. Query 参数

- 自动推断：简单类型方法参数 → 自动映射为 query 参数（除非已匹配 @Path）。
- Map / Dictionary 自动展开为 `&key=value`。
- 支持显式 `@Query` 仅用于覆盖自动推断的名字或编码规则。

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
func searchUsers(@Query("q") keyword: String) async throws -> [User]
// GET /search?q=...
```

---

### 4. Request Body

- 除仅用于 query/path/header 的基础类型，其他对象参数会自动作为 Body。
- 显式 `@Body` 可用于区分多个对象参数的含义。

```swift
@POST("/users/new")
func createUser(_ user: User) async throws -> User

@POST("/items")
func addItem(@Body item: Item, @Query("notify") notify: Bool) async throws -> Item
```

---

### 5. JSON

适用于 `application/json`。

```swift
@JSON
@POST("/users/new")
func createUser(_ user: User) async throws -> User

// 支持自定义 encoder 和 decoder
@JSON(encoder: JSONEncoder(), decoder: JSONDecoder())
@POST("/data")
func processData(_ data: ComplexData) async throws -> Response
```

---

### 6. Form-encoded

适用于 `application/x-www-form-urlencoded`。

```swift
@FormUrlEncoded
@POST("/user/edit")
func updateUser(firstName: String, lastName: String) async throws -> User

// 支持自定义 encoder 和 decoder
@FormUrlEncoded(encoder: URLEncodedFormEncoder(), decoder: URLEncodedFormDecoder())
@POST("/form")
func submitForm(data: FormData) async throws -> Response
```

---

### 7. Multipart

适用于文件上传或富媒体内容。

```swift
@Multipart
@PUT("/user/photo")
func updateUser(photo: Data, description: String) async throws -> User

// 支持自定义 encoder 和 decoder
@Multipart(encoder: MultipartEncoder(), decoder: MultipartDecoder())
@POST("/upload")
func uploadFile(file: URL, meta: [String: String]) async throws -> UploadResponse
```

---

### 8. Header 操作

#### 静态 Header
```swift
@Headers([
    "Cache-Control": "max-age=640000",
    "Accept": "application/vnd.github.v3.full+json"
])
@GET("/users/{username}")
func getUser(username: String) async throws -> User
```

#### 动态 Header
```swift
@GET("/user")
func getUser(@Header("Authorization") token: String) async throws -> User

@GET("/user")
func getUser(@HeaderMap headers: [String: String]) async throws -> User
```

---

### 9. 自动推断规则（Swift 特性）

1. **Path 参数自动匹配规则**  
   - URL 路径中的 `{placeholder}` 会自动匹配同名参数。
   - 仅在不匹配时需要显式 `@Path`。

2. **Query 参数自动推断规则**  
   - 除 Path 参数外，非对象类型（String, Int, Bool 等）会自动映射为 query 参数。
   - `Dictionary` 会被展开为多个 query 项。

3. **Body 参数自动推断规则**  
   - 除 Query/Path/Header 外的非基础类型对象自动作为 Body。
   - 多个对象参数时需使用 `@Body` 区分。

4. **默认编码规则**  
   - JSON 为默认 body 编码（可选自定义 Converter）。
   - URL Encoding 为默认 query 参数编码。

---

### 10.  返回值解析 KeyPath

`@ResponseKeyPath` 可以解析JSON中的KeyPath，支持多级嵌套。

```swift
@GET("/users")
@ResponseKeyPath("data.list")
func listUsers() async throws -> [User]
```

---

### 11. 返回值支持 tuple（包括嵌套 tuple）

 支持返回值为 tuple，且 tuple 可以嵌套。  
每个 tuple 元素会按顺序映射对应的响应数据部分（例如通过多分部解析器或批量请求返回）。

```swift
@GET("/user")
func getUser(id: Int) async throws -> (id: String, name: String)

@GET("/user-list")
func getUserList() async throws -> (list: [(id: String, name: String)], count: Int)
```

---

### 12. 额外支持（Retrofit 文档未重点提到）

- **默认方法**：无注解则默认为 `application/json`。
- **Generic Response**：支持泛型封装，如 `Response<T>`。
- **Async & Combine**：既支持 `async/await`，也可返回 `Publisher`。
- **Global Interceptors**：可在 `RetrofitSwift` 实例注册 header、logging、auth 拦截器。
- **Custom Converter**：支持 XML、ProtoBuf 等自定义序列化。
- **Mock Support**：内置 MockAdapter，可用于测试。

---

我已经把 **tuple 返回值** 和 **@HeaderMap** 支持补充到你的 Swift 版本 Retrofit 规范里。  
如果你希望，我可以在下一步帮你画一张 **API 调用声明解析优先级图**，把 Path → Query → Body → Header 检测流程和 tuple 解析顺序全部可视化，这样你就可以为你的 Swift 框架直接实现一个解析器。  

✅ 要帮你画这张优先级流程图吗？这样你就能一目了然知道每个参数会怎么被映射。
## Acknowledgements

Heavily inspired by [Rapyrus](https://github.com/joshuawright11/papyrus), [Retrofit](https://github.com/square/retrofit).
