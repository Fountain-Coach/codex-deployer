import Foundation
import Yams

/// Actor responsible for managing DNS zone records with persistent YAML storage.
public actor ZoneManager {
    private var cache: [String: String]
    private let fileURL: URL

    /// Loads the zone cache from the provided YAML file if it exists.
    /// - Parameter fileURL: Location of the YAML zone file on disk.
    public init(fileURL: URL) throws {
        self.fileURL = fileURL
        if let data = try? Data(contentsOf: fileURL),
           let string = String(data: data, encoding: .utf8),
           let loaded = try Yams.load(yaml: string) as? [String: String] {
            self.cache = loaded
        } else {
            self.cache = [:]
        }
    }

    /// Returns the IPv4 address associated with the given domain name.
    /// - Parameter name: Fully qualified domain name.
    /// - Returns: The IPv4 address string if present.
    public func ip(for name: String) -> String? {
        cache[name]
    }

    /// Updates or inserts a DNS record and persists it to disk.
    /// - Parameters:
    ///   - name: Fully qualified domain name.
    ///   - ip: IPv4 address string.
    public func set(name: String, ip: String) throws {
        cache[name] = ip
        try persist()
    }

    /// Returns the current in-memory zone cache.
    public func allRecords() -> [String: String] {
        cache
    }

    private func persist() throws {
        let yaml = try Yams.dump(object: cache)
        try yaml.write(to: fileURL, atomically: true, encoding: .utf8)
    }
}

// © 2025 Contexter alias Benedikt Eickhoff 🛡️ All rights reserved.
