import Foundation
import FoundationNetworking
import OpenAPICurator

func loadDotEnv(path: String = ".env") {
    guard let data = try? String(contentsOfFile: path) else { return }
    for line in data.split(separator: "\n") {
        let trimmed = line.trimmingCharacters(in: .whitespaces)
        if trimmed.isEmpty || trimmed.hasPrefix("#") { continue }
        let parts = trimmed.split(separator: "=", maxSplits: 1).map(String.init)
        if parts.count == 2 { setenv(parts[0], parts[1], 1) }
    }
}

func extractOperationIds(from text: String) -> [String] {
    var ops: [String] = []
    for line in text.split(separator: "\n") {
        if let range = line.range(of: "operationId:") {
            let op = line[range.upperBound...].trimmingCharacters(in: .whitespaces)
            if !op.isEmpty { ops.append(String(op)) }
        }
    }
    return ops
}

loadDotEnv()

var specPath: String?
var corpusId = ProcessInfo.processInfo.environment["DEFAULT_CORPUS_ID"] ?? "tools-factory"
var submit = false

let args = Array(CommandLine.arguments.dropFirst())
var i = 0
while i < args.count {
    let a = args[i]
    if a == "--spec", i + 1 < args.count {
        specPath = args[i + 1]
        i += 2
        continue
    }
    if a == "--corpus", i + 1 < args.count {
        corpusId = args[i + 1]
        i += 2
        continue
    }
    if a == "--submit" {
        submit = true
        i += 1
        continue
    }
    i += 1
}

guard let specPath else {
    if let data = "--spec path or url required\n".data(using: .utf8) {
        FileHandle.standardError.write(data)
    }
    exit(2)
}

let specURL: URL
if let url = URL(string: specPath), url.scheme != nil {
    specURL = url
} else {
    specURL = URL(fileURLWithPath: specPath)
}

let specData: Data
if specURL.isFileURL {
    specData = (try? Data(contentsOf: specURL)) ?? Data()
} else {
    specData = (try? Data(contentsOf: specURL)) ?? Data()
}

let text = String(data: specData, encoding: .utf8) ?? ""
let operations = extractOperationIds(from: text)
let spec = Spec(operations: operations)
let result = OpenAPICuratorKit.run(specs: [spec], submit: submit)

let storageBase = ProcessInfo.processInfo.environment["CURATOR_STORAGE_PATH"] ?? "/data/corpora/\(corpusId)/curator"
let ts = ISO8601DateFormatter().string(from: Date())
let outDir = URL(fileURLWithPath: storageBase).appendingPathComponent(ts)
try? FileManager.default.createDirectory(at: outDir, withIntermediateDirectories: true)
let specOut = outDir.appendingPathComponent("curated.json")
let reportOut = outDir.appendingPathComponent("report.json")
if let specDataOut = try? JSONSerialization.data(withJSONObject: ["operations": result.spec.operations], options: [.prettyPrinted]) {
    try? specDataOut.write(to: specOut)
}
if let reportDataOut = try? JSONSerialization.data(withJSONObject: ["appliedRules": result.report.appliedRules, "collisions": result.report.collisions], options: [.prettyPrinted]) {
    try? reportDataOut.write(to: reportOut)
}

print("Applied rules: \(result.report.appliedRules.count); Collisions: \(result.report.collisions.count)")
if !result.report.collisions.isEmpty {
    exit(1)
}
