import XCTest
@testable import MIDI2Transports

final class RTPMidiSessionTests: XCTestCase {
    func testLoopbackSendReceive() throws {
        let session = RTPMidiSession(localName: "test", enableDiscovery: false, enableCINegotiation: false)
        let exp = expectation(description: "receive")
        var received: [UInt32] = []
        session.onReceiveUMP = { words in
            received = words
            exp.fulfill()
        }
        try session.open()
        let packet: [UInt32] = [0xCAFEBABE, 0x8BADF00D, 0xDEADC0DE, 0xFEEDFACE]
        try session.send(umpWords: packet)
        wait(for: [exp], timeout: 2.0)
        XCTAssertEqual(received, packet)
        try session.close()
    }
}

// © 2025 Contexter alias Benedikt Eickhoff 🛡️ All rights reserved.
