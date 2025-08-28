import XCTest
@testable import gateway_server

final class RoleGuardConfigTests: XCTestCase {
    func testLoadRoleGuardRulesFromYAML() throws {
        let dir = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString)
        try FileManager.default.createDirectory(at: dir, withIntermediateDirectories: true)
        let file = dir.appendingPathComponent("roleguard.yml")
        let yaml = """
        rules:
          "/awareness": "admin"
          "/bootstrap": "admin"
        """
        try yaml.write(to: file, atomically: true, encoding: .utf8)
        let rules = loadRoleGuardRules(from: file)
        XCTAssertEqual(rules["/awareness"], "admin")
        XCTAssertEqual(rules["/bootstrap"], "admin")
    }
}

