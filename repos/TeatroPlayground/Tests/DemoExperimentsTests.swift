import XCTest
@testable import TeatroPlaygroundUI

final class DemoExperimentsTests: XCTestCase {
    @MainActor
    func testDemoExperimentRendersNonEmpty() async throws {
        for experiment in DemoExperiments.all {
            let output = experiment.view.render()
            XCTAssertFalse(output.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty, "\(experiment.title) rendered empty output")
        }
    }
}
