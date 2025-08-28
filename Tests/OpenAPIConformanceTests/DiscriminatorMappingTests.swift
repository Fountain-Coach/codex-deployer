import XCTest
import Foundation
import Yams

final class DiscriminatorMappingTests: XCTestCase {
    func testHistoryEventDiscriminatorMappingMatchesSchemas() throws {
        let text = try String(contentsOfFile: "openapi/v1/baseline-awareness.yml")
        let yaml = try Yams.load(yaml: text) as? [String: Any]
        let schemas = (yaml?["components"] as? [String: Any])?["schemas"] as? [String: Any]
        guard let he = schemas?["HistoryEvent"] as? [String: Any],
              let disc = he["discriminator"] as? [String: Any],
              let mapping = disc["mapping"] as? [String: String] else {
            return XCTFail("HistoryEvent discriminator mapping missing")
        }
        // Ensure target schemas exist
        for (k, ref) in mapping {
            XCTAssertTrue(["baseline","reflection","drift","patterns"].contains(k))
            let name = ref.split(separator: "/").last.map(String.init) ?? ""
            XCTAssertNotNil(schemas?[name])
        }
        // Ensure enum values for each concrete schema match mapping keys
        func enumHas(_ name: String, value: String) -> Bool {
            guard let sch = schemas?[name] as? [String: Any],
                  let props = sch["properties"] as? [String: Any],
                  let t = props["type"] as? [String: Any],
                  let en = t["enum"] as? [String] else { return false }
            return en.contains(value)
        }
        XCTAssertTrue(enumHas("BaselineEvent", value: "baseline"))
        XCTAssertTrue(enumHas("ReflectionEvent", value: "reflection"))
        XCTAssertTrue(enumHas("DriftEvent", value: "drift"))
        XCTAssertTrue(enumHas("PatternsEvent", value: "patterns"))
    }
}

