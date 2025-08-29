import XCTest
import Yams

final class FunctionCallerOpenAPIConformanceTests: XCTestCase {
    func testLoadSpec() throws {
        let root = URL(fileURLWithPath: FileManager.default.currentDirectoryPath)
        let url = root.appendingPathComponent("openapi/v1/function-caller.yml")
        let text = try String(contentsOf: url)
        let obj = try Yams.load(yaml: text)
        XCTAssertNotNil(obj)
    }
}

// © 2025 Contexter alias Benedikt Eickhoff 🛡️ All rights reserved.
