import Foundation

// URL
@propertyWrapper
public struct Path<T: CustomStringConvertible> {
    public var wrappedValue: T
    private let path: String?
    private let encoded: Bool

    public init(wrappedValue: T, _ path: String? = nil, encoded: Bool = false) {
        self.wrappedValue = wrappedValue
        self.path = path
        self.encoded = encoded
    }
}

// Query
@propertyWrapper
public struct Query<T: CustomStringConvertible> {
    public var wrappedValue: T
    private let path: String?
    private let encoded: Bool

    public init(wrappedValue: T, _ path: String? = nil, encoded: Bool = false) {
        self.wrappedValue = wrappedValue
        self.path = path
        self.encoded = encoded
    }
}

// Body
@propertyWrapper
public struct Body<T: Encodable> {
    public var wrappedValue: T

    public init(wrappedValue: T) {
        self.wrappedValue = wrappedValue
    }
}

// Query
@propertyWrapper
public struct Field<T: Encodable> {
    public var wrappedValue: T
    private let path: String?

    public init(wrappedValue: T, _ path: String? = nil) {
        self.wrappedValue = wrappedValue
        self.path = path
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
public struct Part<T: Encodable> {
    public var wrappedValue: T
    public let name: String
    public let encoding: String?

    public init(wrappedValue: T, _ name: String, encoding: String? = nil) {
        self.wrappedValue = wrappedValue
        self.name = name
        self.encoding = encoding
    }
}
