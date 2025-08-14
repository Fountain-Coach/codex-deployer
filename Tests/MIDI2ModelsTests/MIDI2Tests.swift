import XCTest
@testable import MIDI2Models

final class MIDI2ModelsTests: XCTestCase {
    func testLoadIndex() throws {
        let index = try MIDIModelIndex.load()
        XCTAssertFalse(index.documents.isEmpty)
    }
}

// © 2025 Contexter alias Benedikt Eickhoff 🛡️ All rights reserved.
