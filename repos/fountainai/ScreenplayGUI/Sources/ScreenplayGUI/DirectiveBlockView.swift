import Teatro

#if canImport(SwiftUI)
import SwiftUI

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
            SceneHeadingView(text: text)
        case .character:
            CharacterCueView(text: text)
        case .dialogue, .dualDialogue:
            DialogueView(text: text)
        case .parenthetical:
            ParentheticalView(text: text)
        case .transition:
            TransitionView(text: text)
        case .action:
            ActionView(text: text)
        case .lyrics:
            LyricsView(text: text)
        case .centered:
            CenteredView(text: text)
        case .pageBreak:
            PageBreakView()
        case .section(let level):
            SectionView(text: text, level: level)
        case .synopsis:
            SynopsisView(text: text)
        case .note:
            NoteView(text: text)
        case .boneyard:
            BoneyardView(text: text)
        case .titlePageField:
            TitlePageFieldView(text: text)
        case .corpusHeader:
            CorpusHeaderView(text: text)
        case .baseline:
            BaselineView(text: text)
        case .sse:
            SSEView(text: text)
        case .toolCall:
            ToolCallView(text: text)
        case .reflect:
            ReflectView(text: text)
        case .promote:
            PromoteView(text: text)
        case .summary:
            SummaryView(text: text)
        case .text, .emphasis:
            PlainLineView(text: text)
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

    // MARK: - Line subviews
    private struct PlainLineView: View {
        var text: String
        var body: some View {
            Text(text)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.vertical, 2)
        }
    }

    private struct SceneHeadingView: View {
        var text: String
        var body: some View {
            Text(text.uppercased())
                .bold()
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.vertical, 2)
        }
    }

    private struct CharacterCueView: View {
        var text: String
        var body: some View {
            Text(text.uppercased())
                .bold()
                .frame(maxWidth: .infinity, alignment: .center)
                .padding(.vertical, 2)
        }
    }

    private struct DialogueView: View {
        var text: String
        var body: some View {
            Text(text)
                .frame(maxWidth: 500, alignment: .center)
                .padding(.vertical, 2)
        }
    }

    private struct ParentheticalView: View {
        var text: String
        var body: some View {
            Text(text)
                .italic()
                .frame(maxWidth: 450, alignment: .center)
                .padding(.vertical, 2)
        }
    }

    private struct TransitionView: View {
        var text: String
        var body: some View {
            Text(text.uppercased())
                .frame(maxWidth: .infinity, alignment: .trailing)
                .padding(.vertical, 2)
        }
    }

    private struct ActionView: View {
        var text: String
        var body: some View {
            Text(text)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.vertical, 2)
        }
    }

    private struct LyricsView: View {
        var text: String
        var body: some View {
            Text(text)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.vertical, 2)
        }
    }

    private struct CenteredView: View {
        var text: String
        var body: some View {
            Text(text)
                .multilineTextAlignment(.center)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 2)
        }
    }

    private struct PageBreakView: View {
        var body: some View {
            Divider().padding(.vertical, 8)
        }
    }

    private struct SectionView: View {
        var text: String
        var level: Int
        var body: some View {
            Text(text)
                .bold()
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.vertical, 2)
                .padding(.leading, CGFloat(level * 8))
        }
    }

    private struct SynopsisView: View {
        var text: String
        var body: some View {
            Text(text)
                .foregroundColor(.gray)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.vertical, 2)
        }
    }

    private struct NoteView: View {
        var text: String
        var body: some View {
            Text(text)
                .foregroundColor(.orange)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.vertical, 2)
        }
    }

    private struct BoneyardView: View {
        var text: String
        var body: some View {
            Text(text)
                .strikethrough()
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.vertical, 2)
        }
    }

    private struct TitlePageFieldView: View {
        var text: String
        var body: some View {
            Text(text)
                .bold()
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.vertical, 2)
        }
    }

    private struct CorpusHeaderView: View {
        var text: String
        var body: some View {
            Text(text)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.vertical, 2)
        }
    }

    private struct BaselineView: View {
        var text: String
        var body: some View {
            Text(text)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.vertical, 2)
        }
    }

    private struct SSEView: View {
        var text: String
        var body: some View {
            Text(text)
                .foregroundColor(.purple)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.vertical, 2)
        }
    }

    private struct ToolCallView: View {
        var text: String
        var body: some View {
            Text(text)
                .foregroundColor(.blue)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.vertical, 2)
        }
    }

    private struct ReflectView: View {
        var text: String
        var body: some View {
            Text(text)
                .italic()
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.vertical, 2)
        }
    }

    private struct PromoteView: View {
        var text: String
        var body: some View {
            Text(text)
                .foregroundColor(.green)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.vertical, 2)
        }
    }

    private struct SummaryView: View {
        var text: String
        var body: some View {
            Text(text)
                .italic()
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.vertical, 2)
        }
    }
}
#endif
