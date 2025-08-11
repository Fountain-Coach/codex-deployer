import NIOCore
import Logging
import NIOConcurrencyHelpers
import Foundation

/// Minimal DNS engine capable of parsing A record queries and responding from an in-memory zone cache.
public struct DNSEngine {
    /// Thread-safe mapping of fully qualified domain names to IPv4 addresses.
    private let zoneCache: NIOLockedValueBox<[String: String]>
    private let logger = Logger(label: "DNSEngine")
    /// Optional DNSSEC signer used for zone signing and verification.
    private let signer: DNSSECSigner?

    /// Creates a new engine with the provided zone cache.
    /// - Parameters:
    ///   - zoneCache: Dictionary of domain names to IPv4 addresses.
    ///   - signer: Optional ``DNSSECSigner`` for zone signing.
    public init(zoneCache: [String: String], signer: DNSSECSigner? = nil) {
        self.zoneCache = NIOLockedValueBox(zoneCache)
        self.signer = signer
    }

    /// Creates a new engine from a ``ZoneManager`` instance.
    /// - Parameters:
    ///   - zoneManager: Zone manager providing records.
    ///   - signer: Optional ``DNSSECSigner`` for zone signing.
    public init(zoneManager: ZoneManager, signer: DNSSECSigner? = nil) async {
        let records = await zoneManager.allRecords()
        var cache: [String: String] = [:]
        for (name, record) in records where record.type == "A" {
            cache[name] = record.value
        }
        self.zoneCache = NIOLockedValueBox(cache)
        self.signer = signer
    }

    /// Updates or inserts a record in the zone cache.
    public func updateRecord(name: String, ip: String) {
        zoneCache.withLockedValue { $0[name] = ip }
    }

    /// Generates a signature for the current zone if a signer is configured.
    /// - Returns: Signature bytes or `nil` when no signer is set.
    public func signZone() throws -> Data? {
        guard let signer else { return nil }
        let zone = zoneCache.withLockedValue { cache in
            cache.map { "\($0.key) \($0.value)" }.sorted().joined(separator: "\n")
        }
        return try signer.sign(zone: zone)
    }

    /// Verifies the provided signature against the current zone state.
    /// - Parameter signature: Signature bytes to verify.
    /// - Returns: `nil` if no signer is configured, otherwise the verification result.
    public func verifyZone(signature: Data) -> Bool? {
        guard let signer else { return nil }
        let zone = zoneCache.withLockedValue { cache in
            cache.map { "\($0.key) \($0.value)" }.sorted().joined(separator: "\n")
        }
        return signer.verify(zone: zone, signature: signature)
    }

    /// Parses an incoming DNS query and constructs a response if the record exists in the cache.
    /// - Parameter buffer: Byte buffer containing the DNS query.
    /// - Returns: A byte buffer with the DNS response or `nil` if the record is unknown or parsing fails.
    public func handleQuery(buffer: inout ByteBuffer) -> ByteBuffer? {
        guard let parser = DNSParser(buffer: &buffer) else {
            logger.warning("Failed to parse query")
            Task { await DNSMetrics.shared.record(query: "invalid", hit: false) }
            return nil
        }
        let response = zoneCache.withLockedValue { cache -> ByteBuffer? in
            guard let ip = cache[parser.name] else { return nil }
            return parser.makeResponse(ip: ip)
        }
        Task { await DNSMetrics.shared.record(query: parser.name, hit: response != nil) }
        logger.info("dns_query", metadata: ["name": .string(parser.name), "hit": .string(String(response != nil))])
        return response
    }
}

/// Simple DNS message parser for queries and responses.
struct DNSParser {
    let id: UInt16
    let name: String

    init?(buffer: inout ByteBuffer) {
        guard buffer.readableBytes >= 12,
              let id = buffer.readInteger(as: UInt16.self) else { return nil }
        self.id = id
        // Skip flags and counts
        buffer.moveReaderIndex(forwardBy: 10)
        var labels: [String] = []
        while let length: UInt8 = buffer.readInteger(as: UInt8.self), length > 0 {
            guard let bytes = buffer.readBytes(length: Int(length)),
                  let label = String(bytes: bytes, encoding: .utf8) else {
                return nil
            }
            labels.append(label)
        }
        // Skip QTYPE and QCLASS
        guard buffer.readInteger(as: UInt16.self) != nil,
              buffer.readInteger(as: UInt16.self) != nil else { return nil }
        self.name = labels.joined(separator: ".")
    }

    func makeResponse(ip: String) -> ByteBuffer? {
        var buf = ByteBufferAllocator().buffer(capacity: 512)
        buf.writeInteger(id, as: UInt16.self)
        buf.writeInteger(UInt16(0x8180), as: UInt16.self) // standard response
        buf.writeInteger(UInt16(1), as: UInt16.self) // QDCOUNT
        buf.writeInteger(UInt16(1), as: UInt16.self) // ANCOUNT
        buf.writeInteger(UInt16(0), as: UInt16.self) // NSCOUNT
        buf.writeInteger(UInt16(0), as: UInt16.self) // ARCOUNT

        // question section
        for label in name.split(separator: ".") {
            let bytes = Array(label.utf8)
            buf.writeInteger(UInt8(bytes.count), as: UInt8.self)
            buf.writeBytes(bytes)
        }
        buf.writeInteger(UInt8(0), as: UInt8.self)
        buf.writeInteger(UInt16(1), as: UInt16.self) // QTYPE A
        buf.writeInteger(UInt16(1), as: UInt16.self) // QCLASS IN

        // answer section
        buf.writeInteger(UInt16(0xC00C), as: UInt16.self) // pointer to name at offset 12
        buf.writeInteger(UInt16(1), as: UInt16.self) // TYPE A
        buf.writeInteger(UInt16(1), as: UInt16.self) // CLASS IN
        buf.writeInteger(UInt32(300), as: UInt32.self) // TTL
        buf.writeInteger(UInt16(4), as: UInt16.self) // RDLENGTH

        let octets = ip.split(separator: ".").compactMap { UInt8($0) }
        guard octets.count == 4 else { return nil }
        buf.writeBytes(octets)
        return buf
    }
}

// © 2025 Contexter alias Benedikt Eickhoff 🛡️ All rights reserved.
