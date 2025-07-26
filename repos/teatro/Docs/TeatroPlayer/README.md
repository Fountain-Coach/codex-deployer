## TeatroPlayerView Usage

This document explains how to pair rendered frames with MIDI timing and play
them back in real time.

### Building frame and MIDI pairs

1. Generate a `Storyboard` using the DSL.
2. Create a matching `MIDISequence` where each `MIDI2Note.duration` equals the
   desired frame duration.

### Playing the storyboard

```swift
let frames = storyboard.frames()
let player = TeatroPlayerView(storyboard: storyboard, midi: melody)
```

### Overlays and reflections

Pass `comments: [String]` when constructing frames to display semantic notes
overlayed during playback.

### Enabling audio

`TeatroPlayerView` uses `AVAudioUnitSampler` to produce live MIDI 2.0 output. Ensure
an appropriate sound font is loaded when initializing the sampler.

````text
©\ 2025 Contexter alias Benedikt Eickhoff 🛡️ All rights reserved.
````
