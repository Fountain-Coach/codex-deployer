import XCTest
@testable import MIDI2Core
import MIDI2
import ResourceLoader
@testable import flexctl

final class RoundTripTests: XCTestCase {
    private func resourceURL(_ relative: String) throws -> URL {
        let ns = relative as NSString
        let subdir = ns.deletingLastPathComponent.isEmpty ? nil : ns.deletingLastPathComponent
        let file = ns.lastPathComponent
        let name = (file as NSString).deletingPathExtension
        let ext = (file as NSString).pathExtension
        do {
            return try ResourceLoader.url(name, ext: ext, subdir: subdir, bundle: FlexctlResources.bundle)
        } catch {
            return try ResourceLoader.url(name, ext: ext, subdir: nil, bundle: FlexctlResources.bundle)
        }
    }

    private func loadJSON<T: Decodable>(_ relative: String, as type: T.Type) throws -> T {
        let url = try resourceURL(relative)
        let text = try String(contentsOf: url, encoding: .utf8)
        let filtered = text.split(separator: "\n").filter { !$0.trimmingCharacters(in: .whitespaces).hasPrefix("//") }.joined(separator: "\n")
        let data = filtered.data(using: .utf8)!
        return try JSONDecoder().decode(T.self, from: data)
    }

    func testRoundTripEnvelopes() throws {
        let intents = [
            "llm.chat",
            "planner.reason",
            "planner.execute",
            "tools.register",
            "function.invoke",
            "persist.baseline",
            "awareness.reflect",
            "custom"
        ]

        for intent in intents {
            let env: FlexEnvelope = try loadJSON("midi/examples/\(intent).json", as: FlexEnvelope.self)
            let data = try JSONEncoder().encode(env)
            let round = try JSONDecoder().decode(FlexEnvelope.self, from: data)
            XCTAssertEqual(round, env)

            let packet = try MIDI2Core.encode(env)
            XCTAssertEqual(packet.words.count, 4)
            let stored: [UInt32] = try loadJSON("midi/examples/\(intent).ump.json", as: [UInt32].self)
            XCTAssertEqual(stored.count, 4, "Golden vector shape for \(intent)")
        }
    }
}

// © 2025 Contexter alias Benedikt Eickhoff 🛡️ All rights reserved.
