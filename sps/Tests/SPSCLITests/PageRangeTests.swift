import XCTest
@testable import SPSCLI
import ArgumentParser
import Foundation
#if canImport(Glibc)
import Glibc
#else
import Darwin
#endif

final class PageRangeTests: XCTestCase {
    private func writeTestIndex() throws -> URL {
        let tempDir = FileManager.default.temporaryDirectory
        let indexURL = tempDir.appendingPathComponent("range-index.json")
        let pages = [
            IndexPage(number: 1, text: "hit", lines: []),
            IndexPage(number: 2, text: "hit", lines: []),
            IndexPage(number: 3, text: "hit", lines: [])
        ]
        let doc = IndexDoc(id: "1", fileName: "dummy", size: 0, sha256: nil, pages: pages)
        let index = IndexRoot(documents: [doc])
        let enc = JSONEncoder()
        enc.outputFormatting = [.prettyPrinted, .sortedKeys]
        try enc.encode(index).write(to: indexURL)
        return indexURL
    }

    func testParsePageRangeSinglePage() throws {
        XCTAssertEqual(try parsePageRange("2"), [2])
    }

    func testParsePageRangeInclusiveRange() throws {
        XCTAssertEqual(try parsePageRange("1-2"), [1,2])
    }

    func testParsePageRangeInvalidSegment() {
        XCTAssertThrowsError(try parsePageRange("2-"))
    }

    func testParsePageRangeZeroIsInvalid() {
        XCTAssertThrowsError(try parsePageRange("0"))
    }

    func testQueryPageRangeSinglePage() throws {
        let indexURL = try writeTestIndex()
        let pipe = Pipe()
        let original = dup(STDOUT_FILENO)
        dup2(pipe.fileHandleForWriting.fileDescriptor, STDOUT_FILENO)
        let cmd = try SPS.Query.parse([indexURL.path, "--q", "hit", "--page-range", "2"])
        try cmd.run()
        pipe.fileHandleForWriting.closeFile()
        dup2(original, STDOUT_FILENO)
        close(original)
        let data = pipe.fileHandleForReading.readDataToEndOfFile()
        let obj = try JSONSerialization.jsonObject(with: data) as! [String: Any]
        let hits = obj["hits"] as? [[String: Any]]
        let pages = hits?.compactMap { $0["page"] as? Int }
        XCTAssertEqual(pages, [2])
    }

    func testQueryPageRangeInclusiveRange() throws {
        let indexURL = try writeTestIndex()
        let pipe = Pipe()
        let original = dup(STDOUT_FILENO)
        dup2(pipe.fileHandleForWriting.fileDescriptor, STDOUT_FILENO)
        let cmd = try SPS.Query.parse([indexURL.path, "--q", "hit", "--page-range", "1-2"])
        try cmd.run()
        pipe.fileHandleForWriting.closeFile()
        dup2(original, STDOUT_FILENO)
        close(original)
        let data = pipe.fileHandleForReading.readDataToEndOfFile()
        let obj = try JSONSerialization.jsonObject(with: data) as! [String: Any]
        let hits = obj["hits"] as? [[String: Any]]
        let pages = hits?.compactMap { $0["page"] as? Int }
        XCTAssertEqual(pages, [1,2])
    }

    func testQueryPageRangeInvalidInput() throws {
        let indexURL = try writeTestIndex()
        let cmd = try SPS.Query.parse([indexURL.path, "--q", "hit", "--page-range", "2-"])
        XCTAssertThrowsError(try cmd.run())
    }
}

// © 2025 Contexter alias Benedikt Eickhoff 🛡️ All rights reserved.
