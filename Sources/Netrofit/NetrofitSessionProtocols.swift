//
//  NetrofitSessionTask.swift
//  Netrofit
//
//  Created by winddpan on 2025/10/26.
//

import Foundation

public protocol NetrofitSession {
    func createTask(
        method: String,
        url: URL,
        headers: [String: String]?,
        body: Data?,
        plugins: [NetrofitPlugin]
    ) -> NetrofitTask
}

public protocol NetrofitTask {
    func resume()

    func waitUntilFinished() async -> NetrofitResponse

    func decode<T: Decodable>(_ type: T.Type, response: NetrofitResponse, using builder: RequestBuilder) throws -> T

    func connectStream<T: Decodable>(_ type: T.Type, using builder: RequestBuilder) throws -> AsyncStream<T>

    func connectThrowingStream<T: Decodable>(_ type: T.Type, using builder: RequestBuilder) throws -> AsyncThrowingStream<T, Error>
}
