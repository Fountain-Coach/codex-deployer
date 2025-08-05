import XCTest
import Crypto
@testable import FountainCodex

final class ZoneManagerDNSSECTests: XCTestCase {
    func temporaryFile() -> URL {
        let dir = FileManager.default.temporaryDirectory
        return dir.appendingPathComponent(UUID().uuidString)
    }

    func testPersistsSignature() async throws {
        let file = temporaryFile()
        let signer = DNSSECSigner(privateKey: .init())
        let manager = try ZoneManager(fileURL: file, signer: signer)
        try await manager.set(name: "example.com", ip: "9.9.9.9")
        let sigURL = file.appendingPathExtension("sig")
        let sigData = try Data(contentsOf: sigURL)
        let yaml = try String(contentsOf: file, encoding: .utf8)
        XCTAssertTrue(signer.verify(zone: yaml, signature: sigData))
    }
}

// © 2025 Contexter alias Benedikt Eickhoff 🛡️ All rights reserved.

