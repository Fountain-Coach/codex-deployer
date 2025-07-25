#if canImport(SwiftUI)
import SwiftUI
import Combine
import Teatro

/// Displays a sequence of Renderable frames and advances them using a MIDI
/// sequence for timing.
public struct TeatroPlayerView: View {
    public let frames: [Renderable]
    public let midiSequence: MIDISequence

    @State private var currentIndex: Int = 0
    @State private var timer: AnyCancellable?

    public init(frames: [Renderable], midiSequence: MIDISequence) {
        self.frames = frames
        self.midiSequence = midiSequence
    }

    public var body: some View {
        VStack {
            Text(frames[currentIndex].render())
                .font(.system(.body, design: .monospaced))
                .padding()
        }
        .onAppear(perform: startPlayback)
        .onDisappear(perform: stopPlayback)
    }

    private func startPlayback() {
        guard frames.count > 1 else { return }
        currentIndex = 0
        scheduleNextFrame(at: 0)
    }

    private func scheduleNextFrame(at index: Int) {
        guard index < midiSequence.notes.count else { return }
        let delay = midiSequence.notes[index].duration
        timer = Just(())
            .delay(for: .seconds(delay), scheduler: DispatchQueue.main)
            .sink { _ in
                if currentIndex + 1 < frames.count {
                    currentIndex += 1
                    scheduleNextFrame(at: currentIndex)
                } else {
                    stopPlayback()
                }
            }
    }

    private func stopPlayback() {
        timer?.cancel()
        timer = nil
    }
}
#else
import Teatro
import Combine

public struct TeatroPlayerView {
    public let frames: [Renderable]
    public let midiSequence: MIDISequence

    public init(frames: [Renderable], midiSequence: MIDISequence) {
        self.frames = frames
        self.midiSequence = midiSequence
    }
}
#endif
