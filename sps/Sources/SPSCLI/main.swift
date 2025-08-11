import Foundation
#if canImport(CryptoKit)
import CryptoKit
#endif

enum SPSCommand: String {
    case scan, index, query, exportMatrix = "export-matrix", help
}

struct IndexDoc: Codable {
    var id: String
    var fileName: String
    var size: Int
    var sha256: String?
    var pages: [IndexPage]
}
struct IndexPage: Codable {
    var number: Int
    var text: String
}
struct IndexRoot: Codable {
    var documents: [IndexDoc]
}

func usage(_ code: Int32 = 2) -> Never {
    fputs("""
Usage:
  sps scan <pdf...> --out <index.json> [--include-text] [--sha256]
  sps index validate <index.json>
  sps query <index.json> --q "<term>" [--page-range A-B]
  sps export-matrix <index.json> --out spec/matrix.json

""", stderr)
    exit(code)
}

@inline(__always) func argVal(_ name: String, _ argv: [String]) -> String? {
    guard let i = argv.firstIndex(of: name), i + 1 < argv.count else { return nil }
    return argv[i+1]
}
@inline(__always) func hasFlag(_ name: String, _ argv: [String]) -> Bool {
    argv.contains(name)
}

func sha256Hex(data: Data) -> String {
    #if canImport(CryptoKit)
    let digest = SHA256.hash(data: data)
    return digest.map { String(format: "%02x", $0) }.joined()
    #else
    // fallback (non-cryptographic placeholder to stay dependency-free on Linux)
    var sum: UInt64 = 0
    for b in data { sum &+= UInt64(b) }
    return String(format: "sum64-%016llx", sum)
    #endif
}

func cmdScan(_ argv: [String]) throws {
    guard let out = argVal("--out", argv) else { usage() }
    let includeText = hasFlag("--include-text", argv) || hasFlag("--includeText", argv)
    let wantSHA = hasFlag("--sha256", argv)
    let pdfs = argv.dropFirst().filter { !$0.hasPrefix("--") && !$0.contains("scan") }
    if pdfs.isEmpty { usage() }

    var docs: [IndexDoc] = []
    for path in pdfs {
        let url = URL(fileURLWithPath: path)
        let data = (try? Data(contentsOf: url)) ?? Data()
        let text = includeText ? "(text extraction TBD for \(url.lastPathComponent))" : ""
        let sha = wantSHA ? sha256Hex(data: data) : nil
        let pages = [IndexPage(number: 1, text: text)]
        let doc = IndexDoc(id: UUID().uuidString, fileName: url.lastPathComponent, size: data.count, sha256: sha, pages: pages)
        docs.append(doc)
    }
    let index = IndexRoot(documents: docs)
    let enc = JSONEncoder()
    enc.outputFormatting = [.prettyPrinted, .sortedKeys]
    let json = try enc.encode(index)
    try json.write(to: URL(fileURLWithPath: out))
    print("SPS: wrote index -> \(out) (\(json.count) bytes, \(docs.count) doc(s))")
}

func cmdIndexValidate(_ argv: [String]) throws {
    guard argv.count >= 4 else { usage() }
    let path = argv.last!
    let data = try Data(contentsOf: URL(fileURLWithPath: path))
    let dec = JSONDecoder()
    do {
        _ = try dec.decode(IndexRoot.self, from: data)
        print(#"{ "ok": true, "issues": [] }"#)
    } catch {
        print(#"{ "ok": false, "issues": ["\#(error)"] }"#)
        exit(3)
    }
}

func cmdQuery(_ argv: [String]) throws {
    guard let q = argVal("--q", argv) else { usage() }
    let indexPath = argv.dropFirst().first { $0.hasSuffix(".json") } ?? ""
    guard !indexPath.isEmpty else { usage() }
    let data = try Data(contentsOf: URL(fileURLWithPath: indexPath))
    let index = try JSONDecoder().decode(IndexRoot.self, from: data)
    var hits: [[String: Any]] = []
    for doc in index.documents {
        for page in doc.pages {
            if page.text.lowercased().contains(q.lowercased()) {
                hits.append(["docId": doc.id, "page": page.number, "snippet": page.text])
            }
        }
    }
    let out: [String: Any] = ["hits": hits]
    let json = try JSONSerialization.data(withJSONObject: out, options: [.prettyPrinted, .sortedKeys])
    FileHandle.standardOutput.write(json)
    FileHandle.standardOutput.write("\n".data(using: .utf8)!)
}

func cmdExportMatrix(_ argv: [String]) throws {
    guard let out = argVal("--out", argv) else { usage() }
    let matrix: [String: Any] = [
        "messages": [],
        "terms": []
    ]
    let data = try JSONSerialization.data(withJSONObject: matrix, options: [.prettyPrinted, .sortedKeys])
    try data.write(to: URL(fileURLWithPath: out))
    print("SPS: wrote matrix skeleton -> \(out)")
}

let argv = CommandLine.arguments
guard argv.count >= 2 else { usage() }
let cmdStr = argv[1]
switch cmdStr {
case SPSCommand.scan.rawValue:
    try! cmdScan(Array(argv.dropFirst(1)))
case "index":
    if argv.count >= 3, argv[2] == "validate" {
        try! cmdIndexValidate(Array(argv.dropFirst(2)))
    } else { usage() }
case SPSCommand.query.rawValue:
    try! cmdQuery(Array(argv.dropFirst(1)))
case SPSCommand.exportMatrix.rawValue:
    try! cmdExportMatrix(Array(argv.dropFirst(1)))
case SPSCommand.help.rawValue, "--help", "-h":
    usage(0)
default:
    usage()
}
