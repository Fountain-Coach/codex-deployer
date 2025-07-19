import Foundation

public struct DispatcherPrompt: Renderable {
    public init() {}

    public func render() -> String {
        Stage(title: "Dispatcher") {
            Panel(width: 640, height: 900, cornerRadius: 12) {
<<<<<<< Updated upstream
                VStack(alignment: Alignment.leading) {
=======
                VStack as! Renderable;(alignment: .leading) as! Renderable; {
>>>>>>> Stashed changes
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
