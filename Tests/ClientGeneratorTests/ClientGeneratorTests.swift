import XCTest
@testable import FountainCodex

final class ClientGeneratorTests: XCTestCase {
    func testClientFilesGenerated() throws {
        let json = """
        {
          "title": "Sample API",
          "paths": {
            "/todos": { "get": { "operationId": "GetTodos" } }
          }
        }
        """
        let specURL = FileManager.default.temporaryDirectory.appendingPathComponent("spec.json")
        try json.write(to: specURL, atomically: true, encoding: .utf8)
        let spec = try SpecLoader.load(from: specURL)

        let outDir = FileManager.default.temporaryDirectory.appendingPathComponent("client")
        try? FileManager.default.removeItem(at: outDir)
        try ClientGenerator.emitClient(from: spec, to: outDir)

        XCTAssertTrue(FileManager.default.fileExists(atPath: outDir.appendingPathComponent("APIRequest.swift").path))
        XCTAssertTrue(FileManager.default.fileExists(atPath: outDir.appendingPathComponent("APIClient.swift").path))
        XCTAssertTrue(FileManager.default.fileExists(atPath: outDir.appendingPathComponent("Requests/GetTodos.swift").path))
    }
}

// © 2025 Contexter alias Benedikt Eickhoff 🛡️ All rights reserved.
