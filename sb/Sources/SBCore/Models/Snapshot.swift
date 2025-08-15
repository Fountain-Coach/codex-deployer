import Foundation

public struct Snapshot: Codable, Sendable {
    public struct Page: Codable, Sendable {
        public var uri: URL
        public var finalUrl: URL?
        public var fetchedAt: Date
        public var status: Int
        public var contentType: String
        public struct Navigation: Codable, Sendable {
            public var ttfbMs: Int?
            public var loadMs: Int?
            public init(ttfbMs: Int? = nil, loadMs: Int? = nil) {
                self.ttfbMs = ttfbMs
                self.loadMs = loadMs
            }
        }
        public var navigation: Navigation?

        public init(uri: URL, finalUrl: URL? = nil, fetchedAt: Date, status: Int, contentType: String, navigation: Navigation? = nil) {
            self.uri = uri
            self.finalUrl = finalUrl
            self.fetchedAt = fetchedAt
            self.status = status
            self.contentType = contentType
            self.navigation = navigation
        }
    }

    public struct Rendered: Codable, Sendable {
        public var html: String
        public var text: String
        public var meta: [String: String]?

        public init(html: String, text: String, meta: [String: String]? = nil) {
            self.html = html
            self.text = text
            self.meta = meta
        }
    }

    public struct Network: Codable, Sendable {
        public struct Request: Codable, Sendable {
            public enum ResourceType: String, Codable, Sendable {
                case Document, Stylesheet, Image, Media, Font, Script, XHR, Fetch, Other
            }
            public var url: URL
            public var type: ResourceType?
            public var status: Int?
            public var body: String?

            public init(url: URL, type: ResourceType? = nil, status: Int? = nil, body: String? = nil) {
                self.url = url
                self.type = type
                self.status = status
                self.body = body
            }
        }

        public var requests: [Request]?

        public init(requests: [Request]? = nil) {
            self.requests = requests
        }
    }

    public var snapshotId: String
    public var page: Page
    public var rendered: Rendered
    public var network: Network?
    public var diagnostics: [String]?

    public init(snapshotId: String, page: Page, rendered: Rendered, network: Network? = nil, diagnostics: [String]? = nil) {
        self.snapshotId = snapshotId
        self.page = page
        self.rendered = rendered
        self.network = network
        self.diagnostics = diagnostics
    }
}
// © 2025 Contexter alias Benedikt Eickhoff 🛡️ All rights reserved.
