import SwiftUI
import Teatro

public struct DirectiveBlockView: View {
    let block: FountainLineBlock

    public init(block: FountainLineBlock) {
        self.block = block
    }

    public init(_ block: FountainLineBlock) {
        self.block = block
    }

    @SwiftUI.ViewBuilder
    public var body: some View {
        switch block {
        case .line(let text, let type, _):
            lineView(text: text, type: type)
        case .injected(let inj):
            injectedView(for: inj)
        }
    }

    @SwiftUI.ViewBuilder
    private func lineView(text: String, type: FountainElementType) -> some View {
        switch type {
        case .sceneHeading:
            Text(text.uppercased())
                .bold()
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.vertical, 2)
        case .character:
            Text(text)
                .bold()
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.vertical, 2)
        case .action:
            Text(text)
                .italic()
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.vertical, 2)
        default:
            Text(text)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.vertical, 2)
        }
    }

    @SwiftUI.ViewBuilder
    private func injectedView(for inj: InjectedBlock) -> some View {
        switch inj {
        case .toolResponse(let text):
            Text(text)
                .font(.system(.body, design: .monospaced))
                .foregroundColor(.blue)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.vertical, 2)
        case .reflectionReply(let text):
            Text(text)
                .italic()
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.vertical, 2)
        case .sseChunk(let text):
            Text(text)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.vertical, 2)
        case .promotionConfirmation(let text):
            Text(text)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.vertical, 2)
        case .summaryBlock(let text):
            Text(text)
                .italic()
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.vertical, 2)
        }
    }
}
