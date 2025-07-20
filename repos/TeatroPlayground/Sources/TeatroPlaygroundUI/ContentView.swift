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

#Preview {
    ContentView()
}
#endif
