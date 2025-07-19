#if canImport(SwiftUI)
import Foundation

/// Model for a pending feedback item displayed in ``QueueView``.
public struct QueueItem: Identifiable {
    public let id: UUID
    public var file: String
    public var status: String

    public init(id: UUID = UUID(), file: String, status: String = "pending") {
        self.id = id
        self.file = file
        self.status = status
    }
}
#endif
