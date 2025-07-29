import Foundation

public final class CertificateManager {
    private var timer: DispatchSourceTimer?
    private let scriptPath: String
    private let interval: TimeInterval

    public init(scriptPath: String = "./Scripts/renew-certs.sh", interval: TimeInterval = 86_400) {
        self.scriptPath = scriptPath
        self.interval = interval
    }

    public func start() {
        let timer = DispatchSource.makeTimerSource()
        timer.schedule(deadline: .now(), repeating: interval)
        timer.setEventHandler { [scriptPath] in
            let task = Process()
            task.executableURL = URL(fileURLWithPath: scriptPath)
            do {
                try task.run()
            } catch {
                print("Certificate renewal failed: \(error)")
            }
        }
        self.timer = timer
        timer.resume()
    }

    public func stop() {
        timer?.cancel()
        timer = nil
    }

    public func triggerNow() {
        let task = Process()
        task.executableURL = URL(fileURLWithPath: scriptPath)
        do {
            try task.run()
        } catch {
            print("Certificate renewal failed: \(error)")
        }
    }
}

// © 2025 Contexter alias Benedikt Eickhoff 🛡️ All rights reserved.
