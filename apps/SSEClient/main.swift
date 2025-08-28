import Foundation

final class SSEClient: NSObject, URLSessionDataDelegate {
    private let url: URL
    private var task: URLSessionDataTask?
    private var received = Data()
    private var attempt = 0
    private let maxBackoff: TimeInterval = 10

    init(url: URL) { self.url = url }

    func start() {
        connect()
        RunLoop.main.run()
    }

    private func connect() {
        attempt += 1
        let config = URLSessionConfiguration.default
        let session = URLSession(configuration: config, delegate: self, delegateQueue: nil)
        var req = URLRequest(url: url)
        req.setValue("text/event-stream", forHTTPHeaderField: "Accept")
        task = session.dataTask(with: req)
        task?.resume()
        log("connecting to \(url.absoluteString) [attempt \(attempt)]")
    }

    private func scheduleReconnect() {
        let delay = min(pow(2.0, Double(attempt)), maxBackoff)
        log("reconnecting in \(Int(delay))s")
        DispatchQueue.global().asyncAfter(deadline: .now() + delay) { [weak self] in self?.connect() }
    }

    func urlSession(_ session: URLSession, dataTask: URLSessionDataTask, didReceive data: Data) {
        received.append(data)
        guard let text = String(data: data, encoding: .utf8) else { return }
        for line in text.split(separator: "\n", omittingEmptySubsequences: false) {
            if line.hasPrefix(":") { log("comment \(line)"); continue }
            if line.hasPrefix("event:") { log(String(line)) }
            if line.hasPrefix("data:") { print(String(line.dropFirst(5)).trimmingCharacters(in: .whitespaces)) }
        }
    }

    func urlSession(_ session: URLSession, task: URLSessionTask, didCompleteWithError error: Error?) {
        if let error { log("connection closed: \(error.localizedDescription)") } else { log("connection closed") }
        scheduleReconnect()
    }

    private func log(_ msg: String) { fputs("[sse] \(msg)\n", stderr) }
}

// Entry
let args = Array(CommandLine.arguments.dropFirst())
guard let raw = args.first, let url = URL(string: raw) else {
    fputs("Usage: sse-client <url>\n", stderr)
    exit(2)
}
SSEClient(url: url).start()

