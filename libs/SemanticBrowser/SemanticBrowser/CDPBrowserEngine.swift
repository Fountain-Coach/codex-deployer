import Foundation

public struct CDPBrowserEngine: BrowserEngine {
    let wsURL: URL
    public init(wsURL: URL) { self.wsURL = wsURL }

    public func snapshotHTML(for url: String) async throws -> (html: String, text: String) {
        if #available(macOS 14.0, *) {
            let session = CDPSession(wsURL: wsURL)
            try await session.open()
            defer { Task { await session.close() } }
            let targetId = try await session.createTarget(url: "about:blank")
            try await session.attach(targetId: targetId)
            try await session.enablePage()
            try await session.navigate(url: url)
            try await session.waitForLoadEvent(timeoutMs: 5000)
            let html = try await session.getOuterHTML()
            let text = html.removingHTMLTags()
            return (html, text)
        } else {
            throw BrowserError.fetchFailed
        }
    }
}

@available(macOS 14.0, *)
actor CDPSession {
    let wsURL: URL
    var task: URLSessionWebSocketTask?
    var nextId: Int = 1
    init(wsURL: URL) { self.wsURL = wsURL }
    func open() async throws {
        let session = URLSession(configuration: .default)
        let task = session.webSocketTask(with: wsURL)
        self.task = task
        task.resume()
        try await Task.sleep(nanoseconds: 100_000_000)
    }
    func close() {
        task?.cancel()
    }
    private func sendRecv<T: Decodable>(_ method: String, params: [String: Any]? = nil, result: T.Type) async throws -> T {
        guard let task else { throw BrowserError.fetchFailed }
        let id = nextId; nextId += 1
        var obj: [String: Any] = ["id": id, "method": method]
        if let params { obj["params"] = params }
        let data = try JSONSerialization.data(withJSONObject: obj)
        try await task.send(.data(data))
        while true {
            let msg = try await task.receive()
            switch msg {
            case .data(let d):
                let j = try JSONSerialization.jsonObject(with: d) as? [String: Any]
                if let rid = j?["id"] as? Int, rid == id {
                    if let res = j?["result"] {
                        let rd = try JSONSerialization.data(withJSONObject: res)
                        return try JSONDecoder().decode(T.self, from: rd)
                    } else { throw BrowserError.fetchFailed }
                }
            case .string(let s):
                if let d = s.data(using: .utf8) {
                    let j = try JSONSerialization.jsonObject(with: d) as? [String: Any]
                    if let rid = j?["id"] as? Int, rid == id {
                        if let res = j?["result"] {
                            let rd = try JSONSerialization.data(withJSONObject: res)
                            return try JSONDecoder().decode(T.self, from: rd)
                        } else { throw BrowserError.fetchFailed }
                    }
                }
            @unknown default: break
            }
        }
    }
    func createTarget(url: String) async throws -> String {
        struct R: Decodable { let targetId: String }
        let r: R = try await sendRecv("Target.createTarget", params: ["url": url], result: R.self)
        return r.targetId
    }
    func attach(targetId: String) async throws {
        struct R: Decodable { let sessionId: String }
        _ = try await sendRecv("Target.attachToTarget", params: ["targetId": targetId, "flatten": true], result: R.self)
    }
    func enablePage() async throws { struct R: Decodable {}; _ = try await sendRecv("Page.enable", params: [:], result: R.self) }
    func navigate(url: String) async throws { struct R: Decodable {}; _ = try await sendRecv("Page.navigate", params: ["url": url], result: R.self) }
    func waitForLoadEvent(timeoutMs: Int) async throws { try await Task.sleep(nanoseconds: UInt64(timeoutMs) * 1_000_000) }
    func getOuterHTML() async throws -> String {
        struct GetDoc: Decodable { let root: Node }
        struct Node: Decodable { let nodeId: Int }
        let doc: GetDoc = try await sendRecv("DOM.getDocument", params: ["depth": -1], result: GetDoc.self)
        struct Outer: Decodable { let outerHTML: String }
        let out: Outer = try await sendRecv("DOM.getOuterHTML", params: ["nodeId": doc.root.nodeId], result: Outer.self)
        return out.outerHTML
    }
}

// © 2025 Contexter alias Benedikt Eickhoff 🛡️ All rights reserved.
