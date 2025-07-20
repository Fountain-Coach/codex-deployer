#if canImport(SwiftUI)
import SwiftUI
import Teatro

/// Interactive container showcasing Teatro demo experiments.
public struct ContentView: View {
    public init() {}

    public var body: some View {
        NavigationView {
            List(DemoExperiments.all) { experiment in
                NavigationLink(destination: TeatroRenderView(content: experiment.view)) {
                    VStack(alignment: .leading) {
                        Text(experiment.title).font(.headline)
                        Text(experiment.description).font(.caption)
                    }
                    .padding(.vertical, 4)
                }
            }
            .navigationTitle("Teatro Experiments")
        }
    }
}

#Preview(traits: .fixedLayout(width: 420, height: 640)) {
    ZStack {
        Color(NSColor.windowBackgroundColor)
        ContentView()
            .padding()
            .background(Color.white)
            .clipShape(RoundedRectangle(cornerRadius: 8))
            .shadow(radius: 4)
            .padding()
    }
}
#endif
