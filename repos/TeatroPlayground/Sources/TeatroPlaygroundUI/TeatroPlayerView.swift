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
    @State private var timerCancellable: Cancellable?
    @State private var isPlaying: Bool = false

    public init(frames: [Renderable], midiSequence: MIDISequence) {
        self.frames = frames
        self.midiSequence = midiSequence
    }

    public var body: some View {
        VStack(spacing: 20) {
            Text(frames[currentIndex].render())
                .font(.system(.body, design: .monospaced))
                .padding()

            HStack {
                Button("Play") {
                    if !isPlaying { playFrom(currentIndex) }
                }
                .disabled(isPlaying || currentIndex >= frames.count - 1)

                Button("Pause") {
                    pausePlayback()
                }
                .disabled(!isPlaying)

                Button("Reset") {
                    stopPlayback()
                    currentIndex = 0
                }
            }
            .padding(.top)
        }
        .onDisappear {
            stopPlayback()
        }
    }

    private func playFrom(_ index: Int) {
        guard index < midiSequence.notes.count else { return }
        isPlaying = true
        scheduleNextFrame(at: index)
    }

    private func scheduleNextFrame(at index: Int) {
        guard index + 1 < frames.count else {
            isPlaying = false
            return
        }

        let duration = midiSequence.notes[index].duration
        timerCancellable = Just(())
            .delay(for: .seconds(duration), scheduler: DispatchQueue.main)
            .sink { _ in
                currentIndex += 1
                scheduleNextFrame(at: currentIndex)
            }
    }

    private func pausePlayback() {
        timerCancellable?.cancel()
        isPlaying = false
    }

    private func stopPlayback() {
        timerCancellable?.cancel()
        isPlaying = false
    }
}
#else
import Teatro

public struct TeatroPlayerView {
    public let frames: [Renderable]
    public let midiSequence: MIDISequence

    public init(frames: [Renderable], midiSequence: MIDISequence) {
        self.frames = frames
        self.midiSequence = midiSequence
    }
}
#endif
