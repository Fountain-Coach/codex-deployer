import Teatro

/// Renders a simple metrics animation.
@MainActor
public struct VitalSignsAnimation: @preconcurrency Renderable {
    let storyboard: Storyboard

    public init() {
        storyboard = Storyboard {
            Scene("Metric 1") {
                Stage(title: "Vital Signs") {
                    VStack(alignment: .leading) {
                        Text("Attention Drift", style: .bold)
                    }
                }
            }
            Transition(style: .crossfade, frames: 5)
            Scene("Metric 2") {
                Stage(title: "Vital Signs") {
                    VStack(alignment: .leading) {
                        Text("Attention Drift", style: .bold)
                        Text("Cognitive Load", style: .bold)
                    }
                }
            }
            Transition(style: .crossfade, frames: 5)
            Scene("Metric 3") {
                Stage(title: "Vital Signs") {
                    VStack(alignment: .leading) {
                        Text("Attention Drift", style: .bold)
                        Text("Cognitive Load", style: .bold)
                        Text("Memory Use", style: .bold)
                    }
                }
            }
            Transition(style: .crossfade, frames: 5)
            Scene("Metric 4") {
                Stage(title: "Vital Signs") {
                    VStack(alignment: .leading) {
                        Text("Attention Drift", style: .bold)
                        Text("Cognitive Load", style: .bold)
                        Text("Memory Use", style: .bold)
                        Text("Latency", style: .bold)
                    }
                }
            }
        }
    }

    public func render() -> String {
        let frames = storyboard.frames()
        Animator.renderFrames(frames, baseName: "vital_signs")
        return CodexStoryboardPreviewer.prompt(storyboard)
    }
}


#if DEBUG
import SwiftUI
import Combine

struct VitalSignsAnimationLivePreview: View {
    let frames = VitalSignsAnimation().storyboard.frames()
    @State private var frameIndex = 0

    // Use Combine publisher instead of Timer directly
    let timer = Timer.publish(every: 0.5, on: .main, in: .common).autoconnect()

    var body: some View {
        ScrollView {
            Text(frames[frameIndex].render())
                .font(.system(.body, design: .monospaced))
                .padding()
        }
        .onReceive(timer) { _ in
            frameIndex = (frameIndex + 1) % frames.count
        }
    }
}

struct VitalSignsAnimationLivePreview_Previews: PreviewProvider {
    static var previews: some View {
        VitalSignsAnimationLivePreview()
    }
}
#endif
