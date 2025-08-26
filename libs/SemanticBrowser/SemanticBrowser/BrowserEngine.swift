import Foundation

public protocol BrowserEngine: Sendable {
    func snapshotHTML(for url: String) async throws -> (html: String, text: String)
}

public enum BrowserError: Error { case invalidURL, fetchFailed }

public struct URLFetchBrowserEngine: BrowserEngine {
    public init() {}
    public func snapshotHTML(for url: String) async throws -> (html: String, text: String) {
        guard let u = URL(string: url) else { throw BrowserError.invalidURL }
        let (data, _) = try await URLSession.shared.data(from: u)
        let html = String(data: data, encoding: .utf8) ?? ""
        let text = html.removingHTMLTags()
        return (html, text)
    }
}

public struct ShellBrowserEngine: BrowserEngine {
    let binary: String
    let args: [String]
    public init(binary: String, args: [String] = []) { self.binary = binary; self.args = args }
    public func snapshotHTML(for url: String) async throws -> (html: String, text: String) {
        let proc = Process()
        proc.executableURL = URL(fileURLWithPath: binary)
        proc.arguments = args + [url]
        let pipe = Pipe()
        proc.standardOutput = pipe
        try proc.run()
        proc.waitUntilExit()
        guard proc.terminationStatus == 0 else { throw BrowserError.fetchFailed }
        let data = pipe.fileHandleForReading.readDataToEndOfFile()
        let html = String(data: data, encoding: .utf8) ?? ""
        let text = html.removingHTMLTags()
        return (html, text)
    }
}

extension String {
    func removingHTMLTags() -> String {
        return self.replacingOccurrences(of: "<[^>]+>", with: " ", options: .regularExpression, range: nil)
            .replacingOccurrences(of: "\\s+", with: " ", options: .regularExpression)
            .trimmingCharacters(in: .whitespacesAndNewlines)
    }
}

// © 2025 Contexter alias Benedikt Eickhoff 🛡️ All rights reserved.
