#if canImport(SwiftUI)
import SwiftUI
import Teatro

/// Placeholder prompt view used for renderer testing.
public struct ProcessPrompt: View, Renderable {
    public init() {}

    public var body: some View {
        EmptyView() // TODO
    }

    nonisolated public func render() -> String {
        "" // TODO: update with prompt content
    }
}
#else
import Teatro

public struct ProcessPrompt: Renderable {
    public init() {}
    public func render() -> String { "" }
}
#endif
