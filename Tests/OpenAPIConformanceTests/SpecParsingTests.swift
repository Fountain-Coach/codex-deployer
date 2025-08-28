import XCTest
import Foundation
import Yams
@testable import AwarenessService

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

    func testOperationIdsPresent() throws {
        let files = [
            "openapi/v1/baseline-awareness.yml",
            "openapi/v1/bootstrap.yml"
        ]
        for f in files {
            let text = try String(contentsOfFile: f)
            let yaml = try Yams.load(yaml: text) as? [String: Any]
            let paths = yaml?["paths"] as? [String: Any]
            XCTAssertNotNil(paths)
            for (_, methodMapAny) in paths ?? [:] {
                guard let methodMap = methodMapAny as? [String: Any] else { continue }
                for (_, opAny) in methodMap {
                    if let op = opAny as? [String: Any] {
                        XCTAssertNotNil(op["operationId"], "operationId missing in \(f)")
                    }
                }
            }
        }
    }
}

    func testRuntimeValidationAgainstYAMLSchema() throws {
        let url = URL(fileURLWithPath: "openapi/v1/baseline-awareness.yml")
        let text = try String(contentsOf: url)
        let yaml = try Yams.load(yaml: text) as? [String: Any]
        let components = yaml?["components"] as? [String: Any]
        let schemas = components?["schemas"] as? [String: Any]
        guard let histSchema = schemas?["HistorySummaryResponse"] as? [String: Any] else {
            return XCTFail("HistorySummaryResponse missing in spec")
        }
        let sample: [String: Any] = ["summary": "ok"]
        XCTAssertTrue(OpenAPISchemaValidator.validate(object: sample, against: histSchema))
    }

// © 2025 Contexter alias Benedikt Eickhoff 🛡️ All rights reserved.
