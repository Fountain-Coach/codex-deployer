import XCTest
import Crypto
@testable import FountainRuntime

final class ZoneManagerDNSSECTests: XCTestCase {
    func temporaryFile() -> URL {
        let dir = FileManager.default.temporaryDirectory
        return dir.appendingPathComponent(UUID().uuidString)
    }

    func testPersistsSignature() async throws {
        let file = temporaryFile()
        let signer = DNSSECSigner(privateKey: .init())
        let manager = try ZoneManager(fileURL: file, signer: signer)
        let zone = try await manager.createZone(name: "example.com")
        _ = try await manager.createRecord(zoneId: zone.id, name: "", type: "A", value: "9.9.9.9")
        let sigURL = file.appendingPathExtension("sig")
        let sigData = try Data(contentsOf: sigURL)
        let yaml = try String(contentsOf: file, encoding: .utf8)
        XCTAssertTrue(signer.verify(zone: yaml, signature: sigData))
    }
}

// © 2025 Contexter alias Benedikt Eickhoff 🛡️ All rights reserved.

