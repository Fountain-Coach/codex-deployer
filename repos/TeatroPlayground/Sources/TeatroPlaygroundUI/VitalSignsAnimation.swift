import Teatro

/// Renders a simple metrics animation.
public struct VitalSignsAnimation: Renderable {
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
