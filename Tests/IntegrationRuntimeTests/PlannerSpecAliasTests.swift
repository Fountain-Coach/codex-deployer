import XCTest
import Foundation

final class PlannerSpecAliasTests: XCTestCase {
    func testPlannerV0AliasesV1() throws {
        let fileURL = URL(fileURLWithPath: #filePath)
            .deletingLastPathComponent()
            .appendingPathComponent("Fixtures/planner.yml")
        let text = try String(contentsOf: fileURL, encoding: .utf8)
        XCTAssertTrue(text.contains("$ref: \"../v1/planner.yml\""))
    }
}

// © 2025 Contexter alias Benedikt Eickhoff 🛡️ All rights reserved.
