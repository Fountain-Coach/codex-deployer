#!/usr/bin/env swift
import Foundation

let fm = FileManager.default
let repoRoot = URL(fileURLWithPath: fm.currentDirectoryPath)
let modelsDir = repoRoot.appendingPathComponent("midi/models")
let outDir = repoRoot.appendingPathComponent("Sources/MIDI2/Generated")
let outFile = outDir.appendingPathComponent("Models.swift")

struct MessageType: Codable {
    let name: String
    let status: UInt8
    let description: String
}

struct EnumDefinition: Codable {
    let name: String
    let cases: [String]
}

struct Bit: Codable {
    let name: String
    let offset: Int
    let width: Int
}

struct Bitfield: Codable {
    let name: String
    let bits: [Bit]
}

struct RangeDefinition: Codable {
    let name: String
    let min: Int
    let max: Int
}

func loadArray<T: Decodable>(_ fileName: String, as type: T.Type) throws -> [T] {
    let url = modelsDir.appendingPathComponent(fileName)
    let data = try Data(contentsOf: url)
    let raw = try JSONSerialization.jsonObject(with: data) as? [Any] ?? []
    var result: [T] = []
    let decoder = JSONDecoder()
    for element in raw {
        if let dict = element as? [String: Any] {
            let elemData = try JSONSerialization.data(withJSONObject: dict)
            result.append(try decoder.decode(T.self, from: elemData))
        }
    }
    return result
}

let messages = try loadArray("messages.json", as: MessageType.self)
let enums = try loadArray("enums.json", as: EnumDefinition.self)
let bitfields = try loadArray("bitfields.json", as: Bitfield.self)
let ranges = try loadArray("ranges.json", as: RangeDefinition.self)

try? fm.createDirectory(at: outDir, withIntermediateDirectories: true)

var output = """
// Generated Swift models - regenerated from midi/models/*.json
// DO NOT EDIT MANUALLY

public struct MessageType: Codable, Equatable, Sendable {
    public let name: String
    public let status: UInt8
    public let description: String
}

public struct EnumDefinition: Codable, Equatable, Sendable {
    public let name: String
    public let cases: [String]
}

public struct Bitfield: Codable, Equatable, Sendable {
    public struct Bit: Codable, Equatable, Sendable {
        public let name: String
        public let offset: Int
        public let width: Int
    }
    public let name: String
    public let bits: [Bit]
}

public struct RangeDefinition: Codable, Equatable, Sendable {
    public let name: String
    public let min: Int
    public let max: Int
}
"""

output += "\npublic let messageTypes: [MessageType] = [\n"
for m in messages {
    output += "    MessageType(name: \"\(m.name)\", status: \(m.status), description: \"\(m.description)\"),\n"
}
output += "]\n\n"

output += "public let enumDefinitions: [EnumDefinition] = [\n"
for e in enums {
    let casesList = e.cases.map { "\"\($0)\"" }.joined(separator: ", ")
    output += "    EnumDefinition(name: \"\(e.name)\", cases: [\(casesList)]),\n"
}
output += "]\n\n"

output += "public let bitfields: [Bitfield] = [\n"
for b in bitfields {
    output += "    Bitfield(name: \"\(b.name)\", bits: [\n"
    for bit in b.bits {
        output += "        .init(name: \"\(bit.name)\", offset: \(bit.offset), width: \(bit.width)),\n"
    }
    output += "    ]),\n"
}
output += "]\n\n"

output += "public let rangeDefinitions: [RangeDefinition] = [\n"
for r in ranges {
    output += "    RangeDefinition(name: \"\(r.name)\", min: \(r.min), max: \(r.max)),\n"
}
output += "]\n\n// © 2025 Contexter alias Benedikt Eickhoff 🛡️ All rights reserved.\n"

try output.write(to: outFile, atomically: true, encoding: .utf8)
print("Generated \(outFile.path)")

// © 2025 Contexter alias Benedikt Eickhoff 🛡️ All rights reserved.
