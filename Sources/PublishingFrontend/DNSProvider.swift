import Foundation

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

/// Stub implementation used during development.
public struct Route53Client: DNSProvider {
    /// Creates a new client instance.
    public init() {}
    /// Lists zones available to the AWS Route53 account.
    /// - Returns: This stub never returns normally.
    /// - Throws: An ``NSError`` with domain `"Route53"` and code `501`.
    public func listZones() async throws -> [String] {
        throw NSError(domain: "Route53", code: 501)
    }
    /// Attempts to create a DNS record within Route53.
    /// - Parameters:
    ///   - zone: Hosted zone identifier.
    ///   - name: Record name without the zone suffix.
    ///   - type: DNS record type such as `"A"` or `"TXT"`.
    ///   - value: Content value for the record.
    /// - Throws: An ``NSError`` with domain `"Route53"` and code `501`.
    public func createRecord(zone: String, name: String, type: String, value: String) async throws {
        throw NSError(domain: "Route53", code: 501)
    }
    /// Attempts to update a DNS record within Route53.
    /// - Parameters:
    ///   - id: Identifier of the record to update.
    ///   - zone: Hosted zone containing the record.
    ///   - name: Record name without the zone suffix.
    ///   - type: DNS record type such as `"A"` or `"TXT"`.
    ///   - value: New content to store in the record.
    /// - Throws: An ``NSError`` with domain `"Route53"` and code `501`.
    public func updateRecord(id: String, zone: String, name: String, type: String, value: String) async throws {
        throw NSError(domain: "Route53", code: 501)
    }
    /// Attempts to delete a DNS record in Route53.
    /// - Parameter id: Identifier of the record to delete.
    /// - Throws: An ``NSError`` with domain `"Route53"` and code `501`.
    public func deleteRecord(id: String) async throws {
        throw NSError(domain: "Route53", code: 501)
    }
}

// © 2025 Contexter alias Benedikt Eickhoff 🛡️ All rights reserved.
