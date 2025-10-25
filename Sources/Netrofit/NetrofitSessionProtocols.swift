//
//  NetrofitSessionTask.swift
//  Netrofit
//
//  Created by winddpan on 2025/10/26.
//

import Foundation

/// A type that can perform arbitrary HTTP requests.
public protocol NetrofitSession {
    func createTask(method: String, url: URL, headers: [String: String]?, body: Data?) -> NetrofitTask
}

public protocol NetrofitTask {
    func resume()
    func waitUntilFinished() async -> NetrofitResponse
    func connectStream<T: Decodable>(_ type: T.Type, using: HTTPBodyDecoder) throws -> AsyncStream<T>
    func connectThrowingStream<T: Decodable, E: Error>(_ type: T.Type, errorType: E.Type, using: HTTPBodyDecoder) throws -> AsyncThrowingStream<T, E>
}

public protocol NetrofitResponse {
    var request: URLRequest { get }
    var body: Data? { get }
    var headers: [String: String]? { get }
    var statusCode: Int? { get }
    var error: Error? { get }

    func validate() throws
    func decode<T: Decodable>(_ type: T.Type, using: HTTPBodyDecoder) throws -> T
}
