#if canImport(SwiftUI)
import SwiftUI
import Teatro

/// Demonstrates planning app states with the Storyboard DSL.
public struct StoryboardDemoView: View, Renderable {

    /// Preconfigured storyboard used to teach the DSL.
    /// Each step is deliberately simple so Codex can
    /// explain the purpose of every scene and transition.

    let storyboard: Storyboard
    public init() {
        storyboard = Storyboard {
            Scene("Welcome") {
                VStack(alignment: .center) {
                    Text("Teatro Storyboards", style: .bold)
                    Text("Plan your UI states step by step")
                }
            }

            // Fade to the login form over five frames
            Transition(style: .crossfade, frames: 5)

            Scene("Login") {
                VStack(alignment: .leading, padding: 1) {
                    Text("Name:")
                    Text("[input field]")
                    Text("Password:")
                    Text("[secure field]")
                }
            }

            // Show a short loading state before entering the dashboard
            Transition(style: .crossfade, frames: 3)

            Scene("Processing") {
                Text("Logging in…")
            }

            // Tween the login screen into the dashboard
            Transition(style: .tween, frames: 8, easing: .easeInOut)

            Scene("Dashboard") {
                Text("Logged in successfully", style: .italic)
            }
        }
    }

    public nonisolated func render() -> String {
        CodexStoryboardPreviewer.prompt(storyboard)
    }

    public var body: some View {
        ScrollView {
            Text(render())
                .font(.system(.body, design: .monospaced))
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding()
        }
    }
}
#else
import Teatro

public struct StoryboardDemoView: Renderable {

    /// Console-only variant of the tutorial storyboard.

    let storyboard: Storyboard
    public init() {
        storyboard = Storyboard {
            Scene("Welcome") {
                VStack(alignment: .center) {
                    Text("Teatro Storyboards", style: .bold)
                    Text("Plan your UI states step by step")
                }
            }
            Transition(style: .crossfade, frames: 5)
            Scene("Login") {
                VStack(alignment: .leading, padding: 1) {
                    Text("Name:")
                    Text("[input field]")
                    Text("Password:")
                    Text("[secure field]")
                }
            }

            Transition(style: .crossfade, frames: 3)
            Scene("Processing") {
                Text("Logging in…")
            }


            Transition(style: .tween, frames: 8, easing: .easeInOut)
            Scene("Dashboard") {
                Text("Logged in successfully", style: .italic)
            }
        }
    }
    public func render() -> String {
        CodexStoryboardPreviewer.prompt(storyboard)
    }
}
#endif
