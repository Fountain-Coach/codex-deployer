import XCTest
import MIDI2
@testable import SSEOverMIDI

final class FlexPackerTests: XCTestCase {
    func testRandomPayloadRoundTrip() throws {
        let packer = FlexPacker()
        var rng = SystemRandomNumberGenerator()
        for size in 1...64 {
            let payload = Data((0..<size).map { _ in UInt8.random(in: 0...255, using: &rng) })
            let frames = packer.pack(json: payload, group: 0x2, statusBank: 0x1, status: 0x1)
            let blobs = packer.unpack(umps: frames)
            XCTAssertEqual(blobs.first, payload)
            if size > 12 { XCTAssertGreaterThan(frames.count, 1) }
        }
    }
}

// © 2025 Contexter alias Benedikt Eickhoff 🛡️ All rights reserved.
