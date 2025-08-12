import XCTest
@testable import SPSCLI

final class JobQueueTests: XCTestCase {
    func testEnqueueAndComplete() throws {
        let tmpPDF = FileManager.default.temporaryDirectory.appendingPathComponent("sample.pdf")
        try Data().write(to: tmpPDF)
        let outPath = FileManager.default.temporaryDirectory.appendingPathComponent("index.json").path
        let ticket = SPSJobQueue.shared.enqueueScan(pdfs: [tmpPDF.path], out: outPath, includeText: false, sha256: false)
        var final: SPSJobQueue.Job? = nil
        for _ in 0..<50 {
            final = SPSJobQueue.shared.status(id: ticket)
            if final?.state == .completed || final?.state == .failed { break }
            usleep(100_000)
        }
        XCTAssertNotNil(final)
        XCTAssertEqual(final?.state, .completed)
    }
}

// © 2025 Contexter alias Benedikt Eickhoff 🛡️ All rights reserved.
