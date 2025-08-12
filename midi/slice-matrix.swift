#!/usr/bin/env swift
import Foundation

let footerString = "© 2025 Contexter alias Benedikt Eickhoff 🛡️ All rights reserved."
let args = CommandLine.arguments
guard args.count == 3 else {
    fputs("usage: slice-matrix.swift <matrix.json> <output-dir>\n", stderr)
    exit(1)
}

let matrixURL = URL(fileURLWithPath: args[1])
let outDirURL = URL(fileURLWithPath: args[2])
let fm = FileManager.default

do {
    let data = try Data(contentsOf: matrixURL)
    guard let root = try JSONSerialization.jsonObject(with: data) as? [String: Any] else {
        fputs("matrix.json is not a JSON object\n", stderr)
        exit(1)
    }

    try fm.createDirectory(at: outDirURL, withIntermediateDirectories: true)

    var hadEmpty = false
    for key in ["messages", "enums", "bitfields", "ranges"] {
        let arr = root[key] as? [Any] ?? []
        if arr.isEmpty {
            fputs("Error: \(key) array is empty\n", stderr)
            hadEmpty = true
        }
        var arrWithFooter = arr
        arrWithFooter.append(footerString)
        let jsonData = try JSONSerialization.data(withJSONObject: arrWithFooter, options: [.prettyPrinted])
        let outURL = outDirURL.appendingPathComponent("\(key).json")
        try jsonData.write(to: outURL)
        print("Wrote \(key) to \(outURL.path)")
    }
    if hadEmpty { exit(1) }
} catch {
    fputs("Error: \(error)\n", stderr)
    exit(1)
}

// © 2025 Contexter alias Benedikt Eickhoff 🛡️ All rights reserved.
