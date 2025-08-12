import Foundation
#if canImport(CryptoKit)
import CryptoKit
#endif
#if os(macOS)
import CoreGraphics
import CoreText
import PDFKit
#elseif os(Linux)
import Glibc
#endif
import ArgumentParser
import Validation

let SPS_DEBUG: Bool = ProcessInfo.processInfo.environment["SPS_DEBUG"] != nil

struct IndexDoc: Codable {
    var id: String
    var fileName: String
    var size: Int
    var sha256: String?
    var pages: [IndexPage]
}

struct TextLine: Codable {
    var text: String
    var x: Double
    var y: Double
    var width: Double
    var height: Double
    // Whether this token ends with a hyphenation marker (soft or hard)
    var hyphenated: Bool?
}

// Per-character bounding box used for grouping into lines. Use Double for portability.
struct CharBox {
    var text: String
    var x: Double
    var y: Double
    var width: Double
    var height: Double
}

struct IndexPage: Codable {
    var number: Int
    var text: String
    var lines: [TextLine]
    // Optional finer-grained tokens (word-level) extracted by PDFKit fallback.
    var words: [TextLine]?
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
        return [IndexPage(number: 1, text: "", lines: [])]
    }
    #if os(macOS)
    guard let provider = CGDataProvider(data: data as CFData),
          let doc = CGPDFDocument(provider) else {
        return [IndexPage(number: 1, text: "", lines: [])]
    }

    struct CharBox {
        var text: String
        var x: CGFloat
        var y: CGFloat
        var width: CGFloat
        var height: CGFloat
    }

    struct ScanState {
        var tm = CGAffineTransform.identity
        var tlm = CGAffineTransform.identity
        var leading: CGFloat = 0
        var font: CTFont?
        var fontSize: CGFloat = 0
        var chars: [CharBox] = []
        var fontsDict: CGPDFDictionaryRef?
        var fontCache: [String: CTFont] = [:]

        mutating func setFont(name: String, size: CGFloat) {
            fontSize = size
            if let cached = fontCache[name] {
                font = CTFontCreateCopyWithAttributes(cached, size, nil, nil)
                return
            }
            guard let fontsDict = fontsDict else {
                if SPS_DEBUG { print("[SPS_DEBUG] fontsDict is nil for font resource: \(name)") }
                return
            }
            var obj: CGPDFObjectRef?
            if SPS_DEBUG { print("[SPS_DEBUG] looking up font resource key=\(name)") }
            guard CGPDFDictionaryGetObject(fontsDict, name, &obj) else {
                if SPS_DEBUG { print("[SPS_DEBUG] CGPDFDictionaryGetObject failed for key=\(name)") }
                return
            }
            var dict: CGPDFDictionaryRef?
            guard CGPDFObjectGetValue(obj!, .dictionary, &dict), let fontDict = dict else {
                if SPS_DEBUG { print("[SPS_DEBUG] CGPDFObjectGetValue -> dictionary failed for key=\(name)") }
                return
            }
            var basePtr: UnsafePointer<Int8>?
            guard CGPDFDictionaryGetName(fontDict, "BaseFont", &basePtr), let base = basePtr else {
                if SPS_DEBUG { print("[SPS_DEBUG] BaseFont not found in font dict for key=\(name)") }
                return
            }
            let baseName = String(cString: base)
            if SPS_DEBUG { print("[SPS_DEBUG] resolved base font name=\(baseName) for resource key=\(name)") }
            let ct = CTFontCreateWithName(baseName as CFString, size, nil)
            fontCache[name] = ct
            font = ct
        }

        mutating func show(_ string: String) {
            guard let font = font else { return }
            let charsArray = Array(string)
            let utf16 = Array(string.utf16)
            var glyphs = [CGGlyph](repeating: 0, count: utf16.count)
            CTFontGetGlyphsForCharacters(font, utf16, &glyphs, utf16.count)
            var advances = [CGSize](repeating: .zero, count: utf16.count)
            CTFontGetAdvancesForGlyphs(font, .horizontal, glyphs, &advances, utf16.count)
            for (idx, ch) in charsArray.enumerated() {
                let adv = advances[idx].width
                chars.append(CharBox(text: String(ch), x: Double(tm.tx), y: Double(tm.ty), width: Double(adv), height: Double(fontSize)))
                tm = tm.translatedBy(x: adv, y: 0)
            }
        }
    }

    var pages: [IndexPage] = []
    for i in 1...doc.numberOfPages {
        guard let page = doc.page(at: i) else { continue }
        // Use modern API: obtain the page dictionary via `page.dictionary` (optional)
        let pageDict = page.dictionary
        var resources: CGPDFDictionaryRef?
        if let dict = pageDict {
            CGPDFDictionaryGetDictionary(dict, "Resources", &resources)
        }
        var fontsDict: CGPDFDictionaryRef?
        if let res = resources {
            CGPDFDictionaryGetDictionary(res, "Font", &fontsDict)
        }

        var state = ScanState()
        state.fontsDict = fontsDict

        let content = CGPDFContentStreamCreateWithPage(page)
        let table = CGPDFOperatorTableCreate()!

        let Tj: CGPDFOperatorCallback = { scanner, info in
            guard let info = info?.assumingMemoryBound(to: ScanState.self) else { return }
            var strRef: CGPDFStringRef?
            if CGPDFScannerPopString(scanner, &strRef), let s = strRef,
               let cf = CGPDFStringCopyTextString(s) {
                let text = cf as String
                if SPS_DEBUG { print("[SPS_DEBUG] Tj text=\(text)") }
                // Mutating methods on a pointee return a copy; make mutation persistent by
                // modifying a local, then writing back to the pointer.
                var st = info.pointee
                st.show(text)
                info.pointee = st
            }
        }

        let TJ: CGPDFOperatorCallback = { scanner, info in
            guard let info = info?.assumingMemoryBound(to: ScanState.self) else { return }
            var arrayRef: CGPDFArrayRef?
            if !CGPDFScannerPopArray(scanner, &arrayRef) { return }
            guard let arrayRef = arrayRef else { return }
            let count = CGPDFArrayGetCount(arrayRef)
            for idx in 0..<count {
                var element: CGPDFObjectRef?
                if !CGPDFArrayGetObject(arrayRef, idx, &element) { continue }
                let type = CGPDFObjectGetType(element!)
                if type == .string {
                    if let str = cgpdfObjectToString(element!) {
                        if SPS_DEBUG { print("[SPS_DEBUG] TJ string=\(str)") }
                        var st = info.pointee
                        st.show(str)
                        info.pointee = st
                    }
                } else if type == .real || type == .integer {
                    var val: CGPDFReal = 0
                    CGPDFObjectGetValue(element!, .real, &val)
                    info.pointee.tm.tx -= CGFloat(val) * info.pointee.fontSize / 1000
                }
            }
        }

        let Tf: CGPDFOperatorCallback = { scanner, info in
            guard let info = info?.assumingMemoryBound(to: ScanState.self) else { return }
            var size: CGPDFReal = 0
            var namePtr: UnsafePointer<Int8>?
            guard CGPDFScannerPopNumber(scanner, &size), CGPDFScannerPopName(scanner, &namePtr), let n = namePtr else { return }
            let fontName = String(cString: n)
            if SPS_DEBUG { print("[SPS_DEBUG] Tf font=\(fontName) size=\(size)") }
            info.pointee.setFont(name: fontName, size: CGFloat(size))
        }

        let Td: CGPDFOperatorCallback = { scanner, info in
            guard let info = info?.assumingMemoryBound(to: ScanState.self) else { return }
            var ty: CGPDFReal = 0
            var tx: CGPDFReal = 0
            guard CGPDFScannerPopNumber(scanner, &ty), CGPDFScannerPopNumber(scanner, &tx) else { return }
            info.pointee.tlm = info.pointee.tlm.translatedBy(x: CGFloat(tx), y: CGFloat(ty))
            info.pointee.tm = info.pointee.tlm
        }

        let TD: CGPDFOperatorCallback = { scanner, info in
            guard let info = info?.assumingMemoryBound(to: ScanState.self) else { return }
            var ty: CGPDFReal = 0
            var tx: CGPDFReal = 0
            guard CGPDFScannerPopNumber(scanner, &ty), CGPDFScannerPopNumber(scanner, &tx) else { return }
            info.pointee.leading = -CGFloat(ty)
            info.pointee.tlm = info.pointee.tlm.translatedBy(x: CGFloat(tx), y: CGFloat(ty))
            info.pointee.tm = info.pointee.tlm
        }

        let Tm: CGPDFOperatorCallback = { scanner, info in
            guard let info = info?.assumingMemoryBound(to: ScanState.self) else { return }
            var a: CGPDFReal = 0, b: CGPDFReal = 0, c: CGPDFReal = 0, d: CGPDFReal = 0, e: CGPDFReal = 0, f: CGPDFReal = 0
            guard CGPDFScannerPopNumber(scanner, &f), CGPDFScannerPopNumber(scanner, &e),
                  CGPDFScannerPopNumber(scanner, &d), CGPDFScannerPopNumber(scanner, &c),
                  CGPDFScannerPopNumber(scanner, &b), CGPDFScannerPopNumber(scanner, &a) else { return }
            let t = CGAffineTransform(a: CGFloat(a), b: CGFloat(b), c: CGFloat(c), d: CGFloat(d), tx: CGFloat(e), ty: CGFloat(f))
            info.pointee.tlm = t
            info.pointee.tm = t
        }

        let Tstar: CGPDFOperatorCallback = { _, info in
            guard let info = info?.assumingMemoryBound(to: ScanState.self) else { return }
            info.pointee.tlm = info.pointee.tlm.translatedBy(x: 0, y: -info.pointee.leading)
            info.pointee.tm = info.pointee.tlm
        }

        CGPDFOperatorTableSetCallback(table, "Tj", Tj)
        CGPDFOperatorTableSetCallback(table, "TJ", TJ)
        CGPDFOperatorTableSetCallback(table, "Tf", Tf)
        CGPDFOperatorTableSetCallback(table, "Td", Td)
        CGPDFOperatorTableSetCallback(table, "TD", TD)
        CGPDFOperatorTableSetCallback(table, "Tm", Tm)
        CGPDFOperatorTableSetCallback(table, "T*", Tstar)

        // CGPDFScannerCreate returns a non-optional CGPDFScannerRef in this SDK; call directly.
        let scanner = CGPDFScannerCreate(content, table, &state)
        CGPDFScannerScan(scanner)

        let epsilon: CGFloat = 2
        let sortedChars = state.chars.sorted { (a, b) -> Bool in
            if abs(a.y - b.y) > epsilon {
                return a.y > b.y
            }
            return a.x < b.x
        }

        var lineGroups: [[CharBox]] = []
        for ch in sortedChars {
            if var last = lineGroups.last, abs(last.first!.y - ch.y) <= epsilon {
                lineGroups[lineGroups.count - 1].append(ch)
            } else {
                lineGroups.append([ch])
            }
        }

        var lines: [TextLine] = []
        for group in lineGroups {
                    // (hyphen handling note)
            let text = group.map { $0.text }.joined()
            let minX = group.map { $0.x }.min() ?? 0
            let maxX = group.map { $0.x + $0.width }.max() ?? 0
            let minY = group.map { $0.y }.min() ?? 0
            let maxY = group.map { $0.y + $0.height }.max() ?? 0
            lines.append(TextLine(text: text,
                                  x: Double(minX),
                                  y: Double(minY),
                                  width: Double(maxX - minX),
                                  height: Double(maxY - minY)))
        }

        if SPS_DEBUG {
            print("[SPS_DEBUG] page=\(i) chars=\(state.chars.count) groups=\(lineGroups.count) lines=\(lines.count)")
            if !state.chars.isEmpty {
                let sample = state.chars.prefix(20).map { $0.text }.joined()
                print("[SPS_DEBUG] sample chars text=\(sample)")
            }
            if !lines.isEmpty {
                print("[SPS_DEBUG] sample line[0]=\(lines.first!.text)")
            }
        }

        let pageText = lines.map { $0.text }.joined(separator: "\n")
        pages.append(IndexPage(number: i, text: pageText, lines: lines))
    }

    // If CoreGraphics extraction produced no lines, try PDFKit-based extraction as a fallback.
    let empty = pages.allSatisfy { $0.lines.isEmpty }
    if empty {
        if SPS_DEBUG { print("[SPS_DEBUG] CoreGraphics extraction yielded no lines; trying PDFKit fallback") }
        if let pdfDoc = PDFDocument(data: data) {
            // Use PDFKit to extract per-character bounding boxes and reconstruct lines.
            var pkPages: [IndexPage] = []
            for pidx in 0..<pdfDoc.pageCount {
                guard let p = pdfDoc.page(at: pidx) else { continue }
                let text = p.string ?? ""
                let ns = text as NSString
                var charBoxes: [CharBox] = []
                var ci = 0
                while ci < ns.length {
                    let range = NSRange(location: ci, length: 1)
                    let sel = p.selection(for: range)
                    var ssub = ns.substring(with: range)
                    var advance = 1
                    if let sel = sel, let sstr = sel.string, !sstr.isEmpty {
                        ssub = sstr
                        advance = (sstr as NSString).length
                    }
                    var rect = CGRect.zero
                    if let sel = sel {
                        rect = sel.bounds(for: p)
                    }
                    charBoxes.append(CharBox(text: ssub, x: rect.origin.x, y: rect.origin.y, width: rect.size.width, height: rect.size.height))
                    ci += advance
                }

                // Group characters into lines using vertical clustering
                let epsilon: CGFloat = 2
                let sortedChars = charBoxes.sorted { (a, b) -> Bool in
                    if abs(a.y - b.y) > epsilon { return a.y > b.y }
                    return a.x < b.x
                }
                var lineGroups: [[CharBox]] = []
                for ch in sortedChars {
                    if var last = lineGroups.last, abs(last.first!.y - ch.y) <= epsilon {
                        lineGroups[lineGroups.count - 1].append(ch)
                    } else {
                        lineGroups.append([ch])
                    }
                }

                var lines: [TextLine] = []
                for group in lineGroups {
                    // (hyphen handling note)
                    let text = group.map { $0.text }.joined()
                    let minX = group.map { $0.x }.min() ?? 0
                    let maxX = group.map { $0.x + $0.width }.max() ?? 0
                    let minY = group.map { $0.y }.min() ?? 0
                    let maxY = group.map { $0.y + $0.height }.max() ?? 0
                    lines.append(TextLine(text: text, x: Double(minX), y: Double(minY), width: Double(maxX - minX), height: Double(maxY - minY), hyphenated: nil))
                }
                // Build word-level tokens per line and normalize unicode to NFC; handle hyphenation across lines.
                var words: [TextLine] = []
                var wordsByLine: [[TextLine]] = []
                for group in lineGroups {
                    // (hyphen handling note)
                    var currentChars: [CharBox] = []
                    var lineWords: [TextLine] = []
                    for ch in group {
                        let isSpace = ch.text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
                        if isSpace {
                            if !currentChars.isEmpty {
                                let wText = currentChars.map { $0.text }.joined()
                                let minX = currentChars.map { $0.x }.min() ?? 0
                                let maxX = currentChars.map { $0.x + $0.width }.max() ?? 0
                                let minY = currentChars.map { $0.y }.min() ?? 0
                                let maxY = currentChars.map { $0.y + $0.height }.max() ?? 0
                                let hasSoft = wText.contains("\u{00AD}")
                                let cleaned = wText.replacingOccurrences(of: "\u{00AD}", with: "")
                                let normalized = (cleaned as NSString).precomposedStringWithCanonicalMapping
                                lineWords.append(TextLine(text: normalized, x: Double(minX), y: Double(minY), width: Double(maxX - minX), height: Double(maxY - minY), hyphenated: hasSoft || normalized.hasSuffix("-")))
                                currentChars.removeAll()
                            }
                        } else {
                            currentChars.append(ch)
                        }
                    }
                    if !currentChars.isEmpty {
                        let wText = currentChars.map { $0.text }.joined()
                        let minX = currentChars.map { $0.x }.min() ?? 0
                        let maxX = currentChars.map { $0.x + $0.width }.max() ?? 0
                        let minY = currentChars.map { $0.y }.min() ?? 0
                        let maxY = currentChars.map { $0.y + $0.height }.max() ?? 0
                        let hasSoft = wText.contains("\u{00AD}")
                        let cleaned = wText.replacingOccurrences(of: "\u{00AD}", with: "")
                        let normalized = (cleaned as NSString).precomposedStringWithCanonicalMapping
                        lineWords.append(TextLine(text: normalized, x: Double(minX), y: Double(minY), width: Double(maxX - minX), height: Double(maxY - minY), hyphenated: hasSoft || normalized.hasSuffix("-")))
                        currentChars.removeAll()
                    }
                    wordsByLine.append(lineWords)
                }
                // Handle hyphenation: join trailing hyphenated words with next line's leading word
                for idx in 0..<wordsByLine.count {
                    if idx > 0, let prev = wordsByLine[idx-1].last, (prev.hyphenated == true || prev.text.hasSuffix("-")) {
                        // merge prev (without hyphen) with first of current line if exists
                        if !wordsByLine[idx].isEmpty {
                            let first = wordsByLine[idx].removeFirst()
                            let mergedText = String(prev.text.dropLast()) + first.text
                            // create merged bounding box spanning prev and first
                            let minX = min(prev.x, first.x)
                            let minY = min(prev.y, first.y)
                            let maxX = max(prev.x + prev.width, first.x + first.width)
                            let maxY = max(prev.y + prev.height, first.y + first.height)
                            let merged = TextLine(text: (mergedText as NSString).precomposedStringWithCanonicalMapping, x: minX, y: minY, width: maxX - minX, height: maxY - minY, hyphenated: nil)
                            // replace prev in previous line
                            var prevLine = wordsByLine[idx-1]
                            prevLine[prevLine.count-1] = merged
                            wordsByLine[idx-1] = prevLine
                        }
                    }
                }
                for lw in wordsByLine { words.append(contentsOf: lw) }
                pkPages.append(IndexPage(number: pidx+1, text: text, lines: lines, words: words))
            }
            if !pkPages.isEmpty {
                return pkPages
            }
        } else {
            if SPS_DEBUG { print("[SPS_DEBUG] PDFKit failed to create PDFDocument from data") }
        }
    }

    return pages
    #elseif os(Linux)
    if let handle = dlopen("libpdfium.so", RTLD_NOW) {
        dlclose(handle)
        return [IndexPage(number: 1, text: "(PDFium extraction not implemented)", lines: [])]
    } else {
        let msg = "SPS: PDFium not found. Run 'make deps' to install.\n"
        FileHandle.standardError.write(msg.data(using: .utf8)!)
        return [IndexPage(number: 1, text: "(text extraction unavailable)", lines: [])]
    }
    #else
    return [IndexPage(number: 1, text: "(text extraction unavailable)", lines: [])]
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
        subcommands: [Scan.self, Index.self, Query.self, ExportMatrix.self, Status.self]
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

        @Flag(name: .long, help: "Wait for the scan to finish")
        var wait = false

        func run() throws {
            guard !pdfs.isEmpty else {
                throw ValidationError("At least one PDF must be provided.")
            }
            let ticket = SPSJobQueue.shared.enqueueScan(pdfs: pdfs, out: out, includeText: includeText, sha256: sha256)
            print("SPS: enqueued scan job -> \(ticket.uuidString)")
            guard wait else { return }
            while let job = SPSJobQueue.shared.status(id: ticket), job.state == .pending || job.state == .running {
                Thread.sleep(forTimeInterval: 0.1)
            }
            if let job = SPSJobQueue.shared.status(id: ticket) {
                switch job.state {
                case .completed:
                    print("Job completed: \(job.result ?? "")")
                case .failed:
                    print("Job failed: \(job.error ?? "unknown error")")
                default:
                    print("Job \(job.state.rawValue)")
                }
            } else {
                print("Job not found")
            }
        }
    }
}

extension SPS {
    struct Status: ParsableCommand {
        static let configuration = CommandConfiguration(abstract: "Check job status")

        @Argument(help: "Ticket ID returned by 'scan'")
        var ticket: String

        func run() throws {
            guard let id = UUID(uuidString: ticket),
                  let job = SPSJobQueue.shared.status(id: id) else {
                print("Job not found")
                return
            }
            let pct = Int(job.progress * 100)
            let messages = [
                "Scanning like a champ!",
                "Hang tight, excellence takes time.",
                "You're doing great!",
                "Almost there!"
            ]
            let msg = messages[Int(Date().timeIntervalSince1970) % messages.count]
            switch job.state {
            case .completed:
                print("Job completed: \(job.result ?? "")")
            case .failed:
                print("Job failed: \(job.error ?? "unknown error")")
            case .pending, .running:
                print("Job \(job.state.rawValue) - \(pct)% - \(msg)")
            }
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

/// Parse a comma-separated list of page numbers and ranges like "1-3,5".
/// - Parameter value: Raw page-range string from the CLI.
/// - Returns: Set of page numbers to include.
/// - Throws: `ValidationError` if the value cannot be parsed.
func parsePageRange(_ value: String) throws -> Set<Int> {
    var pages = Set<Int>()
    for part in value.split(separator: ",") {
        if part.contains("-") {
            let bounds = part.split(separator: "-")
            guard bounds.count == 2,
                  let start = Int(bounds[0]),
                  let end = Int(bounds[1]),
                  start > 0, end >= start else {
                throw ValidationError("Invalid page range segment: \(part)")
            }
            for p in start...end { pages.insert(p) }
        } else {
            guard let page = Int(part), page > 0 else {
                throw ValidationError("Invalid page number: \(part)")
            }
            pages.insert(page)
        }
    }
    return pages
}

extension SPS {
    struct Query: ParsableCommand {
        static let configuration = CommandConfiguration(abstract: "Query an index")

        @Argument(help: "Path to index JSON file")
        var index: String

        @Option(name: .customLong("q"), help: "Search term")
        var q: String

        @Option(name: .customLong("page-range"), help: "Comma-separated list of pages or ranges (e.g., 1-3,5)")
        var pageRange: String?

        func run() throws {
            let data = try Data(contentsOf: URL(fileURLWithPath: index))
            let index = try JSONDecoder().decode(IndexRoot.self, from: data)
            let allowedPages = try pageRange.map { try parsePageRange($0) }
            var hits: [[String: Any]] = []
            for doc in index.documents {
                for page in doc.pages {
                    if let allowed = allowedPages, !allowed.contains(page.number) { continue }
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

        @Flag(name: [.customShort("b"), .long], help: "Include bitfield section")
        var bitfields: Bool = false

        @Flag(name: [.customShort("r"), .long], help: "Include range section")
        var ranges: Bool = false

        @Flag(name: [.customShort("e"), .long], help: "Include enum section")
        var enums: Bool = false

        @Flag(name: [.customShort("v"), .long], help: "Run validation hooks and emit report JSON")
        var validate: Bool = false

        func run() throws {
            let data = try Data(contentsOf: URL(fileURLWithPath: index))
            let index = try JSONDecoder().decode(IndexRoot.self, from: data)
            let detected = TableDetector.detect(from: index)
            struct Matrix: Codable {
                var schemaVersion: String
                var messages: [MatrixEntry]
                var terms: [MatrixEntry]
                var bitfields: [BitField]?
                var ranges: [RangeSpec]?
                var enums: [EnumSpec]?
            }
            var matrix = Matrix(schemaVersion: "2.0", messages: detected.messages, terms: detected.terms)
            if bitfields { matrix.bitfields = [] }
            if ranges { matrix.ranges = [] }
            if enums { matrix.enums = [] }
            let enc = JSONEncoder()
            enc.outputFormatting = [.prettyPrinted, .sortedKeys]
            let outData = try enc.encode(matrix)
            try outData.write(to: URL(fileURLWithPath: out))
            print("SPS: wrote matrix skeleton -> \(out)")
            if validate {
                let report = Validator.validate(matrixData: outData)
                let reportURL = URL(fileURLWithPath: out + ".validation.json")
                let reportEnc = JSONEncoder()
                reportEnc.outputFormatting = [.prettyPrinted, .sortedKeys]
                let reportData = try reportEnc.encode(report)
                try reportData.write(to: reportURL)
                print("SPS: validation report -> \(reportURL.path)")
            }
        }
    }
}

SPS.main()

// © 2025 Contexter alias Benedikt Eickhoff 🛡️ All rights reserved.


// Helper: cluster character boxes into reading-order groups (straight pass-through in current form)
private func groupCharacters(from boxes: [CharBox]) -> [CharBox] {
    return boxes.sorted { (a, b) -> Bool in
        if abs(a.y - b.y) > 2 { return a.y > b.y }
        return a.x < b.x
    }
}
