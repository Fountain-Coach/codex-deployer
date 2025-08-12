import Foundation

public struct MIDIModelIndex: Codable {
    public struct Document: Codable {
        public let fileName: String
        public let id: String
        public let pages: [Page]
        public let sha256: String
        public let size: Int
        public init(fileName: String, id: String, pages: [Page], sha256: String, size: Int) {
            self.fileName = fileName
            self.id = id
            self.pages = pages
            self.sha256 = sha256
            self.size = size
        }
    }

    public struct Page: Codable {
        public let lines: [String]
        public let number: Int
        public let text: String
        public init(lines: [String], number: Int, text: String) {
            self.lines = lines
            self.number = number
            self.text = text
        }
    }

    public let documents: [Document]
    public init(documents: [Document]) {
        self.documents = documents
    }

    public static func load(from path: String = "midi/models/index.json") throws -> MIDIModelIndex {
        let url = URL(fileURLWithPath: FileManager.default.currentDirectoryPath).appendingPathComponent(path)
        let data = try Data(contentsOf: url)
        return try JSONDecoder().decode(MIDIModelIndex.self, from: data)
    }
}

// © 2025 Contexter alias Benedikt Eickhoff 🛡️ All rights reserved.
