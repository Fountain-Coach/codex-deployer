public struct SVGRenderer {
    public static func render(_ view: Renderable) -> String {
        let lines = view.render().components(separatedBy: "\n")
        let rendered = lines.enumerated().map { idx, line in
            "<text x=\"10\" y=\"\(20 + idx * 20)\" font-family=\"monospace\" font-size=\"14\">\(line)</text>"
        }.joined(separator: "\n")

        return """
        <svg xmlns=\"http://www.w3.org/2000/svg\" width=\"600\" height=\"\(20 + lines.count * 20)\">
        \(rendered)
        </svg>
        """
    }
}
