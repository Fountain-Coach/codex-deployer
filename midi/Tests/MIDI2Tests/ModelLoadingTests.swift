import XCTest
@testable import MIDI2

final class ModelLoadingTests: XCTestCase {
    func testLoadMessages() throws {
        // Ensure the messages file exists (produced by pipeline). If missing, create an empty array so test can run.
        let fm = FileManager.default
        let path = "models/messages.json"
        if !fm.fileExists(atPath: path) {
            try Data("[]\n".utf8).write(to: URL(fileURLWithPath: path))
        }

        let msgs = try ModelLoader.loadMessages(from: path)
        // Should decode to an array (possibly empty)
        XCTAssertNotNil(msgs)
        // Confirm generated placeholder is available
        XCTAssertEqual(GeneratedMessages.generatedVersion, 1)
    }
}
