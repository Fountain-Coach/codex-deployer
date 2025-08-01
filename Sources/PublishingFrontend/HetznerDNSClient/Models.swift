// Models for Hetzner DNS API

public struct BulkRecordsCreateRequest: Codable {
    public let records: [RecordCreate]
}

public struct BulkRecordsCreateResponse: Codable {
    public let invalid_records: [RecordCreate]
    public let records: [Record]
    public let valid_records: [RecordCreate]
}

public struct BulkRecordsUpdateRequest: Codable {
    public let records: [[String: String]]
}

public struct BulkRecordsUpdateResponse: Codable {
    public let failed_records: [RecordUpdate]
    public let records: [Record]
}

public struct RecordUpdate: Codable {
    public let id: String
    public let name: String
    public let ttl: Int
    public let type: String
    public let value: String
    public let zone_id: String
}

public struct PrimaryServer: Codable {
    public let address: String
    public let created: String
    public let id: String
    public let modified: String
    public let port: Int
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

public struct validateZoneFileResponse: Codable {
    public let parsed_records: Int
    public let valid_records: [Record]
}

