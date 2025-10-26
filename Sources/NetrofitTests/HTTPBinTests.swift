import Netrofit
import XCTest

private let httpbinProvider = NetrofitProvider(baseURL: "https://httpbin.org")

// MARK: - HTTPBin Response Models

struct HTTPBinGetResponse: Codable {
    let args: [String: String]
    let headers: [String: String]
    let origin: String
    let url: String
}

struct HTTPBinPostResponse: Codable {
    let args: [String: String]?
    let data: String?
    let files: [String: String]?
    let form: [String: String]?
    let json: [String: AnyCodable]?
    let headers: [String: String]
    let origin: String
    let url: String
}

struct HTTPBinHeadersResponse: Codable {
    let headers: [String: String]
}

struct HTTPBinUUIDResponse: Codable {
    let uuid: String
}

struct HTTPBinIPResponse: Codable {
    let origin: String
}

struct HTTPBinUserAgentResponse: Codable {
    let userAgent: String

    enum CodingKeys: String, CodingKey {
        case userAgent = "user-agent"
    }
}

struct HTTPBinStreamResponse: Codable {
    let id: Int
    let url: String
}

// MARK: - HTTPBin Test API

@API
struct HTTPBinAPI {
    // MARK: - Basic HTTP Methods

    /// Test GET request with query parameters
    @GET("/get")
    func get(param1: String, param2: Int) async throws -> HTTPBinGetResponse

    /// Test GET request with query parameter name override
    @GET("/get")
    func getWithQueryOverride(@Query("custom_name") value: String) async throws -> HTTPBinGetResponse

    /// Test POST request with JSON body
    @POST("/post")
    func postJSON(_ body: [String: String]) async throws -> HTTPBinPostResponse

    /// Test POST request with fields (auto-inferred)
    @POST("/post")
    func postFields(name: String, age: Int, email: String) async throws -> HTTPBinPostResponse

    /// Test PUT request with body
    @PUT("/put")
    func put(_ data: [String: String]) async throws -> HTTPBinPostResponse

    /// Test PATCH request
    @PATCH("/patch")
    func patch(field: String, value: String) async throws -> HTTPBinPostResponse

    /// Test DELETE request
    @DELETE("/delete")
    func delete(id: String) async throws -> HTTPBinPostResponse

    // MARK: - Path Parameters

    /// Test path parameter (auto-matched by name)
    @GET("/anything/{id}")
    func anythingWithId(id: String) async throws -> HTTPBinPostResponse

    /// Test path parameter with custom name
    @GET("/anything/{user_id}")
    func anythingWithUserId(@Path("user_id") userId: String) async throws -> HTTPBinPostResponse

    /// Test multiple path parameters
    @GET("/anything/{category}/{item}")
    func anythingWithMultiplePaths(category: String, item: String) async throws -> HTTPBinPostResponse

    // MARK: - Headers

    /// Test static headers
    @Headers([
        "X-Custom-Header": "CustomValue",
        "X-API-Version": "1.0",
    ])
    @GET("/headers")
    func headersStatic() async throws -> HTTPBinHeadersResponse

    /// Test dynamic header
    @GET("/headers")
    func headersDynamic(@Header("X-Auth-Token") token: String) async throws -> HTTPBinHeadersResponse

    /// Test header map
    @GET("/headers")
    func headersMap(@HeaderMap headers: [String: String]) async throws -> HTTPBinHeadersResponse

    /// Test User-Agent
    @GET("/user-agent")
    func userAgent() async throws -> HTTPBinUserAgentResponse

    // MARK: - Form URL Encoded

    /// Test form-encoded POST
    @FormUrlEncoded
    @POST("/post")
    func postForm(username: String, password: String) async throws -> HTTPBinPostResponse

    /// Test form-encoded with field name override
    @FormUrlEncoded
    @POST("/post")
    func postFormWithFieldOverride(
        @Field("user") username: String,
        @Field("pass") password: String
    ) async throws -> HTTPBinPostResponse

    // MARK: - Response Parsing

    /// Test UUID endpoint
    @GET("/uuid")
    func uuid() async throws -> HTTPBinUUIDResponse

    /// Test IP endpoint
    @GET("/ip")
    func ip() async throws -> HTTPBinIPResponse

    /// Test tuple return type
    @GET("/uuid")
    func uuidTuple() async throws -> (uuid: String, dummy: Int?)

    // MARK: - Query Parameters

    /// Test dictionary expansion to query params
    @GET("/get")
    func getWithDictionary(filters: [String: String]) async throws -> HTTPBinGetResponse

    /// Test mixed query and path parameters
    @GET("/anything/{id}")
    func anythingMixed(id: String, sort: String, limit: Int) async throws -> HTTPBinPostResponse

    // MARK: - EventStreaming

    /// Test streaming endpoint
    @EventStreaming
    @GET("/stream/{count}")
    func stream(count: Int) async throws -> AsyncThrowingStream<HTTPBinStreamResponse, Error>

    // MARK: - Encoded Parameters

    /// Test encoded path parameter
    @GET("/anything/{value}")
    func anythingEncoded(@Path(encoded: true) value: String) async throws -> HTTPBinPostResponse

    /// Test encoded query parameter
    @GET("/get")
    func getEncoded(@Query(encoded: true) text: String) async throws -> HTTPBinGetResponse

    @PUT("/anything")
    @Multipart
    func upload(title: String, text: String) async throws -> String
}

// MARK: - Test Cases

final class HTTPBinTests: XCTestCase {
    let api = HTTPBinAPI(httpbinProvider)

    func testHTTPBinGET() async throws {
        let resp = try await api.get(param1: "value1", param2: 42)
        print("GET response:", resp)

        XCTAssertEqual(resp.args["param1"], "value1")
        XCTAssertEqual(resp.args["param2"], "42")
        XCTAssertTrue(resp.url.contains("param1=value1"))
        XCTAssertTrue(resp.url.contains("param2=42"))
    }

    func testHTTPBinGETWithQueryOverride() async throws {
        let resp = try await api.getWithQueryOverride(value: "test_value")
        print("GET with query override:", resp)

        XCTAssertEqual(resp.args["custom_name"], "test_value")
        XCTAssertTrue(resp.url.contains("custom_name=test_value"))
    }

    func testHTTPBinPOSTJSON() async throws {
        let body = ["key1": "value1", "key2": "value2"]
        let resp = try await api.postJSON(body)
        print("POST JSON response:", resp)

        XCTAssertNotNil(resp.json)
        XCTAssertTrue(resp.headers["Content-Type"]?.contains("application/json") ?? false)
    }

    func testHTTPBinPOSTFields() async throws {
        let resp = try await api.postFields(name: "John", age: 30, email: "john@example.com")
        print("POST fields response:", resp)

        XCTAssertNotNil(resp.json)
    }

    func testHTTPBinPUT() async throws {
        let data = ["status": "updated", "version": "2.0"]
        let resp = try await api.put(data)
        print("PUT response:", resp)

        XCTAssertNotNil(resp.json)
    }

    func testHTTPBinPATCH() async throws {
        let resp = try await api.patch(field: "status", value: "patched")
        print("PATCH response:", resp)

        XCTAssertNotNil(resp.json)
    }

    func testHTTPBinDELETE() async throws {
        let resp = try await api.delete(id: "123")
        print("DELETE response:", resp)

        XCTAssertEqual(resp.args?["id"], "123")
    }

    // MARK: - Path Parameters Tests

    func testHTTPBinPathParameter() async throws {
        let resp = try await api.anythingWithId(id: "test123")
        print("Path parameter response:", resp)

        XCTAssertTrue(resp.url.contains("/anything/test123"))
    }

    func testHTTPBinPathParameterWithOverride() async throws {
        let resp = try await api.anythingWithUserId(userId: "user456")
        print("Path parameter override response:", resp)

        XCTAssertTrue(resp.url.contains("/anything/user456"))
    }

    func testHTTPBinMultiplePathParameters() async throws {
        let resp = try await api.anythingWithMultiplePaths(category: "electronics", item: "laptop")
        print("Multiple path parameters response:", resp)

        XCTAssertTrue(resp.url.contains("/anything/electronics/laptop"))
    }

    // MARK: - Headers Tests

    func testHTTPBinStaticHeaders() async throws {
        let resp = try await api.headersStatic()
        print("Static headers response:", resp)

        XCTAssertEqual(resp.headers["X-Custom-Header"], "CustomValue")
        XCTAssertEqual(resp.headers["X-Api-Version"], "1.0")
    }

    func testHTTPBinDynamicHeader() async throws {
        let resp = try await api.headersDynamic(token: "secret_token_123")
        print("Dynamic header response:", resp)

        XCTAssertEqual(resp.headers["X-Auth-Token"], "secret_token_123")
    }

    func testHTTPBinHeaderMap() async throws {
        let customHeaders = [
            "X-Session-Id": "session-456",
        ]
        let resp = try await api.headersMap(headers: customHeaders)
        print("Header map response:", resp)

        XCTAssertEqual(resp.headers["X-Session-Id"], "session-456")
    }

    func testHTTPBinUserAgent() async throws {
        let resp = try await api.userAgent()
        print("User-Agent response:", resp)

        XCTAssertFalse(resp.userAgent.isEmpty)
    }

    // MARK: - Form URL Encoded Tests

    func testHTTPBinFormEncoded() async throws {
        let resp = try await api.postForm(username: "testuser", password: "testpass")
        print("Form encoded response:", resp)

        XCTAssertEqual(resp.form?["username"], "testuser")
        XCTAssertEqual(resp.form?["password"], "testpass")
    }

    func testHTTPBinFormEncodedWithFieldOverride() async throws {
        let resp = try await api.postFormWithFieldOverride(username: "admin", password: "admin123")
        print("Form encoded with field override response:", resp)

        XCTAssertEqual(resp.form?["user"], "admin")
        XCTAssertEqual(resp.form?["pass"], "admin123")
    }

    // MARK: - Response Parsing Tests

    func testHTTPBinUUID() async throws {
        let resp = try await api.uuid()
        print("UUID response:", resp)

        XCTAssertFalse(resp.uuid.isEmpty)
        XCTAssertTrue(resp.uuid.contains("-"))
    }

    func testHTTPBinIP() async throws {
        let resp = try await api.ip()
        print("IP response:", resp)

        XCTAssertFalse(resp.origin.isEmpty)
    }

    func testHTTPBinTupleResponse() async throws {
        let resp = try await api.uuidTuple()
        print("Tuple response:", resp)

        XCTAssertFalse(resp.uuid.isEmpty)
    }

    // MARK: - Query Parameters Tests

    func testHTTPBinDictionaryAsQueryParams() async throws {
        let filters = ["name": "John", "city": "NYC", "age": "30"]
        let resp = try await api.getWithDictionary(filters: filters)
        print("Dictionary as query params response:", resp)

        XCTAssertEqual(resp.args["name"], "John")
        XCTAssertEqual(resp.args["city"], "NYC")
        XCTAssertEqual(resp.args["age"], "30")
    }

    func testHTTPBinMixedPathAndQueryParams() async throws {
        let resp = try await api.anythingMixed(id: "item123", sort: "desc", limit: 10)
        print("Mixed path and query params response:", resp)

        XCTAssertTrue(resp.url.contains("/anything/item123"))
        XCTAssertEqual(resp.args?["sort"], "desc")
        XCTAssertEqual(resp.args?["limit"], "10")
    }

    // MARK: - EventStreaming Tests

    func testHTTPBinEventStreaming() async throws {
        let stream = try await api.stream(count: 5)
        print("Event streaming started...")

        var receivedEvents = [HTTPBinStreamResponse]()
        for try await event in stream {
            print("Received event:", event)
            receivedEvents.append(event)
        }

        print("Total events received:", receivedEvents.count)
        XCTAssertEqual(receivedEvents.count, 5)
    }

    // MARK: - Encoded Parameters Tests

    func testHTTPBinEncodedPathParameter() async throws {
        let resp = try await api.anythingEncoded(value: "hello world")
        print("Encoded path parameter response:", resp)

        XCTAssertTrue(resp.url.contains("/anything/"))
    }

    func testHTTPBinEncodedQueryParameter() async throws {
        let resp = try await api.getEncoded(text: "hello world")
        print("Encoded query parameter response:", resp)

        XCTAssertNotNil(resp.args["text"])
    }

    func testMultipartUpload() async throws {
        let resp = try await api.upload(title: "hello", text: "world")
        print(resp)
    }
}
