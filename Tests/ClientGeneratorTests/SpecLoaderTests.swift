import XCTest
@testable import FountainRuntime

final class SpecLoaderTests: XCTestCase {
    func testLoadsJSONRemovingCopyright() throws {
        let json = "© 2025 Contexter alias Benedikt Eickhoff 🛡️\n{\"title\":\"API\",\"paths\":{}}"
        let url = FileManager.default.temporaryDirectory.appendingPathComponent("spec.json")
        try json.write(to: url, atomically: true, encoding: .utf8)
        let spec = try SpecLoader.load(from: url)
        XCTAssertEqual(spec.title, "API")
    }

    func testLoadsYAMLAndNormalizesInfoTitle() throws {
        let yaml = """
        info:
          title: Example
        paths: {}
        """
        let url = FileManager.default.temporaryDirectory.appendingPathComponent("spec.yml")
        try yaml.write(to: url, atomically: true, encoding: .utf8)
        let spec = try SpecLoader.load(from: url)
        XCTAssertEqual(spec.title, "Example")
    }

    /// Loading an empty file should produce a decoding error.
    func testLoadThrowsForEmptyFile() {
        let url = FileManager.default.temporaryDirectory.appendingPathComponent("empty.yml")
        _ = FileManager.default.createFile(atPath: url.path, contents: Data())
        XCTAssertThrowsError(try SpecLoader.load(from: url))
    }

    /// Non-UTF8 input should trigger a data corruption error.
    func testLoadThrowsForInvalidUTF8() {
        let url = FileManager.default.temporaryDirectory.appendingPathComponent("invalid.json")
        let bytes: [UInt8] = [0xFF]
        let data = Data(bytes)
        _ = FileManager.default.createFile(atPath: url.path, contents: data)
        XCTAssertThrowsError(try SpecLoader.load(from: url))
    }
}

// © 2025 Contexter alias Benedikt Eickhoff 🛡️ All rights reserved.
