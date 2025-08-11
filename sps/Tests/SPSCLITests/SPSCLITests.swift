import XCTest
@testable import SPSCLI
import ArgumentParser
import Foundation
#if canImport(Glibc)
import Glibc
#else
import Darwin
#endif

private let samplePDFBase64 = "JVBERi0xLjQKMSAwIG9iago8PCAvVHlwZSAvQ2F0YWxvZyAvUGFnZXMgMiAwIFIgPj4KZW5kb2JqCjIgMCBvYmoKPDwgL1R5cGUgL1BhZ2VzIC9LaWRzIFszIDAgUl0gL0NvdW50IDEgPj4KZW5kb2JqCjMgMCBvYmoKPDwgL1R5cGUgL1BhZ2UgL1BhcmVudCAyIDAgUiAvTWVkaWFCb3ggWzAgMCAyMDAgMjAwXSAvQ29udGVudHMgNCAwIFIgL1Jlc291cmNlcyA8PCAvRm9udCA8PCAvRjEgNSAwIFIgPj4gPj4gPj4KZW5kb2JqCjQgMCBvYmoKPDwgL0xlbmd0aCA0NCA+PgpzdHJlYW0KQlQgL0YxIDI0IFRmIDcyIDEyMCBUZCAoSGVsbG8pIFRqIEVUCmVuZHN0cmVhbQplbmRvYmoKNSAwIG9iago8PCAvVHlwZSAvRm9udCAvU3VidHlwZSAvVHlwZTEgL0Jhc2VGb250IC9IZWx2ZXRpY2EgPj4KZW5kb2JqCnhyZWYKMCA2CjAwMDAwMDAwMDAgNjU1MzUgZiAKMDAwMDAwMDAxMCAwMDAwMCBuIAowMDAwMDAwMDUzIDAwMDAwIG4gCjAwMDAwMDAxMDAgMDAwMDAgbiAKMDAwMDAwMDIxMSAwMDAwMCBuIAowMDAwMDAwMzAwIDAwMDAwIG4gCnRyYWlsZXIKPDwgL1NpemUgNiAvUm9vdCAxIDAgUiA+PgpzdGFydHhyZWYKMzYxCiUlRU9G"

private func canonicalData(from data: Data) throws -> Data {
    let obj = try JSONSerialization.jsonObject(with: data, options: [])
    return try JSONSerialization.data(withJSONObject: obj, options: [.sortedKeys, .prettyPrinted])
}

final class SPSCLITests: XCTestCase {
    func testSHA256FallbackDeterministic() throws {
        let data = Data([0,1,2,3,4,5,6,7,8,9])
        let expected = "sum64-000000000000002d"
        XCTAssertEqual(sha256Hex(data: data), expected)
        XCTAssertEqual(sha256Hex(data: data), expected)
    }

    func testScanProducesDeterministicJSONAndSHA() throws {
        let pdfData = Data(base64Encoded: samplePDFBase64)!
        let tempDir = FileManager.default.temporaryDirectory
        let pdfURL = tempDir.appendingPathComponent("sample.pdf")
        try pdfData.write(to: pdfURL)
        let outURL = tempDir.appendingPathComponent("out.json")
        let cmd = try SPS.Scan.parse([pdfURL.path, "--out", outURL.path, "--sha256"])
        try cmd.run()
        let data = try Data(contentsOf: outURL)
        XCTAssertEqual(data, try canonicalData(from: data))
        let index = try JSONDecoder().decode(IndexRoot.self, from: data)
        XCTAssertEqual(index.documents.first?.sha256, sha256Hex(data: pdfData))
    }

    func testIncludeTextUsesStubOnLinux() throws {
        let pdfData = Data(base64Encoded: samplePDFBase64)!
        let tempDir = FileManager.default.temporaryDirectory
        let pdfURL = tempDir.appendingPathComponent("sample.pdf")
        try pdfData.write(to: pdfURL)
        let outURL = tempDir.appendingPathComponent("out.json")
        let cmd = try SPS.Scan.parse([pdfURL.path, "--out", outURL.path, "--include-text"])
        try cmd.run()
        let data = try Data(contentsOf: outURL)
        let index = try JSONDecoder().decode(IndexRoot.self, from: data)
        XCTAssertEqual(index.documents.first?.pages.first?.text, "(text extraction unavailable)")
    }

#if os(macOS)
    func testExtractedCoordinates() throws {
        let pdfData = Data(base64Encoded: samplePDFBase64)!
        let pages = extractPages(data: pdfData, includeText: true)
        XCTAssertEqual(pages.count, 1)
        let line = pages.first?.lines.first
        XCTAssertEqual(line?.text, "Hello")
        XCTAssertEqual(line?.x, 72, accuracy: 0.1)
        XCTAssertEqual(line?.y, 120, accuracy: 0.1)
        XCTAssertEqual(line?.height, 24, accuracy: 0.1)
        XCTAssertGreaterThan(line!.width, 50)
    }
#endif

    func testScanWithoutIncludeTextEmpty() throws {
        let pdfData = Data(base64Encoded: samplePDFBase64)!
        let tempDir = FileManager.default.temporaryDirectory
        let pdfURL = tempDir.appendingPathComponent("sample.pdf")
        try pdfData.write(to: pdfURL)
        let outURL = tempDir.appendingPathComponent("out2.json")
        let cmd = try SPS.Scan.parse([pdfURL.path, "--out", outURL.path])
        try cmd.run()
        let data = try Data(contentsOf: outURL)
        let index = try JSONDecoder().decode(IndexRoot.self, from: data)
        XCTAssertEqual(index.documents.first?.pages.first?.text, "")
    }

    func testIndexValidateOutputsOK() throws {
        let pdfData = Data(base64Encoded: samplePDFBase64)!
        let tempDir = FileManager.default.temporaryDirectory
        let pdfURL = tempDir.appendingPathComponent("sample.pdf")
        try pdfData.write(to: pdfURL)
        let indexURL = tempDir.appendingPathComponent("index.json")
        let scanCmd = try SPS.Scan.parse([pdfURL.path, "--out", indexURL.path])
        try scanCmd.run()
        let devNull = open("/dev/null", O_WRONLY)
        let original = dup(STDOUT_FILENO)
        dup2(devNull, STDOUT_FILENO)
        let idxCmd = try SPS.Index.Validate.parse([indexURL.path])
        try idxCmd.run()
        dup2(original, STDOUT_FILENO)
        close(original)
        close(devNull)
        let data = try Data(contentsOf: indexURL)
        XCTAssertEqual(data, try canonicalData(from: data))
    }

    func testQueryReturnsDeterministicHits() throws {
        let pdfData = Data(base64Encoded: samplePDFBase64)!
        let tempDir = FileManager.default.temporaryDirectory
        let pdfURL = tempDir.appendingPathComponent("sample.pdf")
        try pdfData.write(to: pdfURL)
        let indexURL = tempDir.appendingPathComponent("index.json")
        let scanCmd = try SPS.Scan.parse([pdfURL.path, "--out", indexURL.path, "--include-text"])
        try scanCmd.run()
        let devNull = open("/dev/null", O_WRONLY)
        let original = dup(STDOUT_FILENO)
        dup2(devNull, STDOUT_FILENO)
        let qCmd = try SPS.Query.parse([indexURL.path, "--q", "extraction"])
        try qCmd.run()
        dup2(original, STDOUT_FILENO)
        close(original)
        close(devNull)
        let indexData = try Data(contentsOf: indexURL)
        let index = try JSONDecoder().decode(IndexRoot.self, from: indexData)
        var hits: [[String: Any]] = []
        for doc in index.documents {
            for page in doc.pages {
                if page.text.lowercased().contains("extraction") {
                    hits.append(["docId": doc.id, "page": page.number, "snippet": page.text])
                }
            }
        }
        XCTAssertEqual(hits.count, 1)
    }

    private func writeTestIndex() throws -> URL {
        let tempDir = FileManager.default.temporaryDirectory
        let indexURL = tempDir.appendingPathComponent("range-index.json")
        let pages = [
            IndexPage(number: 1, text: "hit", lines: []),
            IndexPage(number: 2, text: "hit", lines: []),
            IndexPage(number: 3, text: "hit", lines: [])
        ]
        let doc = IndexDoc(id: "1", fileName: "dummy", size: 0, sha256: nil, pages: pages)
        let index = IndexRoot(documents: [doc])
        let enc = JSONEncoder()
        enc.outputFormatting = [.prettyPrinted, .sortedKeys]
        try enc.encode(index).write(to: indexURL)
        return indexURL
    }

    func testQueryPageRangeSinglePage() throws {
        let indexURL = try writeTestIndex()
        let pipe = Pipe()
        let original = dup(STDOUT_FILENO)
        dup2(pipe.fileHandleForWriting.fileDescriptor, STDOUT_FILENO)
        let cmd = try SPS.Query.parse([indexURL.path, "--q", "hit", "--page-range", "2"])
        try cmd.run()
        pipe.fileHandleForWriting.closeFile()
        dup2(original, STDOUT_FILENO)
        close(original)
        let data = pipe.fileHandleForReading.readDataToEndOfFile()
        let obj = try JSONSerialization.jsonObject(with: data) as! [String: Any]
        let hits = obj["hits"] as? [[String: Any]]
        let pages = hits?.compactMap { $0["page"] as? Int }
        XCTAssertEqual(pages, [2])
    }

    func testQueryPageRangeInclusiveRange() throws {
        let indexURL = try writeTestIndex()
        let pipe = Pipe()
        let original = dup(STDOUT_FILENO)
        dup2(pipe.fileHandleForWriting.fileDescriptor, STDOUT_FILENO)
        let cmd = try SPS.Query.parse([indexURL.path, "--q", "hit", "--page-range", "1-2"])
        try cmd.run()
        pipe.fileHandleForWriting.closeFile()
        dup2(original, STDOUT_FILENO)
        close(original)
        let data = pipe.fileHandleForReading.readDataToEndOfFile()
        let obj = try JSONSerialization.jsonObject(with: data) as! [String: Any]
        let hits = obj["hits"] as? [[String: Any]]
        let pages = hits?.compactMap { $0["page"] as? Int }
        XCTAssertEqual(pages, [1,2])
    }

    func testQueryPageRangeInvalidInput() throws {
        let indexURL = try writeTestIndex()
        let cmd = try SPS.Query.parse([indexURL.path, "--q", "hit", "--page-range", "2-"])
        XCTAssertThrowsError(try cmd.run())
    }

    func testExportMatrixDeterministic() throws {
        let tempDir = FileManager.default.temporaryDirectory
        let indexPath = tempDir.appendingPathComponent("index.json")
        let page = IndexPage(number: 1, text: "Test Message and Term line", lines: [])
        let doc = IndexDoc(id: "1", fileName: "dummy", size: 0, sha256: nil, pages: [page])
        let index = IndexRoot(documents: [doc])
        let enc = JSONEncoder()
        enc.outputFormatting = [.prettyPrinted, .sortedKeys]
        try enc.encode(index).write(to: indexPath)
        let outURL = tempDir.appendingPathComponent("matrix.json")
        let cmd = try SPS.ExportMatrix.parse([indexPath.path, "--out", outURL.path])
        try cmd.run()
        let data = try Data(contentsOf: outURL)
        XCTAssertEqual(data, try canonicalData(from: data))
        let obj = try JSONSerialization.jsonObject(with: data, options: []) as! [String: Any]
        let msgs = obj["messages"] as? [[String: Any]]
        let terms = obj["terms"] as? [[String: Any]]
        XCTAssertEqual(msgs?.count, 1)
        XCTAssertEqual(terms?.count, 1)
    }
}

// © 2025 Contexter alias Benedikt Eickhoff 🛡️ All rights reserved.
