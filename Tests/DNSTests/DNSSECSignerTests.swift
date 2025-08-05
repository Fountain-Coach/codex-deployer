import XCTest
import Crypto
@testable import FountainCodex

final class DNSSECSignerTests: XCTestCase {
    func testSignAndVerifyZone() throws {
        let key = Curve25519.Signing.PrivateKey()
        let signer = DNSSECSigner(privateKey: key)
        let zone = "example.com: 1.2.3.4"
        let sig = try signer.sign(zone: zone)
        XCTAssertTrue(signer.verify(zone: zone, signature: sig))
    }
}

// © 2025 Contexter alias Benedikt Eickhoff 🛡️ All rights reserved.

