import XCTest
import MIDI2
@testable import SSEOverMIDI

final class SysEx8PackerTests: XCTestCase {
    func testRoundTripMultiKB() {
        let packer = SysEx8Packer()
        let size = 3 * 1024
        let blob = Data((0..<size).map { _ in UInt8.random(in: 0...255) })
        let packets = packer.pack(streamID: 0x7F, blob: blob, group: 0x0)
        let unpacked = packer.unpack(umps: packets)
        XCTAssertEqual(unpacked.count, 1)
        XCTAssertEqual(unpacked.first?.streamID, 0x7F)
        XCTAssertEqual(unpacked.first?.blob, blob)
    }
}

// © 2025 Contexter alias Benedikt Eickhoff 🛡️ All rights reserved.
