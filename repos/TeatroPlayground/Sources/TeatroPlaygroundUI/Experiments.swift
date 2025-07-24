import Teatro
import Foundation

/// A single showcase of a Teatro feature.
public struct Experiment: Identifiable {
    public let id = UUID()
    public let title: String
    public let description: String
    public let view: Renderable

    public init(title: String, description: String, content: () -> Renderable) {
        self.title = title
        self.description = description
        self.view = content()
    }
}

/// Pre-built experiments demonstrating Teatro's capabilities.
public enum DemoExperiments {
    @MainActor public static let all: [Experiment] = [
        Experiment(
            title: "Hello Teatro",
            description: "A warm welcome rendered in bold text.") {
                Text("Hello, Teatro!", style: .bold)
        },
        Experiment(
            title: "Stack of Quotes",
            description: "A vertical layout showing basic alignment.") {
                VStack(alignment: .leading, padding: 2) {
                    Text("The stage is yours.")
                    Text("Craft each line with care.", style: .italic)
                    Text("Applause awaits.")
                }
        },
        Experiment(
            title: "Scene Sample",
            description: "A short Fountain screenplay snippet rendered as a stage.") {
                Stage(title: "Opening") {
                    FountainSceneView(fountainText: """
INT. LAB - NIGHT
SCIENTIST
    It's alive!
""")
                }
        },
        Experiment(
            title: "Renderer Showcase",
            description: "Outputs the demo view via Codex, HTML, SVG and PNG.") {
                RendererShowcaseView()
        },
        Experiment(
            title: "Storyboard Demo",
            description: "Plan app states with the Storyboard DSL and Codex prompting.") {
                StoryboardDemoView()
        }
    ]
}
