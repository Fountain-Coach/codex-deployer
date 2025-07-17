import Foundation

struct SocketFixAgent {
    private let constants = ["AF_INET", "SOCK_STREAM", "SOCK_DGRAM", "IPPROTO_TCP"]
    private let fileManager = FileManager.default

    func run() throws {
        let generatedPath = "Generated/Server"
        guard let enumerator = fileManager.enumerator(atPath: generatedPath) else {
            return
        }
        var patched: [String] = []
        for case let file as String in enumerator {
            if file.hasSuffix("main.swift") {
                let path = generatedPath + "/" + file
                var contents = try String(contentsOfFile: path)
                let original = contents
                for constant in constants {
                    let pattern = "\\b" + constant + "\\.rawValue\\b"
                    let regex = try NSRegularExpression(pattern: pattern)
                    let range = NSRange(contents.startIndex..<contents.endIndex, in: contents)
                    contents = regex.stringByReplacingMatches(in: contents, options: [], range: range, withTemplate: constant)
                }
                if contents != original {
                    try contents.write(toFile: path, atomically: true, encoding: .utf8)
                    patched.append(path)
                }
            }
        }
        if patched.isEmpty {
            print("No socket constants needed fixing")
        } else {
            print("Patched \(patched.count) files:")
            for f in patched { print("- \(f)") }
        }
    }
}

@main
struct Main {
    static func main() throws {
        try SocketFixAgent().run()
    }
}
