import Foundation
import SBCore

public struct Handlers {
    private let navigator: URLNavigator
    private let dissector: Dissector
    private let indexer: TypesenseIndexer
    private let sb: SB

    public init(
        navigator: URLNavigator = URLNavigator(),
        dissector: Dissector = Dissector(),
        indexer: TypesenseIndexer = TypesenseIndexer()
    ) {
        self.navigator = navigator
        self.dissector = dissector
        self.indexer = indexer
        self.sb = SB(navigator: navigator, dissector: dissector, indexer: indexer, store: nil)
    }

    // MARK: - Query
    public func querypages(_ request: HTTPRequest, body: NoBody?) async throws -> HTTPResponse {
        struct Response: Codable { let total: Int; let items: [PageDoc] }
        let data = try JSONEncoder().encode(Response(total: 0, items: []))
        return HTTPResponse(status: 200, headers: ["Content-Type": "application/json"], body: data)
    }

    public func browseanddissect(_ request: HTTPRequest, body: BrowseRequest?) async throws -> HTTPResponse {
        struct Req: Codable { let url: URL; let wait: WaitPolicy; let mode: DissectionMode; let index: IndexOptions? }
        struct Resp: Codable { let snapshot: Snapshot; let analysis: Analysis?; let index: IndexResult? }
        let req = try JSONDecoder().decode(Req.self, from: request.body)
        let (snap, analysis, result) = try await sb.browseAndDissect(url: req.url, wait: req.wait, mode: req.mode, index: req.index)
        let payload = try JSONEncoder().encode(Resp(snapshot: snap, analysis: analysis, index: result))
        return HTTPResponse(status: 200, headers: ["Content-Type": "application/json"], body: payload)
    }

    public func snapshotonly(_ request: HTTPRequest, body: SnapshotRequest?) async throws -> HTTPResponse {
        struct Req: Codable { let url: URL; let wait: WaitPolicy }
        struct Resp: Codable { let snapshot: Snapshot }
        let req = try JSONDecoder().decode(Req.self, from: request.body)
        let snap = try await navigator.snapshot(url: req.url, wait: req.wait, store: nil)
        let payload = try JSONEncoder().encode(Resp(snapshot: snap))
        return HTTPResponse(status: 200, headers: ["Content-Type": "application/json"], body: payload)
    }

    public func health(_ request: HTTPRequest, body: NoBody?) async throws -> HTTPResponse {
        struct Health: Codable {
            let status = "ok"
            let version = "0.0.1"
            let browserPool = ["capacity": 0, "inUse": 0]
        }
        let data = try JSONEncoder().encode(Health())
        return HTTPResponse(status: 200, headers: ["Content-Type": "application/json"], body: data)
    }

    public func queryentities(_ request: HTTPRequest, body: NoBody?) async throws -> HTTPResponse {
        struct Response: Codable { let total: Int; let items: [EntityDoc] }
        let data = try JSONEncoder().encode(Response(total: 0, items: []))
        return HTTPResponse(status: 200, headers: ["Content-Type": "application/json"], body: data)
    }

    public func indexanalysis(_ request: HTTPRequest, body: IndexRequest?) async throws -> HTTPResponse {
        struct Req: Codable { let analysis: Analysis; let options: IndexOptions }
        let req = try JSONDecoder().decode(Req.self, from: request.body)
        let result = try await indexer.upsert(analysis: req.analysis, options: req.options)
        let data = try JSONEncoder().encode(result)
        return HTTPResponse(status: 200, headers: ["Content-Type": "application/json"], body: data)
    }

    public func exportartifacts(_ request: HTTPRequest, body: NoBody?) async throws -> HTTPResponse {
        return HTTPResponse(status: 404)
    }

    public func querysegments(_ request: HTTPRequest, body: NoBody?) async throws -> HTTPResponse {
        struct Response: Codable { let total: Int; let items: [SegmentDoc] }
        let data = try JSONEncoder().encode(Response(total: 0, items: []))
        return HTTPResponse(status: 200, headers: ["Content-Type": "application/json"], body: data)
    }

    public func getpage(_ request: HTTPRequest, body: NoBody?) async throws -> HTTPResponse {
        return HTTPResponse(status: 404)
    }

    public func analyzesnapshot(_ request: HTTPRequest, body: AnalyzeRequest?) async throws -> HTTPResponse {
        struct Req: Codable { let mode: DissectionMode; let snapshot: Snapshot }
        let req = try JSONDecoder().decode(Req.self, from: request.body)
        let analysis = try await dissector.analyze(from: req.snapshot, mode: req.mode, store: nil)
        let data = try JSONEncoder().encode(analysis)
        return HTTPResponse(status: 200, headers: ["Content-Type": "application/json"], body: data)
    }
}

© 2025 Contexter alias Benedikt Eickhoff 🛡️ All rights reserved.
