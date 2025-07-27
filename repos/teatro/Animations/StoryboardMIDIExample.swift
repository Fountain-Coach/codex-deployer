import Foundation
import Teatro
import TeatroPlaygroundUI

// MARK: - Storyboard Definition
let storyboard = Storyboard {
    Scene("intro", metadata: ["comment": "Intro scene"]) {
        VStack(alignment: .center) {
            TeatroIcon("🎭")
            Text("Teatro Impossibile", style: .bold)
        }
    }
    Transition(style: .crossfade, frames: 10)
    Scene("outro", metadata: ["comment": "Closing scene"]) {
        VStack(alignment: .center) {
            TeatroIcon("🏁")
            Text("End of Act", style: .bold)
        }
    }
}

// MARK: - Render Animated SVG
let svgOutput = SVGAnimator.renderAnimatedSVG(storyboard: storyboard)
try? svgOutput.write(to: URL(fileURLWithPath: "storyboard.svg"), atomically: true, encoding: .utf8)

// MARK: - MIDI 2.0 Sequence
let midiSequence = MIDISequence {
    for _ in storyboard.frames() {
        MIDI2Note(channel: 0, note: 60, velocity: 0.8, duration: 0.25)
    }
}

// Encode to UMP for demonstration (not saved to file here)
let packets = midiSequence.notes.flatMap { UMPEncoder.encode($0) }
print(packets)

// MARK: - Player View
let playerView = TeatroPlayerView(storyboard: storyboard, midi: midiSequence)
print(playerView)
