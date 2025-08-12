import XCTest
@testable import MIDI2

final class MIDI2Tests: XCTestCase {
    func testLoadIndex() throws {
        let index = try MIDIModelIndex.load()
        XCTAssertFalse(index.documents.isEmpty)
    }
}

// © 2025 Contexter alias Benedikt Eickhoff 🛡️ All rights reserved.
