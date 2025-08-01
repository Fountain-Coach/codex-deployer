import Foundation
#if canImport(FoundationNetworking)
import FoundationNetworking
#endif

public protocol DNSProvider {
    func listZones() async throws -> [String]
    func createRecord(zone: String, name: String, type: String, value: String) async throws
    func updateRecord(id: String, value: String) async throws
    func deleteRecord(id: String) async throws
}

public struct HetznerDNSClient: DNSProvider {
    let token: String
    let session: URLSession

    public init(token: String, session: URLSession = .shared) {
        self.token = token
        self.session = session
    }

    public func listZones() async throws -> [String] { [] }
    public func createRecord(zone: String, name: String, type: String, value: String) async throws {}
    public func updateRecord(id: String, value: String) async throws {}
    public func deleteRecord(id: String) async throws {}
}

public struct Route53Client: DNSProvider {
    public init() {}
    public func listZones() async throws -> [String] { throw NSError(domain: "Route53", code: 501) }
    public func createRecord(zone: String, name: String, type: String, value: String) async throws { throw NSError(domain: "Route53", code: 501) }
    public func updateRecord(id: String, value: String) async throws { throw NSError(domain: "Route53", code: 501) }
    public func deleteRecord(id: String) async throws { throw NSError(domain: "Route53", code: 501) }
}

// © 2025 Contexter alias Benedikt Eickhoff 🛡️ All rights reserved.
