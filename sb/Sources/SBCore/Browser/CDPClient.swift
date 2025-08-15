import Foundation
#if canImport(FoundationNetworking)
import FoundationNetworking
#endif

public actor CDPClient {
    public struct Command<P: Encodable & Sendable>: Encodable, Sendable {
        public let id: Int
        public let method: String
        public let params: P?
        public init(id: Int, method: String, params: P? = nil) {
            self.id = id
            self.method = method
            self.params = params
        }
    }

    public struct Response<R: Decodable & Sendable>: Decodable, Sendable {
        public let id: Int
        public let result: R?
        public let error: RPCError?
    }

    public struct RPCError: Error, Decodable, Sendable {
        public let code: Int
        public let message: String
    }

    private let task: URLSessionWebSocketTask
    private var nextId: Int = 0
    private let encoder = JSONEncoder()
    private let decoder = JSONDecoder()

    public init(endpoint: URL, session: URLSession = .shared) {
        self.task = session.webSocketTask(with: endpoint)
        self.task.resume()
    }

    @discardableResult
    public func send<P: Encodable & Sendable, R: Decodable & Sendable>(_ method: String, params: P? = nil, result: R.Type = R.self) async throws -> R {
        nextId += 1
        let cmd = Command(id: nextId, method: method, params: params)
        let payload = try encoder.encode(cmd)
        try await task.send(.data(payload))
        while true {
            let message = try await task.receive()
            let data: Data
            switch message {
            case .data(let d):
                data = d
            case .string(let s):
                data = Data(s.utf8)
            @unknown default:
                continue
            }
            let resp = try decoder.decode(Response<R>.self, from: data)
            if resp.id == cmd.id {
                if let result = resp.result {
                    return result
                } else {
                    throw resp.error ?? RPCError(code: -1, message: "Unknown error")
                }
            }
        }
    }

    public func close() {
        task.cancel(with: .goingAway, reason: nil)
    }
}

// © 2025 Contexter alias Benedikt Eickhoff 🛡️ All rights reserved.
