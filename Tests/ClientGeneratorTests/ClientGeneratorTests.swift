import XCTest
@testable import FountainRuntime

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

    /// Generated request types include optional query parameters.
    func testEmitRequestGeneratesQueryParameter() throws {
        let json = """
        {
          "title": "Sample API",
          "paths": {
            "/zones/{id}": {
              "get": {
                "operationId": "GetZone",
                "parameters": [
                  {"name": "id", "in": "path", "required": true, "schema": {"type": "string"}},
                  {"name": "detail", "in": "query", "schema": {"type": "string"}}
                ]
              }
            }
          }
        }
        """
        let specURL = FileManager.default.temporaryDirectory.appendingPathComponent("spec2.json")
        try json.write(to: specURL, atomically: true, encoding: .utf8)
        let spec = try SpecLoader.load(from: specURL)
        let outDir = FileManager.default.temporaryDirectory.appendingPathComponent("client2")
        try? FileManager.default.removeItem(at: outDir)
        try ClientGenerator.emitClient(from: spec, to: outDir)
        let requestFile = outDir.appendingPathComponent("Requests/GetZone.swift")
        let contents = try String(contentsOf: requestFile, encoding: .utf8)
        XCTAssertTrue(contents.contains("detail"))
        XCTAssertTrue(contents.contains("query.append(\"detail"))
    }
}

// © 2025 Contexter alias Benedikt Eickhoff 🛡️ All rights reserved.
