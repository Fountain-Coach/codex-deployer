import Foundation

/// Placeholder implementation invoking the csound CLI when available.
public actor CsoundSampler: SampleSource {
    private var orchestra: String?

    public init() {}

    public func loadInstrument(_ path: String) async throws {
        // In a real implementation this would parse the .orc file.
        orchestra = try String(contentsOfFile: path)
    }

    public func trigger(_ note: MIDI2Note) async {
        guard orchestra != nil else {
            print("CsoundSampler: no orchestra loaded")
            return
        }
        // A production version would send a score event via the Csound API.
        print("[Csound] note \(note.note) velocity \(note.velocity)")
    }

    public func stopAll() async {
        print("[Csound] stop all")
    }
}
