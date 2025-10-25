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
public struct Header<T> {
    public var wrappedValue: T // String
    public let name: String?

    public init(wrappedValue: T, _ name: String? = nil) {
        self.wrappedValue = wrappedValue
        self.name = name
    }
}

@propertyWrapper
public struct HeaderMap<T> {
    public var wrappedValue: T // [String: String]

    public init(wrappedValue: T) {
        self.wrappedValue = wrappedValue
    }
}

// Multipart
@propertyWrapper
public struct Part<T: Encodable> {
    public var wrappedValue: T
    public let name: String?
    public let filename: String?
    public let mimeType: String?

    public init(wrappedValue: T, name: String? = nil, filename: String? = nil, mimeType: String? = nil) {
        self.wrappedValue = wrappedValue
        self.name = name
        self.filename = filename
        self.mimeType = mimeType
    }
}
