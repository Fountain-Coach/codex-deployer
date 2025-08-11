import Foundation
#if canImport(CryptoKit)
import CryptoKit
#endif
#if os(macOS)
import CoreGraphics
#endif
import ArgumentParser

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

func extractPages(data: Data, includeText: Bool) -> [IndexPage] {
    guard includeText else {
        return [IndexPage(number: 1, text: "")]
    }
    #if os(macOS)
    guard let provider = CGDataProvider(data: data as CFData),
          let doc = CGPDFDocument(provider) else {
        return [IndexPage(number: 1, text: "")]
    }
    var pages: [IndexPage] = []
    for i in 1...doc.numberOfPages {
        guard let page = doc.page(at: i) else { continue }
        let content = CGPDFContentStreamCreateWithPage(page)
        var strings: [String] = []
        let table = CGPDFOperatorTableCreate()!
        let callback: CGPDFOperatorCallback = { scanner, info in
            guard let info = info?.assumingMemoryBound(to: [String].self) else { return }
            var object: CGPDFObjectRef?
            if CGPDFScannerPopObject(scanner, &object), let obj = object,
               let str = cgpdfObjectToString(obj) {
                info.pointee.append(str)
            }
        }
        CGPDFOperatorTableSetCallback(table, "Tj", callback)
        CGPDFOperatorTableSetCallback(table, "TJ", callback)
        if let scanner = CGPDFScannerCreate(content, table, &strings) {
            CGPDFScannerScan(scanner)
        }
        pages.append(IndexPage(number: i, text: strings.joined(separator: " ")))
    }
    return pages
    #else
    return [IndexPage(number: 1, text: "(text extraction unavailable)")]
    #endif
}

#if os(macOS)
private func cgpdfObjectToString(_ object: CGPDFObjectRef) -> String? {
    let type = CGPDFObjectGetType(object)
    if type == .string {
        var stringRef: CGPDFStringRef?
        if CGPDFObjectGetValue(object, .string, &stringRef), let s = stringRef,
           let cfStr = CGPDFStringCopyTextString(s) {
            return cfStr as String
        }
    } else if type == .array {
        var arrayRef: CGPDFArrayRef?
        if CGPDFObjectGetValue(object, .array, &arrayRef), let arr = arrayRef {
            var texts: [String] = []
            let count = CGPDFArrayGetCount(arr)
            for idx in 0..<count {
                var element: CGPDFObjectRef?
                if CGPDFArrayGetObject(arr, idx, &element), let e = element,
                   let str = cgpdfObjectToString(e) {
                    texts.append(str)
                }
            }
            return texts.joined()
        }
    }
    return nil
}
#endif

struct SPS: ParsableCommand {
    static let configuration = CommandConfiguration(
        abstract: "Semantic PDF Scanner",
        subcommands: [Scan.self, Index.self, Query.self, ExportMatrix.self]
    )
}

extension SPS {
    struct Scan: ParsableCommand {
        static let configuration = CommandConfiguration(abstract: "Scan PDFs and produce an index")

        @Argument(help: "PDF files to scan")
        var pdfs: [String]

        @Option(name: .shortAndLong, help: "Path to output index JSON")
        var out: String

        @Flag(name: [.customLong("include-text"), .customLong("includeText")], help: "Include extracted text")
        var includeText = false

        @Flag(help: "Compute SHA256 digest for each document")
        var sha256 = false

        func run() throws {
            guard !pdfs.isEmpty else {
                throw ValidationError("At least one PDF must be provided.")
            }
            var docs: [IndexDoc] = []
            for path in pdfs {
                let url = URL(fileURLWithPath: path)
                let data = (try? Data(contentsOf: url)) ?? Data()
                let pages = extractPages(data: data, includeText: includeText)
                let hash = sha256 ? sha256Hex(data: data) : nil
                let doc = IndexDoc(id: UUID().uuidString, fileName: url.lastPathComponent, size: data.count, sha256: hash, pages: pages)
                docs.append(doc)
            }
            let index = IndexRoot(documents: docs)
            let enc = JSONEncoder()
            enc.outputFormatting = [.prettyPrinted, .sortedKeys]
            let json = try enc.encode(index)
            try json.write(to: URL(fileURLWithPath: out))
            print("SPS: wrote index -> \(out) (\(json.count) bytes, \(docs.count) doc(s))")
        }
    }
}

extension SPS {
    struct Index: ParsableCommand {
        static let configuration = CommandConfiguration(
            abstract: "Index operations",
            subcommands: [Validate.self]
        )

        struct Validate: ParsableCommand {
            static let configuration = CommandConfiguration(abstract: "Validate an index JSON")

            @Argument(help: "Path to index JSON file")
            var path: String

            func run() throws {
                let data = try Data(contentsOf: URL(fileURLWithPath: path))
                let dec = JSONDecoder()
                do {
                    _ = try dec.decode(IndexRoot.self, from: data)
                    print(#"{ "ok": true, "issues": [] }"#)
                } catch {
                    print(#"{ "ok": false, "issues": ["\#(error)"] }"#)
                    throw ExitCode(3)
                }
            }
        }
    }
}

extension SPS {
    struct Query: ParsableCommand {
        static let configuration = CommandConfiguration(abstract: "Query an index")

        @Argument(help: "Path to index JSON file")
        var index: String

        @Option(name: .customLong("q"), help: "Search term")
        var q: String

        func run() throws {
            let data = try Data(contentsOf: URL(fileURLWithPath: index))
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
    }
}

extension SPS {
    struct ExportMatrix: ParsableCommand {
        static let configuration = CommandConfiguration(abstract: "Export Midi2Swift matrix skeleton")

        @Argument(help: "Path to index JSON file")
        var index: String

        @Option(name: .shortAndLong, help: "Output path for matrix JSON")
        var out: String

        func run() throws {
            let data = try Data(contentsOf: URL(fileURLWithPath: index))
            let index = try JSONDecoder().decode(IndexRoot.self, from: data)
            let detected = TableDetector.detect(from: index)
            struct Matrix: Codable {
                var messages: [MatrixEntry]
                var terms: [MatrixEntry]
            }
            let matrix = Matrix(messages: detected.messages, terms: detected.terms)
            let enc = JSONEncoder()
            enc.outputFormatting = [.prettyPrinted, .sortedKeys]
            let outData = try enc.encode(matrix)
            try outData.write(to: URL(fileURLWithPath: out))
            print("SPS: wrote matrix skeleton -> \(out)")
        }
    }
}

SPS.main()

// © 2025 Contexter alias Benedikt Eickhoff 🛡️ All rights reserved.

