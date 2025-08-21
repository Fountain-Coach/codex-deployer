import XCTest
@testable import SSEOverMIDI

final class TimestampTests: XCTestCase {
    func testTimestampPropagation() {
        let start = Timing.hostTime(fromJR: 0)
        let later = Timing.hostTime(fromJR: 500_000) // +0.5s
        XCTAssertEqual(later - start, 0.5, accuracy: 0.01)
    }
}

// © 2025 Contexter alias Benedikt Eickhoff 🛡️ All rights reserved.
