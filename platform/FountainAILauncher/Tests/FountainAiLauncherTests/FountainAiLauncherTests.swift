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

    /// Verifies the ``Service`` initializer assigns all properties correctly.
    func testServiceInitializerStoresArguments() {
        let service = Service(name: "Demo", binaryPath: "/bin/echo", arguments: ["hi"], port: 42, healthPath: "/health")
        XCTAssertEqual(service.name, "Demo")
        XCTAssertEqual(service.binaryPath, "/bin/echo")
        XCTAssertEqual(service.arguments, ["hi"])
        XCTAssertEqual(service.port, 42)
        XCTAssertEqual(service.healthPath, "/health")
        XCTAssertFalse(service.shouldRestart)
    }

    /// Ensures default initializer uses empty arguments and no health settings.
    func testServiceDefaults() {
        let service = Service(name: "Bare", binaryPath: "/bin/echo")
        XCTAssertTrue(service.arguments.isEmpty)
        XCTAssertNil(service.port)
        XCTAssertNil(service.healthPath)
        XCTAssertFalse(service.shouldRestart)
    }

    /// Decoding JSON manifest into services works.
    func testServiceDecoding() throws {
        let json = """
        [{"name":"X","binaryPath":"/bin/echo","shouldRestart":true}]
        """.data(using: .utf8)!
        let decoded = try JSONDecoder().decode([Service].self, from: json)
        XCTAssertEqual(decoded.count, 1)
        XCTAssertTrue(decoded[0].shouldRestart)
    }
}

// © 2025 Contexter alias Benedikt Eickhoff 🛡️ All rights reserved.
