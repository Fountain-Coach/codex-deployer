import Foundation
import Teatro

/// Simple audio engine bridging the TeatroSampler to the playground.
@MainActor
public enum MIDIAudioEngine {
    private static var sampler = TeatroSampler()
    private static var source: SampleSource = DummySource()

    public static func start() {}

    public static func play(note: MIDI2Note) async {
        let event = MIDI2NoteEvent(
            channel: note.channel,
            note: note.note,
            velocity: note.velocity,
            pitch: Float(note.note),
            timbre: SIMD4<Float>(repeating: 0),
            articulation: "default",
            timestamp: UInt64(Date().timeIntervalSince1970)
        )
        _ = await sampler.play(event, source: source)
    }

    struct DummySource: SampleSource {
        mutating func render(buffer: inout [Float], frameCount: Int) {}
        mutating func update(with event: MIDI2NoteEvent) {}
    }
}
