import XCTest
@testable import Teatro

final class TeatroSamplerTests: XCTestCase {

    struct MockSampleSource: SampleSource {
        var updates: [MIDI2NoteEvent] = []
        mutating func render(buffer: inout [Float], frameCount: Int) {}
        mutating func update(with event: MIDI2NoteEvent) {
            updates.append(event)
        }
    }

    func testPlayAddsVoice() async throws {
        var sampler = TeatroSampler()
        var source = MockSampleSource()
        let event = MIDI2NoteEvent(channel: 0, note: 60, velocity: 0.5,
                                   pitch: 60, timbre: SIMD4<Float>(0,0,0,0),
                                   articulation: "staccato", timestamp: 0)
        let id = await sampler.play(event, source: source)
        let count = await sampler.voiceCount()
        XCTAssertEqual(count, 1)
        let active = await sampler.activeVoices()
        XCTAssertTrue(active.contains(id))
    }

    func testCompatibilityBridgeDowncasts() {
        let event = MIDI2NoteEvent(channel: 0, note: 64, velocity: 1.0,
                                   pitch: 64, timbre: SIMD4<Float>(0,0,0,0),
                                   articulation: "legato", timestamp: 0)
        let midi1 = MIDICompatibilityBridge.toMIDINote(event)
        XCTAssertEqual(midi1.note, 64)
        XCTAssertEqual(midi1.velocity, 127)
    }
}
