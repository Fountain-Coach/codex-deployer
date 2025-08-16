import XCTest
@testable import flexctl
import ResourceLoader

final class FlexctlTests: XCTestCase {
    var tempExamplesDir: URL!

    override func setUp() {
        super.setUp()
        let fm = FileManager.default
        tempExamplesDir = URL(fileURLWithPath: NSTemporaryDirectory()).appendingPathComponent("midi/examples", isDirectory: true)
        try? fm.createDirectory(at: tempExamplesDir, withIntermediateDirectories: true)
        do {
            let src: URL
            do {
                src = try ResourceLoader.url("planner.execute", ext: "ump", subdir: "midi/examples", bundle: FlexctlResources.bundle)
            } catch {
                src = try ResourceLoader.url("planner.execute", ext: "ump", subdir: nil, bundle: FlexctlResources.bundle)
            }
            let dst = tempExamplesDir.appendingPathComponent("planner.execute.ump")
            if fm.fileExists(atPath: dst.path) { try? fm.removeItem(at: dst) }
            try fm.copyItem(at: src, to: dst)
        } catch {
            XCTFail("Fixture copy failed: \(error)")
        }
    }

    func testLoadUMP() throws {
        let file = tempExamplesDir.appendingPathComponent("planner.execute.ump")
        let words = try loadUMP(path: file.path)
        XCTAssertEqual(words.count, 4)
        XCTAssertEqual(words[0], 3490775296)
    }
}

// © 2025 Contexter alias Benedikt Eickhoff 🛡️ All rights reserved.
