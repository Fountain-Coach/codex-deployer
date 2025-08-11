import XCTest
@testable import SPSCLI
import ArgumentParser
import Foundation

private let samplePDFBase64 = "JVBERi0xLjQKMSAwIG9iago8PCAvVHlwZSAvQ2F0YWxvZyAvUGFnZXMgMiAwIFIgPj4KZW5kb2JqCjIgMCBvYmoKPDwgL1R5cGUgL1BhZ2VzIC9LaWRzIFszIDAgUl0gL0NvdW50IDEgPj4KZW5kb2JqCjMgMCBvYmoKPDwgL1R5cGUgL1BhZ2UgL1BhcmVudCAyIDAgUiAvTWVkaWFCb3ggWzAgMCAyMDAgMjAwXSAvQ29udGVudHMgNCAwIFIgL1Jlc291cmNlcyA8PCAvRm9udCA8PCAvRjEgNSAwIFIgPj4gPj4gPj4KZW5kb2JqCjQgMCBvYmoKPDwgL0xlbmd0aCA0NCA+PgpzdHJlYW0KQlQgL0YxIDI0IFRmIDcyIDEyMCBUZCAoSGVsbG8pIFRqIEVUCmVuZHN0cmVhbQplbmRvYmoKNSAwIG9iago8PCAvVHlwZS AvRm9udCAvU3VidHlwZS AvVHlwZTE gL0Jhc2VGb250IC9IZWx2ZXRpY2EgPj4KZW5kb2JqCnhyZWYKMCA2CjAwMDAwMDAwMDAgNjU1MzUgZiAKMDAwMDAwMDAxMCAwMDAwMCBuIAowMDAwMDAwMDUzIDAwMDAwIG4 gCjAwMDAwMDAxMDA gMDAwMDA gbi AKMDAwMDAwMDIxMS AwMDAwMC BuIAowMDAwMDAwMzAwIDAwMDAwIG4 gCnRyYWlsZXIKPDwgL1NpemUgNi AvUm9vdCAxIDAgUiA+PgpzdGFydHhyZWYKMzYxCiUlRU9G"

final class OCRTests: XCTestCase {
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
    }
#endif

    func testExtractPagesInvalidPDFReturnsEmpty() throws {
        let data = Data([0x00, 0x01, 0x02])
        let pages = extractPages(data: data, includeText: true)
        XCTAssertEqual(pages.count, 1)
        XCTAssertEqual(pages.first?.text, "")
    }
}

// © 2025 Contexter alias Benedikt Eickhoff 🛡️ All rights reserved.
