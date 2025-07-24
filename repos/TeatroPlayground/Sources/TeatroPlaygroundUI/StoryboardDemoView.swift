import Teatro
#if canImport(SwiftUI)
import SwiftUI
#endif

/// Builds a tutorial storyboard and renders it as a text prompt.
public struct StoryboardPreviewRenderer: Renderable {
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

    public func render() -> String {
        CodexStoryboardPreviewer.prompt(storyboard)
    }
}

#if canImport(SwiftUI)
/// SwiftUI wrapper that displays the storyboard preview.
public struct StoryboardDemoView: View {
    let renderer = StoryboardPreviewRenderer()
    public var body: some View {
        ScrollView {
            Text(renderer.render())
                .font(.system(.body, design: .monospaced))
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding()
        }
    }
}
#else
/// Console-only variant for non-SwiftUI environments.
public typealias StoryboardDemoView = StoryboardPreviewRenderer
#endif
