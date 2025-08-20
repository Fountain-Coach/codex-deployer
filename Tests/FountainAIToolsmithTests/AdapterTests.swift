import XCTest
@testable import ToolServer

final class AdapterTests: XCTestCase {
    func testProcessAdapterPassesArgumentsAndCapturesOutput() throws {
        let fm = FileManager.default
        let script = fm.temporaryDirectory.appendingPathComponent("echo_args.sh")
        let scriptContent = "#!/bin/sh\necho $@"
        try scriptContent.write(to: script, atomically: true, encoding: .utf8)
        try fm.setAttributes([.posixPermissions: 0o755], ofItemAtPath: script.path)
        let adapter = ProcessAdapter(tool: "test", executable: script.path)
        let (data, code) = try adapter.run(args: ["hello", "world"])
        XCTAssertEqual(code, 0)
        XCTAssertEqual(String(data: data, encoding: .utf8)?.trimmingCharacters(in: .whitespacesAndNewlines), "hello world")
    }

    func testImageMagickAdapterVersion() throws {
        try XCTSkipIf(!FileManager.default.isExecutableFile(atPath: "/usr/bin/convert"), "imagemagick missing")
        let adapter = ImageMagickAdapter()
        let (data, code) = try adapter.run(args: ["-version"])
        XCTAssertEqual(code, 0)
        XCTAssertTrue(String(data: data, encoding: .utf8)?.contains("ImageMagick") ?? false)
    }

    func testFFmpegAdapterVersion() throws {
        try XCTSkipIf(!FileManager.default.isExecutableFile(atPath: "/usr/bin/ffmpeg"), "ffmpeg missing")
        let adapter = FFmpegAdapter()
        let (data, code) = try adapter.run(args: ["-version"])
        XCTAssertEqual(code, 0)
        XCTAssertTrue(String(data: data, encoding: .utf8)?.contains("ffmpeg") ?? false)
    }

    func testExifToolAdapterVersion() throws {
        try XCTSkipIf(!FileManager.default.isExecutableFile(atPath: "/usr/bin/exiftool"), "exiftool missing")
        let adapter = ExifToolAdapter()
        let (data, code) = try adapter.run(args: ["-ver"])
        XCTAssertEqual(code, 0)
        XCTAssertFalse(String(data: data, encoding: .utf8)?.isEmpty ?? true)
    }

    func testPandocAdapterVersion() throws {
        try XCTSkipIf(!FileManager.default.isExecutableFile(atPath: "/usr/bin/pandoc"), "pandoc missing")
        let adapter = PandocAdapter()
        let (data, code) = try adapter.run(args: ["--version"])
        XCTAssertEqual(code, 0)
        XCTAssertTrue(String(data: data, encoding: .utf8)?.contains("pandoc") ?? false)
    }

    func testLibPlistAdapterHelp() throws {
        try XCTSkipIf(!FileManager.default.isExecutableFile(atPath: "/usr/bin/plutil"), "plutil missing")
        let adapter = LibPlistAdapter()
        let (data, code) = try adapter.run(args: ["-help"])
        XCTAssertTrue([0, 1].contains(code), "Unexpected exit code: \(code)")
        // plutil -help exits 0 on some platforms and 1 on others
        XCTAssertTrue(String(data: data, encoding: .utf8)?.contains("plutil") ?? false)
    }
}

// © 2025 Contexter alias Benedikt Eickhoff 🛡️ All rights reserved.
