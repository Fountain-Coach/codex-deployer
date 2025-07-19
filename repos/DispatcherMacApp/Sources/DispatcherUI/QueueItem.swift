#if canImport(SwiftUI)
import Foundation

/// Model for a pending feedback item displayed in ``QueueView``.
public struct QueueItem: Identifiable {
    public let id = UUID()
    public var file: String
    public var status: String

    public init(file: String, status: String = "pending") {
        self.file = file
        self.status = status
    }
}
#endif
