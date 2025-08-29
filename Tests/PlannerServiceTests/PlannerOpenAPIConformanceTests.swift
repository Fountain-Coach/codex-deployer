import XCTest
import Yams

final class PlannerOpenAPIConformanceTests: XCTestCase {
    func testLoadPlannerSpec() throws {
        let root = URL(fileURLWithPath: FileManager.default.currentDirectoryPath)
        let url = root.appendingPathComponent("openapi/v1/planner.yml")
        let text = try String(contentsOf: url)
        let obj = try Yams.load(yaml: text)
        XCTAssertNotNil(obj)
    }
}

// © 2025 Contexter alias Benedikt Eickhoff 🛡️ All rights reserved.
