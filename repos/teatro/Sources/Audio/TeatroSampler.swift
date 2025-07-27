import Foundation

/// High level sampler orchestrating MIDI 2.0 note events.
/// Voices are actor based and render audio via pluggable SampleSource
/// implementations. This avoids platform specific audio frameworks and
/// keeps the sampler cross‐platform.

public struct MIDI2NoteEvent: Sendable, Equatable {
    public var channel: Int
    public var note: Int
    public var velocity: Float
    public var pitch: Float
    public var timbre: SIMD4<Float>
    public var articulation: String
    public var timestamp: UInt64

    public init(channel: Int, note: Int, velocity: Float, pitch: Float,
                timbre: SIMD4<Float>, articulation: String, timestamp: UInt64) {
        self.channel = channel
        self.note = note
        self.velocity = velocity
        self.pitch = pitch
        self.timbre = timbre
        self.articulation = articulation
        self.timestamp = timestamp
    }
}

public protocol SampleSource: Sendable {
    mutating func render(buffer: inout [Float], frameCount: Int)
    mutating func update(with event: MIDI2NoteEvent)
}

public actor Voice {
    public let id: UUID
    var event: MIDI2NoteEvent
    var sampler: SampleSource

    init(id: UUID = UUID(), event: MIDI2NoteEvent, sampler: SampleSource) {
        self.id = id
        self.event = event
        self.sampler = sampler
    }

    func update(_ newEvent: MIDI2NoteEvent) {
        event = newEvent
        sampler.update(with: newEvent)
    }

    func render(into buffer: inout [Float], frameCount: Int) {
        sampler.render(buffer: &buffer, frameCount: frameCount)
    }
}

public actor TeatroSampler {
    private var voices: [UUID: Voice] = [:]

    public init() {}

    @discardableResult
    public func play(_ event: MIDI2NoteEvent, source: SampleSource) async -> UUID {
        let voice = Voice(event: event, sampler: source)
        voices[voice.id] = voice
        return voice.id
    }

    public func updateVoice(id: UUID, with event: MIDI2NoteEvent) async {
        await voices[id]?.update(event)
    }

    public func stopVoice(id: UUID) async {
        voices.removeValue(forKey: id)
    }

    public func activeVoices() async -> [UUID] {
        Array(voices.keys)
    }

    public func voiceCount() async -> Int {
        voices.count
    }
}
