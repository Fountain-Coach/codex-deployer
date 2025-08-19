import XCTest
@testable import SandboxRunner

final class BwrapRunnerTests: XCTestCase {
    func testMountIsolation() throws {
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
            arguments: ["-c", "echo hi > /work/out && echo fail >> /inputs/input.txt || true"],
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

    func testCgroupEnforcement() throws {
        let fm = FileManager.default
        let cgRoot = fm.temporaryDirectory.appendingPathComponent(UUID().uuidString)
        try fm.createDirectory(at: cgRoot, withIntermediateDirectories: true)

        let runner = BwrapRunner(cgroupRoot: cgRoot)
        let limits = CgroupLimits(memoryMax: "1024", cpuMax: "50000 100000", pidsMax: "4")
        let path = try runner.prepareCgroup(limits: limits)
        try runner.add(pid: 1234, toCgroup: path)

        XCTAssertEqual(try String(contentsOf: path.appendingPathComponent("memory.max"), encoding: .utf8), "1024\n")
        XCTAssertEqual(try String(contentsOf: path.appendingPathComponent("cpu.max"), encoding: .utf8), "50000 100000\n")
        XCTAssertEqual(try String(contentsOf: path.appendingPathComponent("pids.max"), encoding: .utf8), "4\n")
        XCTAssertEqual(try String(contentsOf: path.appendingPathComponent("cgroup.procs"), encoding: .utf8), "1234\n")
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
