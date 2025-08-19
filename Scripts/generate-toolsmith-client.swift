import Foundation

let fm = FileManager.default
let root = URL(fileURLWithPath: fm.currentDirectoryPath)
let spec = root.appendingPathComponent("Sources/FountainOps/FountainAi/openAPI/v1/tools-factory.yml")
let tmp = root.appendingPathComponent(".toolsmith-gen")
try? fm.removeItem(at: tmp)
try fm.createDirectory(at: tmp, withIntermediateDirectories: true)

let proc = Process()
proc.executableURL = URL(fileURLWithPath: "/usr/bin/swift")
proc.arguments = ["run", "clientgen-service", "--input", spec.path, "--output", tmp.path]
proc.standardOutput = FileHandle.standardOutput
proc.standardError = FileHandle.standardError
try proc.run()
proc.waitUntilExit()

guard proc.terminationStatus == 0 else {
    throw NSError(domain: "Generator", code: Int(proc.terminationStatus), userInfo: nil)
}

let clientSrc = tmp.appendingPathComponent("Client/tools-factory")
let clientDst = root.appendingPathComponent("FountainAIToolsmith/Sources/ToolsmithAPI")
if fm.fileExists(atPath: clientDst.path) { try fm.removeItem(at: clientDst) }
try fm.createDirectory(at: clientDst.deletingLastPathComponent(), withIntermediateDirectories: true)
try fm.moveItem(at: clientSrc, to: clientDst)

let serverSrc = tmp.appendingPathComponent("Server/tools-factory")
let serverDst = root.appendingPathComponent("Sources/ToolServer")
if fm.fileExists(atPath: serverDst.path) { try fm.removeItem(at: serverDst) }
try fm.moveItem(at: serverSrc, to: serverDst)

try fm.removeItem(at: tmp)

// © 2025 Contexter alias Benedikt Eickhoff 🛡️ All rights reserved.
