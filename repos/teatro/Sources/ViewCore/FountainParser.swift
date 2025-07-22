import Foundation

public struct RuleSet: Sendable {
    public var sceneHeadingKeywords: [String]
    public var transitionKeywords: [String]
    public var enableNotes: Bool
    public var enableBoneyard: Bool
    public var enableSections: Bool
    public var enableSynopses: Bool

    public init(sceneHeadingKeywords: [String] = ["INT.", "EXT.", "INT/EXT.", "I/E."],
                transitionKeywords: [String] = ["TO:"],
                enableNotes: Bool = true,
                enableBoneyard: Bool = true,
                enableSections: Bool = true,
                enableSynopses: Bool = true) {
        self.sceneHeadingKeywords = sceneHeadingKeywords
        self.transitionKeywords = transitionKeywords
        self.enableNotes = enableNotes
        self.enableBoneyard = enableBoneyard
        self.enableSections = enableSections
        self.enableSynopses = enableSynopses
    }

    public static let `default` = RuleSet()
}

public enum FountainElementType: Equatable {
    case sceneHeading
    case action
    case character
    case parenthetical
    case dialogue
    case dualDialogue
    case lyrics
    case transition
    case centered
    case pageBreak
    case section(level: Int)
    case synopsis
    case note
    case boneyard
    case titlePageField(key: String)
}

public struct FountainNode: Equatable {
    public var type: FountainElementType
    public var rawText: String
    public var lineNumber: Int
    public var children: [FountainNode] = []

    public init(type: FountainElementType, rawText: String, lineNumber: Int) {
        self.type = type
        self.rawText = rawText
        self.lineNumber = lineNumber
    }
}

public final class FountainParser {
    enum State { case titlePage, body, note, boneyard }

    private let rules: RuleSet

    public init(rules: RuleSet = .default) {
        self.rules = rules
    }

    public func parse(_ text: String) -> [FountainNode] {
        var elements: [FountainNode] = []
        let lines = text.split(separator: "\n", omittingEmptySubsequences: false)
        var state: State = .titlePage
        var lineNumber = 1
        var currentNote: String = ""
        var currentBoneyard: String = ""
        var previousBlank = true
        for raw in lines {
            let line = String(raw)
            switch state {
            case .titlePage:
                if let field = parseTitlePage(line) {
                    elements.append(FountainNode(type: .titlePageField(key: field.key), rawText: field.raw, lineNumber: lineNumber))
                } else if line.trimmingCharacters(in: .whitespaces).isEmpty {
                    state = .body
                } else {
                    state = .body
                    // handle line again under body rules
                    if rules.enableNotes, line.trimmingCharacters(in: .whitespaces).hasPrefix("[[") {
                        let trimmed = line.trimmingCharacters(in: .whitespaces)
                        if trimmed.hasSuffix("]]") {
                            let content = trimmed.dropFirst(2).dropLast(2)
                            elements.append(FountainNode(type: .note, rawText: String(content), lineNumber: lineNumber))
                        } else {
                            state = .note
                            currentNote = String(trimmed.dropFirst(2))
                        }
                    } else if rules.enableBoneyard, line.trimmingCharacters(in: .whitespaces).hasPrefix("/*") {
                        let trimmed = line.trimmingCharacters(in: .whitespaces)
                        if trimmed.hasSuffix("*/") {
                            let content = trimmed.dropFirst(2).dropLast(2)
                            elements.append(FountainNode(type: .boneyard, rawText: String(content), lineNumber: lineNumber))
                        } else {
                            state = .boneyard
                            currentBoneyard = String(trimmed.dropFirst(2))
                        }
                    } else if let element = parseBody(line: line, previousBlank: previousBlank) {
                        elements.append(FountainNode(type: element, rawText: line, lineNumber: lineNumber))
                    }
                }
            case .body:
                if rules.enableNotes, line.trimmingCharacters(in: .whitespaces).hasPrefix("[[") {
                    let trimmed = line.trimmingCharacters(in: .whitespaces)
                    if trimmed.hasSuffix("]]") {
                        let content = trimmed.dropFirst(2).dropLast(2)
                        elements.append(FountainNode(type: .note, rawText: String(content), lineNumber: lineNumber))
                    } else {
                        state = .note
                        currentNote = String(trimmed.dropFirst(2))
                    }
                } else if rules.enableBoneyard, line.trimmingCharacters(in: .whitespaces).hasPrefix("/*") {
                    let trimmed = line.trimmingCharacters(in: .whitespaces)
                    if trimmed.hasSuffix("*/") {
                        let content = trimmed.dropFirst(2).dropLast(2)
                        elements.append(FountainNode(type: .boneyard, rawText: String(content), lineNumber: lineNumber))
                    } else {
                        state = .boneyard
                        currentBoneyard = String(trimmed.dropFirst(2))
                    }
                } else if let element = parseBody(line: line, previousBlank: previousBlank) {
                    elements.append(FountainNode(type: element, rawText: line, lineNumber: lineNumber))
                }
            case .note:
                if line.trimmingCharacters(in: .whitespaces).hasSuffix("]]") {
                    currentNote += "\n" + String(line.dropLast(2))
                    elements.append(FountainNode(type: .note, rawText: currentNote, lineNumber: lineNumber))
                    currentNote = ""
                    state = .body
                } else {
                    currentNote += "\n" + line
                }
            case .boneyard:
                if line.trimmingCharacters(in: .whitespaces).hasSuffix("*/") {
                    currentBoneyard += "\n" + String(line.dropLast(2))
                    elements.append(FountainNode(type: .boneyard, rawText: currentBoneyard, lineNumber: lineNumber))
                    currentBoneyard = ""
                    state = .body
                } else {
                    currentBoneyard += "\n" + line
                }
            }
            previousBlank = line.trimmingCharacters(in: .whitespaces).isEmpty
            lineNumber += 1
        }
        if state == .note {
            elements.append(FountainNode(type: .note, rawText: currentNote, lineNumber: lineNumber))
        } else if state == .boneyard {
            elements.append(FountainNode(type: .boneyard, rawText: currentBoneyard, lineNumber: lineNumber))
        }
        return elements
    }

    private func parseTitlePage(_ line: String) -> (key: String, raw: String)? {
        let trimmed = line.trimmingCharacters(in: .whitespaces)
        guard let colonIndex = trimmed.firstIndex(of: ":") else { return nil }
        let key = String(trimmed[..<colonIndex])
        let value = trimmed[colonIndex...]
        guard !key.isEmpty && key.uppercased() == key else { return nil }
        return (key: key, raw: String(value.dropFirst()).trimmingCharacters(in: .whitespaces))
    }

    private func parseBody(line: String, previousBlank: Bool) -> FountainElementType? {
        let trimmed = line.trimmingCharacters(in: .whitespaces)
        if trimmed.isEmpty { return nil }
        if isPageBreak(trimmed) { return .pageBreak }
        if rules.enableSections && trimmed.hasPrefix("#") { return .section(level: trimmed.prefix { $0 == "#" }.count) }
        if rules.enableSynopses && trimmed.hasPrefix("=") && !isPageBreak(trimmed) { return .synopsis }
        if isSceneHeading(trimmed) { return .sceneHeading }
        if isTransition(trimmed) { return .transition }
        if trimmed.hasPrefix("~") { return .lyrics }
        if isCentered(trimmed) { return .centered }
        if previousBlank && isAllCaps(trimmed) { return .character }
        if trimmed.hasPrefix("(") { return .parenthetical }
        if previousBlank == false && isAllCaps(trimmed) && trimmed.hasSuffix("^") { return .dualDialogue }
        if previousBlank == false { return .dialogue }
        return .action
    }

    private func isSceneHeading(_ line: String) -> Bool {
        for keyword in rules.sceneHeadingKeywords {
            if line.uppercased().hasPrefix(keyword.uppercased()) { return true }
        }
        return line.hasPrefix(".")
    }

    private func isTransition(_ line: String) -> Bool {
        for keyword in rules.transitionKeywords {
            if line.uppercased().hasSuffix(keyword.uppercased()) { return true }
        }
        return false
    }

    private func isPageBreak(_ line: String) -> Bool {
        line.trimmingCharacters(in: .whitespaces).allSatisfy { $0 == "=" } && line.count >= 3
    }

    private func isCentered(_ line: String) -> Bool {
        line.hasPrefix(">") && line.hasSuffix("<")
    }

    private func isAllCaps(_ line: String) -> Bool {
        let letters = line.trimmingCharacters(in: .whitespaces)
        guard !letters.isEmpty else { return false }
        return letters == letters.uppercased()
    }
}
