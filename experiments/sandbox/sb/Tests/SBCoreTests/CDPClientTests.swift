import XCTest
@testable import SBCore

final class CDPClientTests: XCTestCase {
    func testCommandEncoding() throws {
        let cmd = CDPClient.Command(id: 1, method: "Page.navigate", params: ["url": "https://example.com"])
        let data = try JSONEncoder().encode(cmd)
        let obj = try JSONSerialization.jsonObject(with: data) as? [String: Any]
        XCTAssertEqual(obj?["method"] as? String, "Page.navigate")
        let params = obj?["params"] as? [String: String]
        XCTAssertEqual(params?["url"], "https://example.com")
    }
}

// © 2025 Contexter alias Benedikt Eickhoff 🛡️ All rights reserved.
