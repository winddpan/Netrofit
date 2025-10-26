import Foundation

extension NetrofitProvider {
    public convenience init(
        baseURL: String,
        configuration: URLSessionConfiguration = .default,
        interceptors: [NetrofitInterceptor] = []
    ) {
        let session = _NetrofitSession(configuration: configuration)
        self.init(baseURL: baseURL, session: session, interceptors: interceptors)
    }
}

class _NetrofitSession: NSObject, NetrofitSession, URLSessionDataDelegate {
    let configuration: URLSessionConfiguration
    private var urlSession: URLSession!
    private var createdTasks = Set<_NetrofitTask>()

    init(configuration: URLSessionConfiguration) {
        self.configuration = configuration
        super.init()
        urlSession = URLSession(configuration: configuration, delegate: self, delegateQueue: .main)
    }

    func createTask(method: String, url: URL, headers: [String: String]?, body: Data?) -> NetrofitTask {
        var request = URLRequest(url: url)
        request.httpMethod = method
        request.httpBody = body
        request.allHTTPHeaderFields = headers

        let task = _NetrofitTask(urlSession: urlSession, request: request)
        createdTasks.insert(task)
        return task
    }

    func urlSession(_ session: URLSession, dataTask: URLSessionDataTask, didReceive response: URLResponse) async -> URLSession.ResponseDisposition {
        if let _task = createdTasks.first(where: { $0.dataTask === dataTask }) {
            _task.urlResponse = response
        }
        return .allow
    }

    func urlSession(_ session: URLSession, dataTask: URLSessionDataTask, didReceive data: Data) {
        if let _task = createdTasks.first(where: { $0.dataTask === dataTask }) {
            _task.didReceiveData(data)
        }
    }

    func urlSession(_ session: URLSession, task: URLSessionTask, didCompleteWithError error: (any Error)?) {
        if let _task = createdTasks.first(where: { $0.dataTask === task }) {
            _task.didCompleteWithError(error)
        }
    }
}
