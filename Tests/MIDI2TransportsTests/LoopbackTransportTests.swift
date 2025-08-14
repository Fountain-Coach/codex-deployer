import XCTest
@testable import MIDI2Transports

final class MIDI2TransportsTests: XCTestCase {
    func testLoopbackTransportEchoesUMP() throws {
        let transport = LoopbackTransport()
        let exp = expectation(description: "received")
        var received: [UInt32] = []
        transport.onReceiveUMP = { words in
            received = words
            exp.fulfill()
        }
        try transport.open()
        let packet: [UInt32] = [0x12345678, 0x9ABCDEF0]
        try transport.send(umpWords: packet)
        wait(for: [exp], timeout: 1.0)
        XCTAssertEqual(received, packet)
        try transport.close()
    }
}

// © 2025 Contexter alias Benedikt Eickhoff 🛡️ All rights reserved.
