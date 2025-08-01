import Foundation

/// Manages periodic execution of a certificate renewal script.
public final class CertificateManager {
    /// Dispatch timer scheduling periodic renewals.
    private var timer: DispatchSourceTimer?
    /// Absolute path to the renewal script executed.
    private let scriptPath: String
    /// Delay between script executions.
    private let interval: TimeInterval

    /// Creates a new manager with optional script path and repeat interval.
    /// - Parameters:
    ///   - scriptPath: Shell script used for renewal.
    ///   - interval: Time between renewals in seconds.
    public init(scriptPath: String = "./Scripts/renew-certs.sh", interval: TimeInterval = 86_400) {
        self.scriptPath = scriptPath
        self.interval = interval
    }

    /// Starts automatic certificate renewal on a timer.
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

    /// Stops the timer and cancels future renewals.
    public func stop() {
        timer?.cancel()
        timer = nil
    }

    /// Immediately runs the renewal script once.
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
