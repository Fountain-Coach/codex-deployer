import Foundation
import Teatro
import TeatroPlaygroundUI

@main
enum StoryboardMIDIDemo {
    static func main() throws {
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

        // Frame comments for MIDI timing
        var frameComments: [String] = []
        var last = ""
        for step in storyboard.steps {
            switch step {
            case .scene(let scene):
                last = scene.metadata["comment"] ?? last
                frameComments.append(last)
            case .transition(let transition):
                frameComments.append(contentsOf: Array(repeating: last, count: transition.frames))
            }
        }

        // MARK: - Render Animated SVG
        let svgOutput = SVGAnimator.renderAnimatedSVG(storyboard: storyboard)
        try svgOutput.write(to: URL(fileURLWithPath: "storyboard.svg"), atomically: true, encoding: .utf8)

        // MARK: - MIDI 2.0 Sequence
        let midiSequence = MIDISequence {
            for _ in frameComments {
                MIDI2Note(channel: 0, note: 60, velocity: 0.8, duration: 0.25)
            }
        }

        // Encode to UMP for demonstration
        let _ = midiSequence.notes.flatMap { UMPEncoder.encode($0) }

        // MARK: - Player View
        let playerView = TeatroPlayerView(storyboard: storyboard, midi: midiSequence)
        print(playerView)
    }
}


