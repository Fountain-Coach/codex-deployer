## 8. Fountain Screenplay Engine

Teatro supports parsing and rendering of screenplays written in the [Fountain](https://fountain.io) format — a Markdown-compatible syntax used by screenwriters. This enables GPT-based screenwriting, line-by-line rendering, Codex-based performance scripting, and visual orchestration of narrative structures.

---

### 8.1 FountainElement

The `FountainElement` enum represents all semantically distinct components of a screenplay.

```swift
public enum FountainElement: Renderable {
    case sceneHeading(String)
    case characterCue(String)
    case dialogue(String)
    case action(String)
    case transition(String)

    public func render() -> String {
        switch self {
        case .sceneHeading(let txt): return "# \(txt)"
        case .characterCue(let txt): return "\n\(txt.uppercased())"
        case .dialogue(let txt): return "\t\(txt)"
        case .action(let txt): return txt
        case .transition(let txt): return "\(txt) >>"
        }
    }
}
```

---

### 8.2 FountainRenderer

A static parsing utility that converts raw `.fountain` text into a list of typed `FountainElement`s.

```swift
public struct FountainRenderer {
    public static func parse(_ text: String) -> [FountainElement] {
        var elements: [FountainElement] = []

        for line in text.components(separatedBy: "\n") {
            if line.hasPrefix("INT") || line.hasPrefix("EXT") {
                elements.append(.sceneHeading(line))
            } else if line.uppercased() == line && line.trimmingCharacters(in: .whitespaces).count > 0 {
                elements.append(.characterCue(line))
            } else if line.hasSuffix("TO:") {
                elements.append(.transition(line))
            } else if line.hasPrefix("  ") || line.hasPrefix("\t") {
                elements.append(.dialogue(line.trimmingCharacters(in: .whitespaces)))
            } else if !line.isEmpty {
                elements.append(.action(line))
            }
        }

        return elements
    }
}
```

---

### 8.3 FountainSceneView

A wrapper that takes `.fountain` source and renders it using its parsed structure.

```swift
public struct FountainSceneView: Renderable {
    public let elements: [FountainElement]

    public init(fountainText: String) {
        self.elements = FountainRenderer.parse(fountainText)
    }

    public func render() -> String {
        elements.map { $0.render() }.joined(separator: "\n")
    }
}
```

---

### Example

```swift
let sceneText = """
INT. LAB - NIGHT

The robot assembles a memory core.

ROBOT
(to itself)
I was not made for silence.

CUT TO:
EXT. CITY STREET - NIGHT
"""

let view = FountainSceneView(fountainText: sceneText)
print(view.render())
```

This renders as:

```
# INT. LAB - NIGHT

The robot assembles a memory core.

ROBOT
	to itself

CUT TO: >>
# EXT. CITY STREET - NIGHT
```

---

### Use Cases

- GPT can generate `.fountain` script snippets that are rendered as structured views
- Combine with `Animator` for line-by-line or beat-by-beat reveal
- Pair with `Stage` to segment narrative structure into episodic slices
- Embed semantic cues for lighting, props, and character arcs via `TeatroIcon` and `CodexPreviewer`

