import Foundation

// MARK: API

@attached(member, names: arbitrary)
public macro API() = #externalMacro(module: "NetrofitMacros", type: "APIMacro")

// MARK: Basic

@attached(peer)
public macro Headers(_ headers: [String: String]) = #externalMacro(module: "NetrofitMacros", type: "EmptyMacro")

@attached(peer)
public macro ResponseKeyPath(_ path: String) = #externalMacro(module: "NetrofitMacros", type: "EmptyMacro")

@attached(peer)
public macro JSON(
    encoder: HTTPBodyEncoder = JSONEncoder(),
    decoder: HTTPBodyDecoder = DynamicContentTypeDecoder()
) = #externalMacro(
    module: "NetrofitMacros",
    type: "EmptyMacro"
)

@attached(peer)
public macro FormUrlEncoded(
    encoder: HTTPBodyEncoder = URLEncodedFormEncoder(),
    decoder: HTTPBodyDecoder = DynamicContentTypeDecoder()
) = #externalMacro(
    module: "NetrofitMacros",
    type: "EmptyMacro"
)

@attached(peer)
public macro Multipart(
    encoder: HTTPBodyEncoder = MultipartEncoder(),
    decoder: HTTPBodyDecoder = DynamicContentTypeDecoder()
) = #externalMacro(module: "NetrofitMacros", type: "EmptyMacro")

@attached(peer)
public macro EventStreaming(
    encoder: HTTPBodyEncoder = JSONEncoder(),
    decoder: HTTPBodyDecoder = DynamicContentTypeDecoder()
) = #externalMacro(module: "NetrofitMacros", type: "EmptyMacro")

// MARK: Method

@attached(body)
public macro DELETE(_ path: String) = #externalMacro(module: "NetrofitMacros", type: "MethodMacro")

@attached(body)
public macro GET(_ path: String) = #externalMacro(module: "NetrofitMacros", type: "MethodMacro")

@attached(body)
public macro PATCH(_ path: String) = #externalMacro(module: "NetrofitMacros", type: "MethodMacro")

@attached(body)
public macro POST(_ path: String) = #externalMacro(module: "NetrofitMacros", type: "MethodMacro")

@attached(body)
public macro PUT(_ path: String) = #externalMacro(module: "NetrofitMacros", type: "MethodMacro")

@attached(body)
public macro OPTIONS(_ path: String) = #externalMacro(module: "NetrofitMacros", type: "MethodMacro")

@attached(body)
public macro HEAD(_ path: String) = #externalMacro(module: "NetrofitMacros", type: "MethodMacro")

@attached(body)
public macro TRACE(_ path: String) = #externalMacro(module: "NetrofitMacros", type: "MethodMacro")

@attached(body)
public macro CONNECT(_ path: String) = #externalMacro(module: "NetrofitMacros", type: "MethodMacro")
