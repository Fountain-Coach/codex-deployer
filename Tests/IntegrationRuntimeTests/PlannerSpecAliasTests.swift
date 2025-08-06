import XCTest

final class PlannerSpecAliasTests: XCTestCase {
    func testPlannerV0AliasesV1() throws {
        let path = "Sources/FountainOps/FountainAi/openAPI/v0/planner.yml"
        let text = try String(contentsOfFile: path, encoding: .utf8)
        XCTAssertTrue(text.contains("$ref: \"../v1/planner.yml\""))
    }
}

// © 2025 Contexter alias Benedikt Eickhoff 🛡️ All rights reserved.
