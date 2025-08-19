import XCTest
import SandboxRunner

final class SecurityTests: XCTestCase {
    func testNetworkDenied() throws {
        try XCTSkipIf(!Self.canUseBubblewrap, "bubblewrap not functional")
        let fm = FileManager.default
        let work = fm.temporaryDirectory.appendingPathComponent(UUID().uuidString)
        try fm.createDirectory(at: work, withIntermediateDirectories: true)
        let runner = BwrapRunner()
        let result = try runner.run(
            executable: "/bin/sh",
            arguments: ["-c", "curl -sSf http://example.com >/dev/null && echo ok || echo fail"],
            inputs: [],
            workDirectory: work,
            allowNetwork: false,
            timeout: 5,
            limits: nil
        )
        XCTAssertEqual(result.stdout.trimmingCharacters(in: .whitespacesAndNewlines), "fail")
    }

    func testFilesystemIsolation() throws {
        try XCTSkipIf(!Self.canUseBubblewrap, "bubblewrap not functional")
        let fm = FileManager.default
        let tmp = fm.temporaryDirectory
        let input = tmp.appendingPathComponent("input.txt")
        try "hello".write(to: input, atomically: true, encoding: .utf8)
        let work = tmp.appendingPathComponent(UUID().uuidString)
        try fm.createDirectory(at: work, withIntermediateDirectories: true)
        let runner = BwrapRunner()
        _ = try runner.run(
            executable: "/bin/sh",
            arguments: ["-c", "echo hi > /work/out && echo nope >> /inputs/input.txt || true"],
            inputs: [input],
            workDirectory: work,
            allowNetwork: false,
            timeout: 5,
            limits: nil
        )
        XCTAssertEqual(try String(contentsOf: input, encoding: .utf8), "hello")
        let outPath = work.appendingPathComponent("out")
        XCTAssertEqual(try String(contentsOf: outPath, encoding: .utf8).trimmingCharacters(in: .whitespacesAndNewlines), "hi")
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
