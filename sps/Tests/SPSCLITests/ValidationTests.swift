import XCTest
import Validation

final class ValidationTests: XCTestCase {
    func testValidationPasses() throws {
        let matrix: [String: Any] = [
            "messages": [["text": "Message", "page": 1, "x": 0, "y": 0]],
            "terms": [["text": "Term", "page": 1, "x": 0, "y": 1]],
            "bitfields": [["name": "Flags", "bits": [0, 1, 2]]]
        ]
        let data = try JSONSerialization.data(withJSONObject: matrix, options: [])
        let report = Validator.validate(matrixData: data)
        XCTAssertTrue(report.coveragePassed)
        XCTAssertTrue(report.reservedBitsPassed)
        XCTAssertTrue(report.issues.isEmpty)
    }

    func testValidationFails() throws {
        let matrix: [String: Any] = [
            "messages": [],
            "terms": [],
            "bitfields": [["name": "Flags", "bits": [0, -1, 2]]]
        ]
        let data = try JSONSerialization.data(withJSONObject: matrix, options: [])
        let report = Validator.validate(matrixData: data)
        XCTAssertFalse(report.coveragePassed)
        XCTAssertFalse(report.reservedBitsPassed)
        XCTAssertEqual(report.issues.count, 2)
    }
}

// © 2025 Contexter alias Benedikt Eickhoff 🛡️ All rights reserved.
