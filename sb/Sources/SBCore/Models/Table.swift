import Foundation

public struct Table: Codable, Sendable {
    public var caption: String?
    public var columns: [String]?
    public var rows: [[String]]

    public init(caption: String? = nil, columns: [String]? = nil, rows: [[String]] = []) {
        self.caption = caption
        self.columns = columns
        self.rows = rows
    }
}
// © 2025 Contexter alias Benedikt Eickhoff 🛡️ All rights reserved.
