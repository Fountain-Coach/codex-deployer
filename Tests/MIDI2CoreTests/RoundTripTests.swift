import XCTest
@testable import MIDI2Core
import MIDI2

final class RoundTripTests: XCTestCase {
    private func loadJSON<T: Decodable>(_ relative: String, as type: T.Type) throws -> T {
        let path = (FileManager.default.currentDirectoryPath as NSString).appendingPathComponent(relative)
        let text = try String(contentsOfFile: path, encoding: .utf8)
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
