## 7. MIDI 2.0 DSL

The Teatro View Engine includes a declarative Swift DSL for composing MIDI sequences. It enables Codex and GPT agents to structure musical timelines with precise note control, and render them to `.mid` files.

---

### 7.1 MIDINote

A single note event: pitch, velocity, channel, and duration in seconds.

```swift
public struct MIDINote {
    public let channel: Int
    public let note: Int
    public let velocity: Int
    public let duration: Double

    public init(channel: Int, note: Int, velocity: Int, duration: Double) {
        self.channel = channel
        self.note = note
        self.velocity = velocity
        self.duration = duration
    }
}
```

---

### 7.2 MIDISequence

A collection of `MIDINote` elements. Supports Swift result builder syntax.

```swift
public struct MIDISequence {
    public let notes: [MIDINote]

    public init(@NoteBuilder _ build: () -> [MIDINote]) {
        self.notes = build()
    }
}
```

#### NoteBuilder

```swift
@resultBuilder
public enum NoteBuilder {
    public static func buildBlock(_ notes: MIDINote...) -> [MIDINote] {
        notes
    }
}
```

---

### 7.3 MIDIRenderer

Writes `.mid`-like content to a file. This placeholder is intended to be replaced with a true MIDI encoder.

```swift
import Foundation

public struct MIDIRenderer {
    public static func renderToFile(_ sequence: MIDISequence, to path: String = "output.mid") {
        let content = sequence.notes.map {
            "NOTE(ch:\($0.channel), key:\($0.note), vel:\($0.velocity), dur:\($0.duration))"
        }.joined(separator: "\n")

        try? content.write(toFile: path, atomically: true, encoding: .utf8)
    }
}
```

---

### Example

```swift
let melody = MIDISequence {
    MIDINote(channel: 0, note: 60, velocity: 100, duration: 0.5)
    MIDINote(channel: 0, note: 64, velocity: 100, duration: 0.5)
    MIDINote(channel: 0, note: 67, velocity: 100, duration: 1.0)
}

MIDIRenderer.renderToFile(melody, to: "demo.mid")
```

---

### Integration Notes

- This system can later support MIDI 2.0 features (per-note expression, UMP packets)
- Compatible with future `MIDIPianoRoll` visual rendering
- Pairs well with `Animator` for synchronizing scenes and sounds

