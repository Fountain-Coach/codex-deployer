import XCTest
@testable import OpenAPICurator

final class OpenAPICuratorTests: XCTestCase {
    func testRuleApplicationRenamesOperations() {
        let spec = Spec(operations: ["getUser"])
        let rules = Rules(renames: ["getUser": "fetchUser"])
        let result = curate(specs: [spec], rules: rules)
        XCTAssertTrue(result.report.appliedRules.contains("getUser->fetchUser"))
        XCTAssertEqual(result.spec.operations, ["fetchUser"])
    }

    func testCollisionResolverAddsSuffix() {
        let spec1 = Spec(operations: ["op"])
        let spec2 = Spec(operations: ["op"])
        let result = curate(specs: [spec1, spec2], rules: Rules())
        XCTAssertEqual(result.report.collisions, ["op"])
        XCTAssertEqual(result.spec.operations, ["op", "op_1"])
    }
}
