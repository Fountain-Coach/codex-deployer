import Foundation
import Teatro

let group = DispatchGroup()

group.enter()
Task {
    let orcPath = Bundle.module.path(forResource: "sine", ofType: "orc") ?? "assets/sine.orc"
    if let sampler = try? await TeatroSampler(backend: .csound(orchestra: orcPath)) {
        let note = MIDI2Note(channel: 0, note: 60, velocity: 0.8, duration: 1.0)
        await sampler.trigger(note)
        await sampler.stopAll()
    }
    group.leave()
}

group.wait()
