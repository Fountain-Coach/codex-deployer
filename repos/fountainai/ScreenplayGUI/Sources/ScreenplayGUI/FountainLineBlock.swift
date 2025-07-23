import Foundation

public enum OrchestrationTrigger {
    case toolCall(endpoint: String)
    case sse(filename: String)
    case reflect
    case promote(role: String)
    case summary
}

public enum FountainLineBlock: Identifiable, Equatable {
    case line(text: String, trigger: OrchestrationTrigger?)
    case injected(InjectedBlock)

    public enum InjectedBlock: Equatable {
        case toolResponse(String)
        case reflectionReply(String)
        case sseChunk(String)
        case promotionConfirmation(String)
        case summaryBlock(String)
    }

    public var id: UUID { UUID() }

    public var text: String {
        switch self {
        case .line(let text, _):
            return text
        case .injected(let inj):
            switch inj {
            case .toolResponse(let txt), .reflectionReply(let txt), .sseChunk(let txt), .promotionConfirmation(let txt), .summaryBlock(let txt):
                return txt
            }
        }
    }

    public var trigger: OrchestrationTrigger? {
        switch self {
        case .line(_, let trigger):
            return trigger
        case .injected:
            return nil
        }
    }
}
