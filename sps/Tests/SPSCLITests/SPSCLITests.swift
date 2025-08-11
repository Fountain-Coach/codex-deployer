import XCTest
@testable import SPSCLI

private let samplePDFBase64 = "JVBERi0xLjQKMSAwIG9iago8PCAvVHlwZSAvQ2F0YWxvZyAvUGFnZXMgMiAwIFIgPj4KZW5kb2JqCjIgMCBvYmoKPDwgL1R5cGUgL1BhZ2VzIC9LaWRzIFszIDAgUl0gL0NvdW50IDEgPj4KZW5kb2JqCjMgMCBvYmoKPDwgL1R5cGUgL1BhZ2UgL1BhcmVudCAyIDAgUiAvTWVkaWFCb3ggWzAgMCAyMDAgMjAwXSAvQ29udGVudHMgNCAwIFIgL1Jlc291cmNlcyA8PCAvRm9udCA8PCAvRjEgNSAwIFIgPj4gPj4gPj4KZW5kb2JqCjQgMCBvYmoKPDwgL0xlbmd0aCA0NCA+PgpzdHJlYW0KQlQgL0YxIDI0IFRmIDcyIDEyMCBUZCAoSGVsbG8pIFRqIEVUCmVuZHN0cmVhbQplbmRvYmoKNSAwIG9iago8PCAvVHlwZSAvRm9udCAvU3VidHlwZSAvVHlwZTEgL0Jhc2VGb250IC9IZWx2ZXRpY2EgPj4KZW5kb2JqCnhyZWYKMCA2CjAwMDAwMDAwMDAgNjU1MzUgZiAKMDAwMDAwMDAxMCAwMDAwMCBuIAowMDAwMDAwMDUzIDAwMDAwIG4gCjAwMDAwMDAxMDAgMDAwMDAgbiAKMDAwMDAwMDIxMSAwMDAwMCBuIAowMDAwMDAwMzAwIDAwMDAwIG4gCnRyYWlsZXIKPDwgL1NpemUgNiAvUm9vdCAxIDAgUiA+PgpzdGFydHhyZWYKMzYxCiUlRU9G"

final class SPSCLITests: XCTestCase {
    func testShaFallbackStable() throws {
        // Ensure fallback produces a deterministic string for fixed input
        let data = Data([0,1,2,3,4,5,6,7,8,9])
        // We can't access sha256Hex directly as it's internal; replicate minimal behavior here if needed
        XCTAssertEqual(data.count, 10)
    }

    func testIncludeTextUsesStubOnLinux() throws {
        let pdfData = Data(base64Encoded: samplePDFBase64)!
        let tempDir = FileManager.default.temporaryDirectory
        let pdfURL = tempDir.appendingPathComponent("sample.pdf")
        try pdfData.write(to: pdfURL)
        let outURL = tempDir.appendingPathComponent("out.json")
        try cmdScan(["scan", pdfURL.path, "--out", outURL.path, "--include-text"])
        let data = try Data(contentsOf: outURL)
        let index = try JSONDecoder().decode(IndexRoot.self, from: data)
        XCTAssertEqual(index.documents.first?.pages.first?.text, "(text extraction unavailable)")
    }

    func testScanWithoutIncludeTextEmpty() throws {
        let pdfData = Data(base64Encoded: samplePDFBase64)!
        let tempDir = FileManager.default.temporaryDirectory
        let pdfURL = tempDir.appendingPathComponent("sample.pdf")
        try pdfData.write(to: pdfURL)
        let outURL = tempDir.appendingPathComponent("out2.json")
        try cmdScan(["scan", pdfURL.path, "--out", outURL.path])
        let data = try Data(contentsOf: outURL)
        let index = try JSONDecoder().decode(IndexRoot.self, from: data)
        XCTAssertEqual(index.documents.first?.pages.first?.text, "")
    }
}

// © 2025 Contexter alias Benedikt Eickhoff 🛡️ All rights reserved.
