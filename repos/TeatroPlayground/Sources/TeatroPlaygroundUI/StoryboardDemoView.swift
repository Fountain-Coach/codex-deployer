#if canImport(SwiftUI)
import SwiftUI
import Teatro

/// Demonstrates planning app states with the Storyboard DSL.
public struct StoryboardDemoView: View, Renderable {
    let storyboard: Storyboard
    public init() {
        storyboard = Storyboard {
            Scene("Start") {
                Text("Welcome")
            }
            Transition(style: .crossfade, frames: 5)
            Scene("End") {
                Text("Goodbye")
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
    let storyboard: Storyboard
    public init() {
        storyboard = Storyboard {
            Scene("Start") { Text("Welcome") }
            Transition(style: .crossfade, frames: 5)
            Scene("End") { Text("Goodbye") }
        }
    }
    public func render() -> String {
        CodexStoryboardPreviewer.prompt(storyboard)
    }
}
#endif
