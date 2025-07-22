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

### 8.2 FountainParser

`FountainParser` implements the full state machine described in the
[implementation plan](FountainParserImplementationPlan.md). It recognises notes,
boneyard, page breaks and all other token types without relying on regular
expressions. Behaviour can be customised by passing a `RuleSet` on
initialisation.

```swift
let parser = FountainParser(rules: .init(sceneHeadingKeywords: ["INT.", "EXT."]))
let nodes = parser.parse(scriptText)
```

### 8.3 FountainRenderer

`FountainRenderer` is a small wrapper that converts the parsed nodes into the
`FountainElement` enum used by existing views.

```swift
public struct FountainRenderer {
    public static func parse(_ text: String) -> [FountainElement] {
        let nodes = FountainParser().parse(text)
        return nodes.compactMap { node in
            switch node.type {
            case .sceneHeading: return .sceneHeading(node.rawText)
            case .character: return .characterCue(node.rawText)
            case .dialogue, .dualDialogue: return .dialogue(node.rawText)
            case .transition: return .transition(node.rawText)
            default: return .action(node.rawText)
            }
        }
    }
}
```

---

### 8.4 FountainSceneView

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


```
© 2025 Contexter alias Benedikt Eickhoff, https://fountain.coach. All rights reserved.
Unauthorized copying or distribution is strictly prohibited.
```
````text
©\ 2025 Contexter alias Benedikt Eickhoff 🛡️ All rights reserved.
````

