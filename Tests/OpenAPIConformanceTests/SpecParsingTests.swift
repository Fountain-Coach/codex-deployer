import XCTest
import Foundation
import Yams

final class SpecParsingTests: XCTestCase {
    func testBaselineAwarenessYAMLParsesAndHasPaths() throws {
        let url = URL(fileURLWithPath: "openapi/v1/baseline-awareness.yml")
        let text = try String(contentsOf: url)
        let yaml = try Yams.load(yaml: text) as? [String: Any]
        let paths = yaml?["paths"] as? [String: Any]
        XCTAssertNotNil(paths)
        let needed = ["/corpus/init", "/corpus/baseline", "/corpus/drift", "/corpus/patterns", "/corpus/reflections", "/corpus/history", "/corpus/semantic-arc"]
        for p in needed { XCTAssertNotNil(paths?[p]) }
    }

    func testBootstrapYAMLParsesAndHasPaths() throws {
        let url = URL(fileURLWithPath: "openapi/v1/bootstrap.yml")
        let text = try String(contentsOf: url)
        let yaml = try Yams.load(yaml: text) as? [String: Any]
        let paths = yaml?["paths"] as? [String: Any]
        XCTAssertNotNil(paths)
        let needed = ["/bootstrap/corpus/init", "/bootstrap/roles/seed", "/bootstrap/baseline"]
        for p in needed { XCTAssertNotNil(paths?[p]) }
    }
}

// © 2025 Contexter alias Benedikt Eickhoff 🛡️ All rights reserved.

