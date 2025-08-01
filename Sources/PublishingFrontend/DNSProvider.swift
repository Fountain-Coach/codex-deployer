import Foundation
#if canImport(FoundationNetworking)
import FoundationNetworking
#endif

public protocol DNSProvider {
    func listZones() async throws -> [String]
    func createRecord(zone: String, name: String, type: String, value: String) async throws
    func updateRecord(id: String, zone: String, name: String, type: String, value: String) async throws
    func deleteRecord(id: String) async throws
}

public struct HetznerDNSClient: DNSProvider {
    let api: APIClient

    public init(token: String, session: HTTPSession = URLSession.shared) {
        self.api = APIClient(
            baseURL: URL(string: "https://dns.hetzner.com/api/v1")!,
            session: session,
            defaultHeaders: ["Auth-API-Token": token]
        )
    }

    public func listZones() async throws -> [String] {
        let response = try await api.send(ListZones(parameters: ListZonesParameters()))
        return response.zones.map { $0.id }
    }

    public func createRecord(zone: String, name: String, type: String, value: String) async throws {
        let body = RecordCreate(name: name, ttl: 60, type: type, value: value, zone_id: zone)
        _ = try await api.send(CreateRecord(body: body))
    }

    public func updateRecord(id: String, zone: String, name: String, type: String, value: String) async throws {
        let params = UpdateRecordParameters(recordid: id)
        let body = RecordCreate(name: name, ttl: 60, type: type, value: value, zone_id: zone)
        _ = try await api.send(UpdateRecord(parameters: params, body: body))
    }

    public func deleteRecord(id: String) async throws {
        let params = DeleteRecordParameters(recordid: id)
        _ = try await api.send(DeleteRecord(parameters: params))
    }
}

public struct Route53Client: DNSProvider {
    public init() {}
    public func listZones() async throws -> [String] { throw NSError(domain: "Route53", code: 501) }
    public func createRecord(zone: String, name: String, type: String, value: String) async throws { throw NSError(domain: "Route53", code: 501) }
    public func updateRecord(id: String, zone: String, name: String, type: String, value: String) async throws { throw NSError(domain: "Route53", code: 501) }
    public func deleteRecord(id: String) async throws { throw NSError(domain: "Route53", code: 501) }
}

// © 2025 Contexter alias Benedikt Eickhoff 🛡️ All rights reserved.
