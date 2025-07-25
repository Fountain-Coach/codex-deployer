#if canImport(AVFoundation)
import Foundation
import AVFoundation
import Teatro

public struct MIDIAudioEngine {
    private static var engine: AVAudioEngine?
    private static var sampler: AVAudioUnitSampler?

    public static func start() {
        guard engine == nil else { return }
        let newEngine = AVAudioEngine()
        let newSampler = AVAudioUnitSampler()

        newEngine.attach(newSampler)
        newEngine.connect(newSampler, to: newEngine.mainMixerNode, format: nil)

        do {
            try newEngine.start()
            try newSampler.loadInstrument(at: MIDIAudioEngine.defaultSoundFontURL())
            engine = newEngine
            sampler = newSampler
        } catch {
            print("MIDI engine start failed: \(error)")
        }
    }

    public static func play(note: MIDINote) {
        guard let sampler else { return }

        let midiNote = UInt8(note.note)
        let velocity = UInt8(note.velocity)
        let channel = UInt8(note.channel)

        sampler.startNote(midiNote, withVelocity: velocity, onChannel: channel)

        DispatchQueue.main.asyncAfter(deadline: .now() + note.duration) {
            sampler.stopNote(midiNote, onChannel: channel)
        }
    }

    private static func defaultSoundFontURL() throws -> URL {
        // Replace with bundled soundfont if needed
        return URL(fileURLWithPath: "/System/Library/Audio/Sounds/Bank.sf2")
    }
}
#endif
