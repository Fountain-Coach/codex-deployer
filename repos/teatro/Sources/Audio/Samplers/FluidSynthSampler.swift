import Foundation

/// Placeholder implementation using the FluidSynth CLI when available.
public actor FluidSynthSampler: SampleSource {
    private var soundFont: String?

    public init() {}

    public func loadInstrument(_ path: String) async throws {
        soundFont = path
    }

    public func trigger(_ note: MIDI2Note) async {
        guard let sf = soundFont else {
            print("FluidSynthSampler: no soundfont loaded")
            return
        }
        // Real implementation would use libfluidsynth APIs.
        print("[FluidSynth] \(sf) -> note \(note.note) velocity \(note.velocity)")
    }

    public func stopAll() async {
        print("[FluidSynth] stop all")
    }
}
