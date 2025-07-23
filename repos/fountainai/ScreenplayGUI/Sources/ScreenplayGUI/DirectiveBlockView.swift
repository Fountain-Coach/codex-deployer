import SwiftUI

public struct DirectiveBlockView: View {
    let block: FountainDirective

    public init(block: FountainDirective) {
        self.block = block
    }

    public var body: some View {
        switch block {
        case .editor(let text):
            Text(text)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.vertical, 2)
        case .response(let text):
            HStack {
                Spacer()
                Text(text)
                    .font(.system(.body, design: .monospaced))
            }
            .padding(.vertical, 2)
        }
    }
}

