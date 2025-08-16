import XCTest
@testable import MIDI2Models
import ResourceLoader

final class ModelsFilesTests: XCTestCase {
    private func resourceURL(_ relative: String) throws -> URL {
        let ns = relative as NSString
        let subdir = ns.deletingLastPathComponent.isEmpty ? nil : ns.deletingLastPathComponent
        let file = ns.lastPathComponent
        let name = (file as NSString).deletingPathExtension
        let ext = (file as NSString).pathExtension
        do {
            return try ResourceLoader.url(name, ext: ext, subdir: subdir, bundle: MIDI2ModelsResources.bundle)
        } catch {
            return try ResourceLoader.url(name, ext: ext, subdir: nil, bundle: MIDI2ModelsResources.bundle)
        }
    }

    private func readJSONData(_ file: String) throws -> Data {
        let url = try resourceURL(file)
        let text = try String(contentsOf: url, encoding: .utf8)
        let filtered = text.split(separator: "\n").filter { !$0.trimmingCharacters(in: .whitespaces).hasPrefix("//") }.joined(separator: "\n")
        return filtered.data(using: .utf8)!
    }

    func testMessagesEnumsBitfieldsRangesExistAndAreArrays() throws {
        let files = [
            "midi/models/messages.json",
            "midi/models/enums.json",
            "midi/models/bitfields.json",
            "midi/models/ranges.json"
        ]

        for file in files {
            let url = try resourceURL(file)
            XCTAssertTrue(FileManager.default.fileExists(atPath: url.path), "Missing \(file)")

            let data = try readJSONData(file)
            let json = try JSONSerialization.jsonObject(with: data, options: [])
            XCTAssertTrue(json is [Any], "Expected array JSON in \(file)")
        }
    }

    private func decodeFirst<T: Decodable>(_ file: String, as type: T.Type) throws -> T? {
        let data = try readJSONData(file)
        let raw = try JSONSerialization.jsonObject(with: data) as? [Any] ?? []
        let decoder = JSONDecoder()
        for element in raw {
            if let dict = element as? [String: Any] {
                let elemData = try JSONSerialization.data(withJSONObject: dict)
                return try decoder.decode(T.self, from: elemData)
            }
        }
        return nil
    }

    func testDecodeSampleModels() throws {
        let message = try XCTUnwrap(decodeFirst("midi/models/messages.json", as: MessageType.self))
        XCTAssertEqual(message.name, "noteOn")
        XCTAssertEqual(message.status, 144)

        let enumeration = try XCTUnwrap(decodeFirst("midi/models/enums.json", as: EnumDefinition.self))
        XCTAssertEqual(enumeration.cases, ["up", "down"])

        let bitfield = try XCTUnwrap(decodeFirst("midi/models/bitfields.json", as: Bitfield.self))
        XCTAssertEqual(bitfield.bits.count, 2)
        XCTAssertEqual(bitfield.bits.first?.name, "isSharp")

        let range = try XCTUnwrap(decodeFirst("midi/models/ranges.json", as: RangeDefinition.self))
        XCTAssertEqual(range.min, 0)
        XCTAssertEqual(range.max, 127)
    }

    func testIndexDecodingHasStableShape() throws {
        let index = try MIDIModelIndex.load()
        // Validate at least keys on first document if present
        if let first = index.documents.first {
            XCTAssertFalse(first.fileName.isEmpty)
            XCTAssertFalse(first.id.isEmpty)
            XCTAssertGreaterThan(first.size, 0)
            XCTAssertFalse(first.sha256.isEmpty)
            // At least one page with number and text fields
            if let firstPage = first.pages.first {
                XCTAssertGreaterThan(firstPage.number, 0)
                _ = firstPage.text // ensure accessible
                _ = firstPage.lines // ensure accessible
            }
        }
    }
}

// © 2025 Contexter alias Benedikt Eickhoff 🛡️ All rights reserved.

