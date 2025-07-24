# fix-main-actor-isolation.agent.md

## 🧠 Purpose
Automatically remove `nonisolated` from SwiftUI `View` methods when they access stored properties. Such properties are implicitly `@MainActor`, so `nonisolated` is incorrect.

## 🎯 Goals
- Detect structs conforming to `View` (implicitly `@MainActor`).
- Locate `nonisolated func` declarations inside those structs.
- If the function body references any stored property, rewrite the declaration without `nonisolated`.
- Preserve original formatting.

## 🔒 Constraints
- Do not touch functions where no stored properties are referenced.
- Leave all other code unchanged.

## 🧾 Prompt Instruction for Codex
````swift
// Codex instruction: FixMainActorIsolation.swift
// When scanning Swift source files, remove `nonisolated` from methods inside
// `View` structs if the method accesses a stored property.
// Example before:
// struct StoryboardDemoView: View {
//     let storyboard: Storyboard
//     public nonisolated func render() -> String {
//         CodexStoryboardPreviewer.prompt(storyboard)
//     }
// }
// Example after:
// struct StoryboardDemoView: View {
//     let storyboard: Storyboard
//     // 🛠 Fixed: removed nonisolated to match actor context
//     public func render() -> String {
//         CodexStoryboardPreviewer.prompt(storyboard)
//     }
// }
````

`````text
© 2025 Contexter alias Benedikt Eickhoff 🛡️ All rights reserved.
`````
