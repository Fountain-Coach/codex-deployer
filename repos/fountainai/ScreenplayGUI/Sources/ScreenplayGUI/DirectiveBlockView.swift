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

    @ViewBuilder
    public var body: some View {
        switch block {
        case .line(let text, _):
            Text(text)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.vertical, 2)
        case .injected(let inj):
            injectedView(for: inj)
        }
    }

    @ViewBuilder
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
