import Foundation
import Yams

public func loadRoleGuardRules(from path: URL? = nil, environment: [String: String] = ProcessInfo.processInfo.environment) -> [String: String] {
    let url = path ?? environment["ROLE_GUARD_PATH"].map(URL.init(fileURLWithPath:)) ?? URL(fileURLWithPath: "Configuration/roleguard.yml")
    guard FileManager.default.fileExists(atPath: url.path), let text = try? String(contentsOf: url, encoding: .utf8) else { return [:] }
    do {
        if let yaml = try Yams.load(yaml: text) as? [String: Any], let rules = yaml["rules"] as? [String: String] {
            return rules
        }
    } catch {
        // ignore parse errors
    }
    return [:]
}

// © 2025 Contexter alias Benedikt Eickhoff 🛡️ All rights reserved.

