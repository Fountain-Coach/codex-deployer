import NIOCore

/// Minimal DNS engine capable of parsing A record queries and responding from an in-memory zone cache.
public struct DNSEngine {
    /// Mapping of fully qualified domain names to IPv4 addresses.
    public var zoneCache: [String: String]

    /// Creates a new engine with the provided zone cache.
    /// - Parameter zoneCache: Dictionary of domain names to IPv4 addresses.
    public init(zoneCache: [String: String]) {
        self.zoneCache = zoneCache
    }

    /// Parses an incoming DNS query and constructs a response if the record exists in the cache.
    /// - Parameter buffer: Byte buffer containing the DNS query.
    /// - Returns: A byte buffer with the DNS response or `nil` if the record is unknown or parsing fails.
    public func handleQuery(buffer: inout ByteBuffer) -> ByteBuffer? {
        guard let parser = DNSParser(buffer: &buffer),
              let ip = zoneCache[parser.name] else {
            return nil
        }
        return parser.makeResponse(ip: ip)
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
