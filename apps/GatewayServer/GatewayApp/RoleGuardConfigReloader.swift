import Foundation

/// Periodically checks the RoleGuard config file and triggers reloads on change.
final class RoleGuardConfigReloader {
    private let store: RoleGuardStore
    private let url: URL
    private var timer: DispatchSourceTimer?
    private var lastMTime: Date?

    init?(store: RoleGuardStore) async {
        guard let url = await store.configPath else { return nil }
        self.store = store
        self.url = url
    }

    func start(interval: TimeInterval = 2.0) {
        let q = DispatchQueue(label: "roleguard.reload.timer")
        let t = DispatchSource.makeTimerSource(queue: q)
        t.schedule(deadline: .now() + interval, repeating: interval)
        t.setEventHandler { [weak self] in
            guard let self else { return }
            let attrs = try? FileManager.default.attributesOfItem(atPath: self.url.path)
            let mtime = attrs?[.modificationDate] as? Date
            if self.lastMTime == nil { self.lastMTime = mtime }
            if let mtime, let last = self.lastMTime, mtime > last {
                Task { [weak self] in
                    guard let self else { return }
                    let ok = await self.store.reload()
                    if ok {
                        self.lastMTime = mtime
                        let count = (await self.store.rules).count
                        await RoleGuardMetrics.shared.recordReload(ruleCount: count)
                    }
                }
            }
        }
        self.timer = t
        t.resume()
    }

    func stop() {
        timer?.cancel()
        timer = nil
    }
}

// © 2025 Contexter alias Benedikt Eickhoff 🛡️ All rights reserved.

