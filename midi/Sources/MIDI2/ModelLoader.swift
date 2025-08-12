import Foundation

public struct MessageModel: Codable {
    public let id: String?
    public let name: String?
    public let description: String?
}

public enum ModelLoaderError: Error {
    case fileNotFound(String)
    case decodeError(Error)
}

public struct ModelLoader {
    /// Load messages from the generated models directory (relative to repo root).
    /// Default path: `midi/models/messages.json`.
    public static func loadMessages(from path: String = "models/messages.json") throws -> [MessageModel] {
        let url = URL(fileURLWithPath: path)
        guard FileManager.default.fileExists(atPath: url.path) else {
            throw ModelLoaderError.fileNotFound(path)
        }
        let data = try Data(contentsOf: url)
        do {
            let decoder = JSONDecoder()
            return try decoder.decode([MessageModel].self, from: data)
        } catch {
            throw ModelLoaderError.decodeError(error)
        }
    }
}
