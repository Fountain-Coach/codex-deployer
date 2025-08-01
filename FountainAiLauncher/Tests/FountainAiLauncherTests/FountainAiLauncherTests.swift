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

    func testTerminateAllStopsProcesses() throws {
        let supervisor = Supervisor()
        let service = Service(name: "Sleep", binaryPath: "/bin/sleep", arguments: ["5"])
        let process = try supervisor.start(service: service)
        XCTAssertTrue(process.isRunning)
        supervisor.terminateAll()
        process.waitUntilExit()
        XCTAssertFalse(process.isRunning)
    }
}

// © 2025 Contexter alias Benedikt Eickhoff 🛡️ All rights reserved.
