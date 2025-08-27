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

    public func snapshot(for url: String, wait: APIModels.WaitPolicy?) async throws -> SnapshotResult {
        if #available(macOS 14.0, *) {
            let session = CDPSession(wsURL: wsURL)
            try await session.open()
            defer { Task { await session.close() } }
            let targetId = try await session.createTarget(url: "about:blank")
            try await session.attach(targetId: targetId)
            try await session.enablePage()
            try await session.enableNetwork()
            let start = Date()
            try await session.navigate(url: url)
            let strat = wait?.strategy?.lowercased()
            if strat == "domcontentloaded" {
                try await session.waitForDomContentLoaded(timeoutMs: wait?.maxWaitMs ?? 5000)
            } else if strat == "networkidle" {
                try await session.waitForLoadEvent(timeoutMs: wait?.maxWaitMs ?? 5000)
                if let idle = wait?.networkIdleMs, idle > 0 {
                    try await session.waitForNetworkIdle(idleMs: idle, timeoutMs: wait?.maxWaitMs ?? (idle + 3000))
                }
            } else {
                try await session.waitForLoadEvent(timeoutMs: wait?.maxWaitMs ?? 5000)
            }
            let loadMs = Int(Date().timeIntervalSince(start) * 1000.0)
            let html = try await session.getOuterHTML()
            let text = html.removingHTMLTags()
            let final = (try? await session.getCurrentURL()) ?? url
            // Map captured requests (truncate body capture omitted for now)
            let requests: [APIModels.Snapshot.Network.Request] = session.reqs.values.map { info in
                APIModels.Snapshot.Network.Request(url: info.url, type: info.type, status: info.status, body: nil)
            }
            return SnapshotResult(html: html, text: text, finalURL: final, loadMs: loadMs, network: requests)
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
    // Network tracking
    var inflight: Set<String> = []
    struct ReqInfo { var url: String; var type: String?; var status: Int? }
    var reqs: [String: ReqInfo] = [:]
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
    private func processEventObject(_ obj: [String: Any]) {
        guard let method = obj["method"] as? String, let params = obj["params"] as? [String: Any] else { return }
        switch method {
        case "Network.requestWillBeSent":
            if let rid = params["requestId"] as? String, let req = params["request"] as? [String: Any], let url = req["url"] as? String {
                inflight.insert(rid)
                var info = reqs[rid] ?? ReqInfo(url: url, type: nil, status: nil)
                if let t = params["type"] as? String { info.type = t }
                reqs[rid] = info
            }
        case "Network.responseReceived":
            if let rid = params["requestId"] as? String, let resp = params["response"] as? [String: Any] {
                var info = reqs[rid] ?? ReqInfo(url: "", type: nil, status: nil)
                if let s = resp["status"] as? Int { info.status = s }
                if let t = params["type"] as? String { info.type = t }
                if let url = resp["url"] as? String, info.url.isEmpty { info.url = url }
                reqs[rid] = info
            }
        case "Network.loadingFinished", "Network.loadingFailed":
            if let rid = params["requestId"] as? String { inflight.remove(rid) }
        default:
            break
        }
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
                if let m = j, m["method"] != nil { processEventObject(m) }
                if let rid = j?["id"] as? Int, rid == id {
                    if let res = j?["result"] {
                        let rd = try JSONSerialization.data(withJSONObject: res)
                        return try JSONDecoder().decode(T.self, from: rd)
                    } else { throw BrowserError.fetchFailed }
                }
            case .string(let s):
                if let d = s.data(using: .utf8) {
                    let j = try JSONSerialization.jsonObject(with: d) as? [String: Any]
                    if let m = j, m["method"] != nil { processEventObject(m) }
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
    func enableNetwork() async throws { struct R: Decodable {}; _ = try await sendRecv("Network.enable", params: [:], result: R.self) }
    func navigate(url: String) async throws { struct R: Decodable {}; _ = try await sendRecv("Page.navigate", params: ["url": url], result: R.self) }
    func waitForLoadEvent(timeoutMs: Int) async throws {
        let deadline = Date().addingTimeInterval(Double(timeoutMs)/1000.0)
        while Date() < deadline {
            guard let task else { throw BrowserError.fetchFailed }
            do {
                let msg = try await withTaskCancellationHandler(operation: {
                    try await withTimeout(seconds: 0.5) { try await task.receive() }
                }, onCancel: { })
                switch msg {
                case .data(let d):
                    if let m = try? JSONSerialization.jsonObject(with: d) as? [String: Any] {
                        if (m["method"] as? String) == "Page.loadEventFired" { return }
                        processEventObject(m)
                    }
                case .string(let s):
                    if let d = s.data(using: .utf8), let m = try? JSONSerialization.jsonObject(with: d) as? [String: Any] {
                        if (m["method"] as? String) == "Page.loadEventFired" { return }
                        processEventObject(m)
                    }
                @unknown default: break
                }
            } catch { /* ignore timeouts */ }
        }
    }
    func waitForDomContentLoaded(timeoutMs: Int) async throws {
        let deadline = Date().addingTimeInterval(Double(timeoutMs)/1000.0)
        while Date() < deadline {
            guard let task else { throw BrowserError.fetchFailed }
            do {
                let msg = try await withTaskCancellationHandler(operation: {
                    try await withTimeout(seconds: 0.5) { try await task.receive() }
                }, onCancel: { })
                switch msg {
                case .data(let d):
                    if let m = try? JSONSerialization.jsonObject(with: d) as? [String: Any] {
                        if (m["method"] as? String) == "Page.domContentEventFired" { return }
                        processEventObject(m)
                    }
                case .string(let s):
                    if let d = s.data(using: .utf8), let m = try? JSONSerialization.jsonObject(with: d) as? [String: Any] {
                        if (m["method"] as? String) == "Page.domContentEventFired" { return }
                        processEventObject(m)
                    }
                @unknown default: break
                }
            } catch { /* ignore timeouts */ }
        }
    }
    func waitForNetworkIdle(idleMs: Int, timeoutMs: Int) async throws {
        let overallDeadline = Date().addingTimeInterval(Double(timeoutMs)/1000.0)
        var idleStart: Date? = nil
        while Date() < overallDeadline {
            if inflight.isEmpty {
                if idleStart == nil { idleStart = Date() }
                if let started = idleStart, Int(Date().timeIntervalSince(started) * 1000.0) >= idleMs { return }
            } else {
                idleStart = nil
            }
            // drain events for a short period
            guard let task else { throw BrowserError.fetchFailed }
            do {
                let msg = try await withTimeout(seconds: 0.2) { try await task.receive() }
                switch msg {
                case .data(let d):
                    if let m = try? JSONSerialization.jsonObject(with: d) as? [String: Any] { processEventObject(m) }
                case .string(let s):
                    if let d = s.data(using: .utf8), let m = try? JSONSerialization.jsonObject(with: d) as? [String: Any] { processEventObject(m) }
                @unknown default: break
                }
            } catch { /* time slice idle */ }
        }
    }
    func getOuterHTML() async throws -> String {
        struct GetDoc: Decodable { let root: Node }
        struct Node: Decodable { let nodeId: Int }
        let doc: GetDoc = try await sendRecv("DOM.getDocument", params: ["depth": -1], result: GetDoc.self)
        struct Outer: Decodable { let outerHTML: String }
        let out: Outer = try await sendRecv("DOM.getOuterHTML", params: ["nodeId": doc.root.nodeId], result: Outer.self)
        return out.outerHTML
    }
    func getCurrentURL() async throws -> String? {
        struct Hist: Decodable { let currentIndex: Int; let entries: [Entry] }
        struct Entry: Decodable { let url: String }
        let h: Hist = try await sendRecv("Page.getNavigationHistory", params: [:], result: Hist.self)
        if h.currentIndex >= 0 && h.currentIndex < h.entries.count { return h.entries[h.currentIndex].url }
        return nil
    }
}

@available(macOS 14.0, *)
func withTimeout<T>(seconds: Double, operation: @escaping () async throws -> T) async throws -> T {
    try await withThrowingTaskGroup(of: T.self) { group in
        group.addTask { try await operation() }
        group.addTask { try await Task.sleep(nanoseconds: UInt64(seconds * 1_000_000_000)); throw BrowserError.fetchFailed }
        let result = try await group.next()!
        group.cancelAll()
        return result
    }
}

// © 2025 Contexter alias Benedikt Eickhoff 🛡️ All rights reserved.
