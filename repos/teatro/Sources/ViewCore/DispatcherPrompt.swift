import Foundation

public struct DispatcherPrompt: Renderable {
    public init() {}

    public func render() -> String {
        Stage(title: "Dispatcher") {
            Panel(width: 640, height: 900, cornerRadius: 12) {
                VStack(alignment: .leading) {
                    Dot(color: "green", diameter: 10)
                    Rule()
                    Text("<content>")
                    Rule()
                    InputCursor()
                }
            }
        }.render()
    }
}
