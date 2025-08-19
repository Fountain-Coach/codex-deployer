import XCTest
import SandboxRunner
@testable import ToolServer

final class PerformanceTests: XCTestCase {
    func testColdBwrapPerformance() throws {
        try XCTSkipIf(!Self.canUseBubblewrap, "bubblewrap not functional")
        let fm = FileManager.default
        let work = fm.temporaryDirectory.appendingPathComponent(UUID().uuidString)
        try fm.createDirectory(at: work, withIntermediateDirectories: true)
        let runner = BwrapRunner()
        let start = Date()
        _ = try runner.run(
            executable: "/bin/true",
            arguments: [],
            inputs: [],
            workDirectory: work,
            allowNetwork: false,
            timeout: 5,
            limits: nil
        )
        let duration = Date().timeIntervalSince(start) * 1000
        XCTAssertLessThanOrEqual(duration, 150)
    }

    func testVMSnapshotPerformance() throws {
        let qemuPath = "/usr/bin/qemu-system-x86_64"
        let qemuImgPath = "/usr/bin/qemu-img"
        try XCTSkipIf(!FileManager.default.isExecutableFile(atPath: qemuPath) || !FileManager.default.isExecutableFile(atPath: qemuImgPath), "qemu missing")
        let fm = FileManager.default
        let tmp = fm.temporaryDirectory.appendingPathComponent(UUID().uuidString)
        try fm.createDirectory(at: tmp, withIntermediateDirectories: true)
        let image = tmp.appendingPathComponent("disk.qcow2")
        let img = Process()
        img.executableURL = URL(fileURLWithPath: qemuImgPath)
        img.arguments = ["create", "-f", "qcow2", image.path, "64M"]
        try img.run()
        img.waitUntilExit()
        let runner = QemuRunner(image: image)
        let start = Date()
        try? runner.run(executable: "/bin/true", workDirectory: tmp, allowNetwork: false, timeout: 2)
        let duration = Date().timeIntervalSince(start) * 1000
        XCTAssertLessThanOrEqual(duration, 2000)
    }

    func testImageConversionPerformance() throws {
        try XCTSkipIf(!FileManager.default.isExecutableFile(atPath: "/usr/bin/convert"), "imagemagick missing")
        let fm = FileManager.default
        let tmp = fm.temporaryDirectory.appendingPathComponent(UUID().uuidString)
        try fm.createDirectory(at: tmp, withIntermediateDirectories: true)
        let input = tmp.appendingPathComponent("input.jpg")
        let create = Process()
        create.executableURL = URL(fileURLWithPath: "/usr/bin/convert")
        create.arguments = ["-size", "4000x4000", "xc:white", "-quality", "85", input.path]
        try create.run()
        create.waitUntilExit()
        let attrs = try fm.attributesOfItem(atPath: input.path)
        let size = attrs[.size] as? NSNumber
        XCTAssertGreaterThanOrEqual(size?.intValue ?? 0, 1_000_000)
        let adapter = ImageMagickAdapter()
        let start = Date()
        let (data, code) = try adapter.run(args: [input.path, "-resize", "1024", "png:-"])
        let duration = Date().timeIntervalSince(start) * 1000
        XCTAssertEqual(code, 0)
        XCTAssertLessThanOrEqual(duration, 500)
        XCTAssertEqual(data.prefix(8), Data([0x89, 0x50, 0x4E, 0x47, 0x0D, 0x0A, 0x1A, 0x0A]))
    }
}

extension PerformanceTests {
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
