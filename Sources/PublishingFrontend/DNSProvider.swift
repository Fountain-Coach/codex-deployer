import Foundation
#if canImport(FoundationNetworking)
import FoundationNetworking
#endif

/// Abstraction over DNS providers used for certificate challenges and routing.
public protocol DNSProvider {
    /// Lists all zone identifiers available to the account.
    func listZones() async throws -> [String]
    /// Creates a new DNS record within the given zone.
    func createRecord(zone: String, name: String, type: String, value: String) async throws
    /// Updates an existing record with a new value.
    func updateRecord(id: String, zone: String, name: String, type: String, value: String) async throws
    /// Deletes a DNS record by identifier.
    func deleteRecord(id: String) async throws
}

/// Concrete ``DNSProvider`` that talks to the Hetzner DNS API.
public struct HetznerDNSClient: DNSProvider {
    let api: APIClient

    /// Creates a new client with the given API token and session.
    public init(token: String, session: HTTPSession = URLSession.shared) {
        self.api = APIClient(
            baseURL: URL(string: "https://dns.hetzner.com/api/v1")!,
            session: session,
            defaultHeaders: ["Auth-API-Token": token]
        )
    }

    /// Returns all zone identifiers the token has access to.
    public func listZones() async throws -> [String] {
        let response = try await api.send(ListZones(parameters: ListZonesParameters()))
        return response.zones.map { $0.id }
    }

    /// Adds an ``A`` or ``TXT`` record to the zone.
    public func createRecord(zone: String, name: String, type: String, value: String) async throws {
        let body = RecordCreate(name: name, ttl: 60, type: type, value: value, zone_id: zone)
        _ = try await api.send(CreateRecord(body: body))
    }

    /// Updates a DNS record's value.
    public func updateRecord(id: String, zone: String, name: String, type: String, value: String) async throws {
        let params = UpdateRecordParameters(recordid: id)
        let body = RecordCreate(name: name, ttl: 60, type: type, value: value, zone_id: zone)
        _ = try await api.send(UpdateRecord(parameters: params, body: body))
    }

    /// Removes a DNS record from the zone.
    public func deleteRecord(id: String) async throws {
        let params = DeleteRecordParameters(recordid: id)
        _ = try await api.send(DeleteRecord(parameters: params))
    }
}

/// Stub implementation used during development.
public struct Route53Client: DNSProvider {
    /// Creates a new client instance.
    public init() {}
    /// :nodoc: Currently unimplemented.
    public func listZones() async throws -> [String] { throw NSError(domain: "Route53", code: 501) }
    /// :nodoc: Currently unimplemented.
    public func createRecord(zone: String, name: String, type: String, value: String) async throws { throw NSError(domain: "Route53", code: 501) }
    /// :nodoc: Currently unimplemented.
    public func updateRecord(id: String, zone: String, name: String, type: String, value: String) async throws { throw NSError(domain: "Route53", code: 501) }
    /// :nodoc: Currently unimplemented.
    public func deleteRecord(id: String) async throws { throw NSError(domain: "Route53", code: 501) }
}

// © 2025 Contexter alias Benedikt Eickhoff 🛡️ All rights reserved.
