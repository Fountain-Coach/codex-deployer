import XCTest
import Foundation
import Yams

final class BootstrapDiscriminatorTests: XCTestCase {
    func testStreamEventDiscriminatorMapping() throws {
        let text = try String(contentsOfFile: "openapi/v1/bootstrap.yml")
        let yaml = try Yams.load(yaml: text) as? [String: Any]
        let schemas = (yaml?["components"] as? [String: Any])?["schemas"] as? [String: Any]
        guard let se = schemas?["StreamEvent"] as? [String: Any],
              let disc = se["discriminator"] as? [String: Any],
              let mapping = disc["mapping"] as? [String: String] else {
            return XCTFail("StreamEvent discriminator mapping missing")
        }
        XCTAssertEqual(mapping["started"], "#/components/schemas/StreamStartedData")
        XCTAssertEqual(mapping["complete"], "#/components/schemas/StreamCompleteData")
        XCTAssertNotNil(schemas?["StreamStartedData"]) ; XCTAssertNotNil(schemas?["StreamCompleteData"]) 
        func enumHas(_ name: String, value: String) -> Bool {
            guard let sch = schemas?[name] as? [String: Any],
                  let props = sch["properties"] as? [String: Any],
                  let st = props["status"] as? [String: Any],
                  let en = st["enum"] as? [String] else { return false }
            return en.contains(value)
        }
        XCTAssertTrue(enumHas("StreamStartedData", value: "started"))
    }
}

