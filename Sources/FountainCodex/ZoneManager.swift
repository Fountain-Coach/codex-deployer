import Foundation
import Yams
import Dispatch
#if os(Linux)
import Glibc
#else
import Darwin
#endif

/// Actor responsible for managing DNS zone records with persistent YAML storage.
public actor ZoneManager {
    private var cache: [String: String]
    private let fileURL: URL
    private let signer: DNSSECSigner?
    private var timer: DispatchSourceTimer?
    private var lastModified: Date
    private let enableGitCommits: Bool

    /// Loads the zone cache from the provided YAML file if it exists.
    /// - Parameters:
    ///   - fileURL: Location of the YAML zone file on disk.
    ///   - signer: Optional DNSSEC signer used to generate zone signatures.
    public init(fileURL: URL, signer: DNSSECSigner? = nil, enableGitCommits: Bool = true) throws {
        self.fileURL = fileURL
        self.signer = signer
        self.enableGitCommits = enableGitCommits
        if let data = try? Data(contentsOf: fileURL),
           let string = String(data: data, encoding: .utf8),
           let loaded = try Yams.load(yaml: string) as? [String: String] {
            self.cache = loaded
        } else {
            self.cache = [:]
        }
        let attrs = try? FileManager.default.attributesOfItem(atPath: fileURL.path)
        self.lastModified = (attrs?[.modificationDate] as? Date) ?? Date()
        Task { await self.startWatching() }
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
        if let signer {
            let sig = try signer.sign(zone: yaml)
            try Data(sig).write(to: fileURL.appendingPathExtension("sig"))
        }
        if enableGitCommits {
            gitCommit(message: "Update zone file")
        }
    }

    /// Reloads the zone cache from disk when the file has changed.
    public func reload() {
        let attrs = try? FileManager.default.attributesOfItem(atPath: fileURL.path)
        if let mod = attrs?[.modificationDate] as? Date,
           mod > lastModified,
           let data = try? Data(contentsOf: fileURL),
           let string = String(data: data, encoding: .utf8),
           let loaded = try? Yams.load(yaml: string) as? [String: String] {
            cache = loaded
            lastModified = mod
        }
    }

    private func startWatching() {
        let timer = DispatchSource.makeTimerSource(queue: DispatchQueue.global())
        timer.schedule(deadline: .now() + 1, repeating: 1)
        timer.setEventHandler(handler: { @Sendable [weak self] in
            Task { await self?.reload() }
        })
        timer.resume()
        self.timer = timer
    }

    private func gitCommit(message: String) {
        let dir = fileURL.deletingLastPathComponent()
        guard FileManager.default.fileExists(atPath: dir.appendingPathComponent(".git").path) else { return }

        let add = Process()
        add.executableURL = URL(fileURLWithPath: "/usr/bin/git")
        add.currentDirectoryURL = dir
        add.arguments = ["add", fileURL.lastPathComponent]
        try? add.run()
        add.waitUntilExit()

        let commit = Process()
        commit.executableURL = URL(fileURLWithPath: "/usr/bin/git")
        commit.currentDirectoryURL = dir
        commit.arguments = ["commit", "-m", message]
        commit.environment = [
            "GIT_AUTHOR_NAME": "Codex",
            "GIT_AUTHOR_EMAIL": "codex@example.com",
            "GIT_COMMITTER_NAME": "Codex",
            "GIT_COMMITTER_EMAIL": "codex@example.com"
        ]
        try? commit.run()
        commit.waitUntilExit()
    }
}

// © 2025 Contexter alias Benedikt Eickhoff 🛡️ All rights reserved.
