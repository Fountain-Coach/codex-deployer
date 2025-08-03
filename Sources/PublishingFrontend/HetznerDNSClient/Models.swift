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

/// Request payload for creating a new primary DNS server.
public struct PrimaryServerCreate: Codable {
    /// IP address of the primary server to register.
    public let address: String
    /// Port the server listens on.
    public let port: Int
    /// Identifier of the zone served by the primary server.
    public let zone_id: String
}

/// Response wrapping a single created primary server.
public struct PrimaryServerResponse: Codable {
    /// Newly created or fetched primary server.
    public let primary_server: PrimaryServer
}

/// Response containing an array of primary servers.
public struct PrimaryServersResponse: Codable {
    /// List of available primary servers.
    public let primary_servers: [PrimaryServer]
}

/// Representation of a DNS record returned by the API.
public struct Record: Codable {
    /// Creation timestamp for the record.
    public let created: String
    /// Unique identifier for the record.
    public let id: String
    /// Last modification timestamp.
    public let modified: String
    /// Hostname associated with the record.
    public let name: String
    /// Time to live value in seconds.
    public let ttl: Int
    /// DNS record type, such as `A` or `TXT`.
    public let type: String
    /// Value stored in the record.
    public let value: String
    /// Identifier of the zone that owns the record.
    public let zone_id: String
}

/// Request body for creating a single DNS record.
public struct RecordCreate: Codable {
    /// Hostname for the new record.
    public let name: String
    /// Time to live value in seconds.
    public let ttl: Int
    /// DNS record type, such as `A` or `TXT`.
    public let type: String
    /// Value to associate with the record.
    public let value: String
    /// Zone identifier where the record will be created.
    public let zone_id: String
}

/// Response wrapper containing a single record instance.
public struct RecordResponse: Codable {
    /// Record returned by the server.
    public let record: Record
}

/// Response returning multiple records.
public struct RecordsResponse: Codable {
    /// Array of DNS records.
    public let records: [Record]
}

/// Detailed representation of a DNS zone.
public struct Zone: Codable {
    /// Creation timestamp for the zone.
    public let created: String
    /// Unique identifier for the zone.
    public let id: String
    /// Flag indicating if the zone uses a secondary DNS setup.
    public let is_secondary_dns: Bool
    /// Hostname of the legacy DNS server.
    public let legacy_dns_host: String
    /// Nameserver entries for the legacy setup.
    public let legacy_ns: [String]
    /// Last modification timestamp.
    public let modified: String
    /// Zone name such as `example.com`.
    public let name: String
    /// Nameserver records assigned to the zone.
    public let ns: [String]
    /// Owner identifier for the zone.
    public let owner: String
    /// Indicates whether the zone is paused.
    public let paused: Bool
    /// Permission level of the current account.
    public let permission: String
    /// Project identifier the zone belongs to.
    public let project: String
    /// Number of records contained within the zone.
    public let records_count: Int
    /// Registrar information for the domain.
    public let registrar: String
    /// Operational status of the zone.
    public let status: String
    /// Default time to live value for records.
    public let ttl: Int
    /// TXT records used for verification purposes.
    public let txt_verification: [String: String]
    /// Timestamp when verification completed.
    public let verified: String
}

/// Request payload for creating a new DNS zone.
public struct ZoneCreateRequest: Codable {
    /// Name of the zone to create.
    public let name: String
    /// Default time to live value for the zone.
    public let ttl: Int
}

/// Response wrapper containing a single zone.
public struct ZoneResponse: Codable {
    /// Zone returned by the server.
    public let zone: Zone
}

/// Request payload for updating an existing zone.
public struct ZoneUpdateRequest: Codable {
    /// Updated zone name.
    public let name: String
    /// Updated default time to live value.
    public let ttl: Int
}

/// Response returning a list of zones with metadata.
public struct ZonesResponse: Codable {
    /// Additional response metadata.
    public let meta: [String: String]
    /// Zones returned by the API.
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

