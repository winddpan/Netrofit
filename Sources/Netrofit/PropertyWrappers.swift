import Foundation

// URL
@propertyWrapper
public struct Path {
    public var wrappedValue: String
    private let path: String
    private let encoded: Bool

    public init(wrappedValue: String, _ path: String = "", encoded: Bool = true) {
        self.wrappedValue = wrappedValue
        self.path = path
        self.encoded = encoded
    }
}

// Query
@propertyWrapper
public struct Query {
    public var wrappedValue: String
    private let path: String
    private let encoded: Bool

    public init(wrappedValue: String, _ path: String = "", encoded: Bool = true) {
        self.wrappedValue = wrappedValue
        self.path = path
        self.encoded = encoded
    }
}


// Header
@propertyWrapper
public struct Header {
    public var wrappedValue: String?
    public let name: String

    public init(wrappedValue: String? = nil, _ name: String) {
        self.wrappedValue = wrappedValue
        self.name = name
    }
}

// Multipart
@propertyWrapper
public struct Part {
    public var wrappedValue: Encodable?
    public let name: String
    public let encoding: String?

    public init(wrappedValue: Encodable? = nil, _ name: String, encoding: String? = nil) {
        self.wrappedValue = wrappedValue
        self.name = name
        self.encoding = encoding
    }
}

// Body
@propertyWrapper
public struct Body {
    public var wrappedValue: Encodable?
    private let path: String
    private let encoded: Bool

    public init(wrappedValue: Encodable?, _ path: String = "", encoded: Bool = true) {
        self.wrappedValue = wrappedValue
        self.path = path
        self.encoded = encoded
    }
}
