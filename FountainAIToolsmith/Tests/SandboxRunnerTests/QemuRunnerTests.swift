import XCTest
@testable import SandboxRunner

final class QemuRunnerTests: XCTestCase {
    func testWorkIsolation() throws {
        try XCTSkipIf(!Self.canUseQemu, "qemu not functional")
        let fm = FileManager.default
        let tmp = fm.temporaryDirectory
        let work = tmp.appendingPathComponent(UUID().uuidString)
        try fm.createDirectory(at: work, withIntermediateDirectories: true)
        let runner = QemuRunner(image: Self.imageURL)
        _ = try runner.run(
            executable: "/bin/sh",
            arguments: ["-c", "echo hi > /work/out"],
            inputs: [],
            workDirectory: work,
            allowNetwork: false,
            timeout: 30,
            limits: nil
        )
        let outPath = work.appendingPathComponent("out")
        XCTAssertEqual(try String(contentsOf: outPath, encoding: .utf8).trimmingCharacters(in: .whitespacesAndNewlines), "hi")
    }

    func testNetworkDisabled() throws {
        try XCTSkipIf(!Self.canUseQemu, "qemu not functional")
        let fm = FileManager.default
        let work = fm.temporaryDirectory.appendingPathComponent(UUID().uuidString)
        try fm.createDirectory(at: work, withIntermediateDirectories: true)
        let runner = QemuRunner(image: Self.imageURL)
        let result = try runner.run(
            executable: "/bin/sh",
            arguments: ["-c", "curl -sSf http://example.com >/dev/null && echo ok || echo fail"],
            inputs: [],
            workDirectory: work,
            allowNetwork: false,
            timeout: 30,
            limits: nil
        )
        XCTAssertEqual(result.stdout.trimmingCharacters(in: .whitespacesAndNewlines), "fail")
    }

    func testPathGuard() throws {
        try XCTSkipIf(!Self.canUseQemu, "qemu not functional")
        let fm = FileManager.default
        let work = fm.temporaryDirectory.appendingPathComponent(UUID().uuidString)
        try fm.createDirectory(at: work, withIntermediateDirectories: true)
        let runner = QemuRunner(image: Self.imageURL)
        XCTAssertThrowsError(
            try runner.run(
                executable: "/bin/touch",
                arguments: ["/etc/evil"],
                inputs: [],
                workDirectory: work,
                allowNetwork: false,
                timeout: 30,
                limits: nil
            )
        )
    }

    private static let canUseQemu: Bool = {
        guard let image = ProcessInfo.processInfo.environment["QEMU_TEST_IMAGE"],
              FileManager.default.fileExists(atPath: image),
              FileManager.default.isExecutableFile(atPath: "/usr/bin/qemu-system-x86_64") else {
            return false
        }
        return true
    }()

    private static var imageURL: URL {
        URL(fileURLWithPath: ProcessInfo.processInfo.environment["QEMU_TEST_IMAGE"]!)
    }
}

// © 2025 Contexter alias Benedikt Eickhoff 🛡️ All rights reserved.
