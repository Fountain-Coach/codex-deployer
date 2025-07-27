import Foundation

/// Provides downcasting of MIDI2NoteEvent to legacy formats for
/// Csound and LilyPond while maintaining MIDI 2.0 expressiveness.
public struct MIDICompatibilityBridge {
    public static func toMIDINote(_ event: MIDI2NoteEvent) -> MIDINote {
        MIDINote(
            channel: event.channel,
            note: event.note,
            velocity: Int(event.velocity * 127),
            duration: 0.1
        )
    }

    public static func toCsoundScore(_ event: MIDI2NoteEvent) -> CsoundScore {
        let scoreLine = "i1 0 0.1 \(event.note) \(event.velocity)"
        return CsoundScore(orchestra: "f 1 0 0 10 1", score: scoreLine)
    }

    public static func toLilyScore(_ event: MIDI2NoteEvent) -> LilyScore {
        let lily = "c'" // simplified placeholder
        return LilyScore(lily)
    }
}
