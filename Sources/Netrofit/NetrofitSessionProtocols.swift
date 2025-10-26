//
//  NetrofitSessionTask.swift
//  Netrofit
//
//  Created by winddpan on 2025/10/26.
//

import Foundation

public protocol NetrofitSession {
    func createTask(method: String, url: URL, headers: [String: String]?, body: Data?) -> NetrofitTask
}

public protocol NetrofitTask {
    func resume()
    func waitUntilFinished() async -> NetrofitResponse
    func connectStream<T: Decodable>(_ type: T.Type, using decoder: HTTPBodyDecoder) throws -> AsyncStream<T>
    func connectThrowingStream<T: Decodable>(_ type: T.Type, using decoder: HTTPBodyDecoder) throws -> AsyncThrowingStream<T, Error>
}

public protocol NetrofitResponse {
    var request: URLRequest { get }
    var body: Data? { get }
    var headers: [String: String]? { get }
    var statusCode: Int? { get }
    var error: Error? { get }

    func validate() throws
    func decode<T: Decodable>(_ type: T.Type, using decoder: HTTPBodyDecoder) throws -> T
}
