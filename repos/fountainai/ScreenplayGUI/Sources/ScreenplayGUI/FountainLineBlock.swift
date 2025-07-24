import Foundation
import Teatro


public enum FountainLineBlock: Identifiable, Equatable {
    case line(text: String, type: FountainElementType, trigger: OrchestrationTrigger?)
    case injected(InjectedBlock)

    public var id: UUID { UUID() }

    public var text: String {
        switch self {
        case .line(let text, _, _):
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
        case .line(_, _, let trigger):
            return trigger
        case .injected:
            return nil
        }
    }

    public var elementType: FountainElementType? {
        switch self {
        case .line(_, let type, _):
            return type
        case .injected:
            return nil
        }
    }
}
