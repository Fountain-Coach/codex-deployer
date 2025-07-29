import XCTest
@testable import Teatro

final class MIDI2Tests: XCTestCase {
    func testUMPEncoderProducesWords() {
        let note = MIDI2Note(channel: 0, note: 60, velocity: 0.5, duration: 0.1)
        let packets = UMPEncoder.encode(note)
        XCTAssertEqual(packets.count, 2)
    }

    func testCsoundRendererWritesFile() throws {
        let score = CsoundScore(orchestra: "f 1 0 0 10 1", score: "i1 0 1 0.5")
        let url = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString).appendingPathExtension("csd")
        CsoundRenderer.renderToFile(score, to: url.path)
        XCTAssertTrue(FileManager.default.fileExists(atPath: url.path))
    }
}
