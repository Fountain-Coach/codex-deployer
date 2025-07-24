## 11.7 Storyboard DSL

The Storyboard DSL describes sequences of scenes and animated transitions in a declarative Swift syntax. It allows Codex to orchestrate multi-step interfaces or animations that play back frame by frame.

### Usage

```swift
import Teatro

let storyboard = Storyboard {
    Scene("Intro") {
        VStack(alignment: .center) {
            Text("Welcome", style: .bold)
        }
    }
    Transition(style: .crossfade, frames: 10)
    Scene("End") {
        Text("Goodbye")
    }
}

let prompt = CodexStoryboardPreviewer.prompt(storyboard)
print(prompt)
```

This produces a text prompt that lists each frame and can be fed back to Codex for rendering or reasoning.

````text
©\ 2025 Contexter alias Benedikt Eickhoff 🛡️ All rights reserved.
````
