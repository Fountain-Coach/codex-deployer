import XCTest
@testable import FountainCodex

final class SpecLoaderTests: XCTestCase {
    func testLoadsJSONRemovingCopyright() throws {
        let json = "© 2025 Contexter alias Benedikt Eickhoff 🛡️\n{\"title\":\"API\",\"paths\":{}}"
        let url = FileManager.default.temporaryDirectory.appendingPathComponent("spec.json")
        try json.write(to: url, atomically: true, encoding: .utf8)
        let spec = try SpecLoader.load(from: url)
        XCTAssertEqual(spec.title, "API")
    }

    func testLoadsYAMLAndNormalizesInfoTitle() throws {
        let yaml = """
        info:
          title: Example
        paths: {}
        """
        let url = FileManager.default.temporaryDirectory.appendingPathComponent("spec.yml")
        try yaml.write(to: url, atomically: true, encoding: .utf8)
        let spec = try SpecLoader.load(from: url)
        XCTAssertEqual(spec.title, "Example")
    }
}

// © 2025 Contexter alias Benedikt Eickhoff 🛡️ All rights reserved.
