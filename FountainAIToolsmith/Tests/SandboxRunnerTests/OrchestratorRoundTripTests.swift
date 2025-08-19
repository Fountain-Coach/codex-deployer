import XCTest
import Toolsmith
import SandboxRunner

final class OrchestratorRoundTripTests: XCTestCase {
    func testToolsmithBwrapRoundTrip() throws {
        try XCTSkipIf(!Self.canUseBubblewrap, "bubblewrap not functional")
        let fm = FileManager.default
        let work = fm.temporaryDirectory.appendingPathComponent(UUID().uuidString)
        try fm.createDirectory(at: work, withIntermediateDirectories: true)
        let runner = BwrapRunner()
        let toolsmith = Toolsmith()
        var result: SandboxResult?
        let requestID = try toolsmith.run(tool: "echo") {
            result = try runner.run(
                executable: "/bin/echo",
                arguments: ["hello"],
                inputs: [],
                workDirectory: work,
                allowNetwork: false,
                timeout: 5,
                limits: nil
            )
        }
        XCTAssertFalse(requestID.isEmpty)
        XCTAssertEqual(result?.stdout.trimmingCharacters(in: .whitespacesAndNewlines), "hello")
        XCTAssertEqual(result?.exitCode, 0)
    }

    private static let canUseBubblewrap: Bool = {
        let process = Process()
        process.executableURL = URL(fileURLWithPath: "/usr/bin/bwrap")
        process.arguments = ["--ro-bind", "/", "/", "/bin/true"]
        do {
            try process.run()
            process.waitUntilExit()
            return process.terminationStatus == 0
        } catch {
            return false
        }
    }()
}

// © 2025 Contexter alias Benedikt Eickhoff 🛡️ All rights reserved.
