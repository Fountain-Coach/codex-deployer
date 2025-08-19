import XCTest
@testable import Toolsmith
@testable import SandboxRunner
import ToolsmithSupport

final class ManifestChecksumTests: XCTestCase {
    func testChecksumMismatchDetection() throws {
        let fm = FileManager.default
        let dir = fm.temporaryDirectory.appendingPathComponent(UUID().uuidString)
        try fm.createDirectory(at: dir, withIntermediateDirectories: true)
        let image = dir.appendingPathComponent("test.qcow2")
        try Data("hello".utf8).write(to: image)
        let correctSha = try ToolManifest.sha256(of: image)
        let badManifest = ToolManifest(image: .init(name: "img", tarball: "img.tar.gz", sha256: "dead", qcow2: "test.qcow2", qcow2_sha256: "bad"), tools: [:], operations: [])
        XCTAssertThrowsError(try badManifest.verify(fileAt: image))
        let goodManifest = ToolManifest(image: .init(name: "img", tarball: "img.tar.gz", sha256: "dead", qcow2: "test.qcow2", qcow2_sha256: correctSha), tools: [:], operations: [])
        XCTAssertNoThrow(try goodManifest.verify(fileAt: image))
    }

    func testToolsmithLoadsManifest() throws {
        let fm = FileManager.default
        let dir = fm.temporaryDirectory.appendingPathComponent(UUID().uuidString)
        try fm.createDirectory(at: dir, withIntermediateDirectories: true)
        let manifest = ToolManifest(image: .init(name: "img", tarball: "t.tar.gz", sha256: "a", qcow2: "q.qcow2", qcow2_sha256: "b"), tools: ["swift": "v"], operations: ["swiftc"])
        let data = try JSONEncoder().encode(manifest)
        try data.write(to: dir.appendingPathComponent("tools.json"))
        let toolsmith = Toolsmith(imageDirectory: dir)
        XCTAssertEqual(toolsmith.manifest?.image.name, "img")
    }
}

// © 2025 Contexter alias Benedikt Eickhoff 🛡️ All rights reserved.
