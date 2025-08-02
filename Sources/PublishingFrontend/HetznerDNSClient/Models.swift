// Models for Hetzner DNS API

/// Request body for creating multiple DNS records in a single batch.
public struct BulkRecordsCreateRequest: Codable {
    /// New records to be created atomically.
    public let records: [RecordCreate]
}

/// Response returned after attempting to create multiple records.
public struct BulkRecordsCreateResponse: Codable {
    /// Records deemed invalid and rejected by the API.
    public let invalid_records: [RecordCreate]
    /// Records actually created.
    public let records: [Record]
    /// Records that passed validation and were accepted.
    public let valid_records: [RecordCreate]
}

/// Request body for updating multiple DNS records in one call.
public struct BulkRecordsUpdateRequest: Codable {
    /// Key-value pairs describing records to update.
    public let records: [[String: String]]
}

/// Response body for bulk record update operations.
public struct BulkRecordsUpdateResponse: Codable {
    /// Records that failed to update.
    public let failed_records: [RecordUpdate]
    /// Records successfully updated.
    public let records: [Record]
}

/// Details about a specific record update attempt.
public struct RecordUpdate: Codable {
    /// Identifier of the record to update.
    public let id: String
    /// Hostname associated with the record.
    public let name: String
    /// Time to live value for the record.
    public let ttl: Int
    /// DNS record type, such as `A` or `TXT`.
    public let type: String
    /// New value written for the record.
    public let value: String
    /// Identifier of the zone owning the record.
    public let zone_id: String
}

/// Metadata describing a primary DNS server.
public struct PrimaryServer: Codable {
    /// IP address of the server.
    public let address: String
    /// Creation timestamp.
    public let created: String
    /// Server identifier.
    public let id: String
    /// Last modification timestamp.
    public let modified: String
    /// Port used for communication.
    public let port: Int
    /// Identifier of the zone served.
    public let zone_id: String
}

public struct PrimaryServerCreate: Codable {
    public let address: String
    public let port: Int
    public let zone_id: String
}

public struct PrimaryServerResponse: Codable {
    public let primary_server: PrimaryServer
}

public struct PrimaryServersResponse: Codable {
    public let primary_servers: [PrimaryServer]
}

public struct Record: Codable {
    public let created: String
    public let id: String
    public let modified: String
    public let name: String
    public let ttl: Int
    public let type: String
    public let value: String
    public let zone_id: String
}

public struct RecordCreate: Codable {
    public let name: String
    public let ttl: Int
    public let type: String
    public let value: String
    public let zone_id: String
}

public struct RecordResponse: Codable {
    public let record: Record
}

public struct RecordsResponse: Codable {
    public let records: [Record]
}

public struct Zone: Codable {
    public let created: String
    public let id: String
    public let is_secondary_dns: Bool
    public let legacy_dns_host: String
    public let legacy_ns: [String]
    public let modified: String
    public let name: String
    public let ns: [String]
    public let owner: String
    public let paused: Bool
    public let permission: String
    public let project: String
    public let records_count: Int
    public let registrar: String
    public let status: String
    public let ttl: Int
    public let txt_verification: [String: String]
    public let verified: String
}

public struct ZoneCreateRequest: Codable {
    public let name: String
    public let ttl: Int
}

public struct ZoneResponse: Codable {
    public let zone: Zone
}

public struct ZoneUpdateRequest: Codable {
    public let name: String
    public let ttl: Int
}

public struct ZonesResponse: Codable {
    public let meta: [String: String]
    public let zones: [Zone]
}

/// Response for validating a DNS zone file.
public struct validateZoneFileResponse: Codable {
    /// Number of records parsed from the zone file.
    public let parsed_records: Int
    /// Records that passed validation checks.
    public let valid_records: [Record]
}

// © 2025 Contexter alias Benedikt Eickhoff 🛡️ All rights reserved.

