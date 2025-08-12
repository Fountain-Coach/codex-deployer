import XCTest
@testable import MIDI2

final class ModelsFilesTests: XCTestCase {
    private func path(_ relative: String) -> String {
        return (FileManager.default.currentDirectoryPath as NSString).appendingPathComponent(relative)
    }

    func testMessagesEnumsBitfieldsRangesExistAndAreArrays() throws {
        let files = [
            "midi/models/messages.json",
            "midi/models/enums.json",
            "midi/models/bitfields.json",
            "midi/models/ranges.json"
        ]

        for file in files {
            let url = URL(fileURLWithPath: path(file))
            XCTAssertTrue(FileManager.default.fileExists(atPath: url.path), "Missing \(file)")

            let data = try Data(contentsOf: url)
            let json = try JSONSerialization.jsonObject(with: data, options: [])
            XCTAssertTrue(json is [Any], "Expected array JSON in \(file)")
        }
    }

    func testIndexDecodingHasStableShape() throws {
        let index = try MIDIModelIndex.load()
        // Validate at least keys on first document if present
        if let first = index.documents.first {
            XCTAssertFalse(first.fileName.isEmpty)
            XCTAssertFalse(first.id.isEmpty)
            XCTAssertGreaterThan(first.size, 0)
            XCTAssertFalse(first.sha256.isEmpty)
            // At least one page with number and text fields
            if let firstPage = first.pages.first {
                XCTAssertGreaterThan(firstPage.number, 0)
                _ = firstPage.text // ensure accessible
                _ = firstPage.lines // ensure accessible
            }
        }
    }
}

// © 2025 Contexter alias Benedikt Eickhoff 🛡️ All rights reserved.

