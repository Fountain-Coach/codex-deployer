#!/usr/bin/env swift
import Foundation

let fm = FileManager.default
let repoRoot = URL(fileURLWithPath: fm.currentDirectoryPath)
let messagesPath = repoRoot.appendingPathComponent("midi/models/messages.json")
let outDir = repoRoot.appendingPathComponent("midi/Sources/MIDI2/Generated")
let outFile = outDir.appendingPathComponent("Messages.swift")

try? fm.createDirectory(at: outDir, withIntermediateDirectories: true)

let placeholder = """
// Generated Swift models - regenerated from midi/models/messages.json
// DO NOT EDIT MANUALLY

public struct GeneratedMessages {
    public static let generatedVersion: Int = 1
}

"""

outFile.write_text(placeholder)
print('wrote midi/generate-swift-from-models.swift')
