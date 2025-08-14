import XCTest
@testable import MIDI2Transports

final class ALSATransportTests: XCTestCase {
    func testParsesEndpoints() throws {
        let sample = """
client 14: 'Midi Through' [type=kernel]
  0 'Midi Through Port-0' [type=kernel]
"""
        let file = FileManager.default.temporaryDirectory.appendingPathComponent("clients.txt")
        try sample.write(to: file, atomically: true, encoding: .utf8)
        let names = ALSATransport.availableEndpoints(from: file.path)
        XCTAssertEqual(names, ["Midi Through"])
    }

    func testLoopbackModeEchosUMP() throws {
        let transport = ALSATransport(useLoopback: true)
        let exp = expectation(description: "recv")
        var received: [UInt32] = []
        transport.onReceiveUMP = { words in
            received = words
            exp.fulfill()
        }
        try transport.open()
        let packet: [UInt32] = [0xDEADBEEF, 0xFEEDC0DE]
        try transport.send(umpWords: packet)
        wait(for: [exp], timeout: 1.0)
        XCTAssertEqual(received, packet)
        try transport.close()
    }
}

// © 2025 Contexter alias Benedikt Eickhoff 🛡️ All rights reserved.
