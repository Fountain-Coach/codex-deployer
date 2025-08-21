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

#if canImport(Network)
    func testBonjourAndMIDICIDiscoveryLoopback() throws {
        let session = RTPMidiSession(localName: "disc")
        try session.open()
        Thread.sleep(forTimeInterval: 0.5)
        let mirror = Mirror(reflecting: session)
        let discovered = mirror.children.first { $0.label == "discovered" }?.value as? Set<String> ?? []
        XCTAssertTrue(discovered.contains("disc"))
        let proto = mirror.children.first { $0.label == "protocolVersion" }?.value as? UInt8 ?? 0
        XCTAssertEqual(proto, 1)
        let remote = mirror.children.first { $0.label == "remoteID" }?.value as? UUID?
        XCTAssertNotNil(remote ?? nil)
        try session.close()
    }
#endif
}

// © 2025 Contexter alias Benedikt Eickhoff 🛡️ All rights reserved.
