import XCTest
@testable import FountainAiLauncher

final class FountainAiLauncherTests: XCTestCase {
    func testServiceLaunch() throws {
        let supervisor = Supervisor()
        let service = Service(name: "Echo", binaryPath: "/usr/bin/env", arguments: ["true"])
        let process = try supervisor.start(service: service)
        process.waitUntilExit()
        XCTAssertEqual(process.terminationStatus, 0)
    }
}

// © 2025 Contexter alias Benedikt Eickhoff 🛡️ All rights reserved.
