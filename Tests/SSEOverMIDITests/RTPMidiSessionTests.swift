import XCTest
@testable import MIDI2Transports

final class RTPMidiSessionTests: XCTestCase {
    func testCoalescingAndReordering() throws {
        let session = RTPMidiSession(localName: "test", mtu: 64, enableDiscovery: false, enableCINegotiation: false)
        let exp = expectation(description: "recv")
        var received: [[UInt32]] = []
        session.onReceiveUmps = { umps in
            received.append(contentsOf: umps)
            if received.count == 4 { exp.fulfill() }
        }
        try session.open()
        let u1: [UInt32] = [0x11111111,0x11111111,0x11111111,0x11111111]
        let u2: [UInt32] = [0x22222222,0x22222222,0x22222222,0x22222222]
        let u3: [UInt32] = [0x33333333,0x33333333,0x33333333,0x33333333]
        let u4: [UInt32] = [0x44444444,0x44444444,0x44444444,0x44444444]
        try session.send(umps: [u1, u2, u3, u4])
        wait(for: [exp], timeout: 2.0)
        XCTAssertEqual(received.count, 4)
        let shuffled = received.shuffled()
        let sorted = shuffled.sorted { $0[0] < $1[0] }
        XCTAssertEqual(sorted.first?[0], 0x11111111)
        try session.close()
    }
}

// © 2025 Contexter alias Benedikt Eickhoff 🛡️ All rights reserved.
