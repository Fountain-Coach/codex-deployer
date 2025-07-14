public enum FountainElement: Renderable {
    case sceneHeading(String)
    case characterCue(String)
    case dialogue(String)
    case action(String)
    case transition(String)

    public func render() -> String {
        switch self {
        case .sceneHeading(let txt): return "# \(txt)"
        case .characterCue(let txt): return "\n\(txt.uppercased())"
        case .dialogue(let txt): return "\t\(txt)"
        case .action(let txt): return txt
        case .transition(let txt): return "\(txt) >>"
        }
    }
}

public struct FountainRenderer {
    public static func parse(_ text: String) -> [FountainElement] {
        var elements: [FountainElement] = []

        for line in text.components(separatedBy: "\n") {
            if line.hasPrefix("INT") || line.hasPrefix("EXT") {
                elements.append(.sceneHeading(line))
            } else if line.uppercased() == line && line.trimmingCharacters(in: .whitespaces).count > 0 {
                elements.append(.characterCue(line))
            } else if line.hasSuffix("TO:") {
                elements.append(.transition(line))
            } else if line.hasPrefix("  ") || line.hasPrefix("\t") {
                elements.append(.dialogue(line.trimmingCharacters(in: .whitespaces)))
            } else if !line.isEmpty {
                elements.append(.action(line))
            }
        }

        return elements
    }
}

public struct FountainSceneView: Renderable {
    public let elements: [FountainElement]

    public init(fountainText: String) {
        self.elements = FountainRenderer.parse(fountainText)
    }

    public func render() -> String {
        elements.map { $0.render() }.joined(separator: "\n")
    }
}
