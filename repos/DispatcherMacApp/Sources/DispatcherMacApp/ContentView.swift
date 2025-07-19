import SwiftUI
import Teatro

struct ContentView: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Dispatcher GUI")
                .font(.title)
            Button("Start Dispatcher") {
                print("Start dispatcher tapped")
            }
            TeatroRenderView(content: DispatcherPrompt())
                .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
        .padding()
    }
}

#Preview
struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
