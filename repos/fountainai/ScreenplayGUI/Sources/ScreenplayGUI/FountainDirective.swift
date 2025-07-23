import Foundation

public enum FountainDirective: Identifiable, Equatable {
    case editor(String)
    case response(String)

    public var id: UUID {
        UUID()
    }

    public var text: String {
        switch self {
        case .editor(let text):
            return text
        case .response(let text):
            return text
        }
    }
}

