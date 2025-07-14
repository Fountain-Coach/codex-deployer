## 5. Animation System

The Teatro View Engine supports timeline-based rendering by generating sequential frames of `Renderable` views. These frames can be used to create `.gif` animations or time-stepped outputs for screenplays, music, or visual reasoning steps.

---

### 5.1 Animator

The `Animator` struct provides the ability to render multiple sequential views into numbered `.png` image frames.

```swift
import Foundation

public struct Animator {
    public static func renderFrames(_ frames: [Renderable], baseName: String = "frame") {
        for (i, frame) in frames.enumerated() {
            let path = "Animations/\(baseName)_\(i).png"
            ImageRenderer.renderToPNG(frame, to: path)
        }
    }
}
```

---

### Example

```swift
let frames: [Renderable] = (0..<5).map { i in
    VStack {
        Text("Frame \(i)", style: .bold)
        Text(String(repeating: ".", count: i))
    }
}

Animator.renderFrames(frames, baseName: "timeline")
```

This creates:

```
Animations/timeline_0.png
Animations/timeline_1.png
Animations/timeline_2.png
...
```

---

### Exporting as GIF (using ImageMagick)

Once frames are rendered, you can use `convert` to create an animated `.gif`:

```bash
convert -delay 50 -loop 0 Animations/timeline_*.png animated.gif
```

---

This animation system works especially well for:
- Frame-by-frame reflections or GPT planning steps
- MIDI timeline playback
- `.fountain` screenplay line reveals
- Drift and semantic arc transitions

