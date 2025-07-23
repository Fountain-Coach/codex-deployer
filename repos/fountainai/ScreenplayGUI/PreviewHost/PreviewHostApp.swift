import SwiftUI
import ScreenplayGUI

#if canImport(SwiftUI)
@main
struct PreviewHostApp: App {
    var body: some Scene {
        WindowGroup {
            ScriptEditorStageView()
        }
    }
}
#endif
