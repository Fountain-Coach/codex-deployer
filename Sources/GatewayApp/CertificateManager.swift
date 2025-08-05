import Foundation
import PublishingFrontend

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
    /// Invokes the configured shell script every ``interval`` seconds on a
    /// background queue until ``stop()`` is called.
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
    /// Safe to call multiple times; subsequent calls have no effect.
    public func stop() {
        timer?.cancel()
        timer = nil
    }

    /// Immediately runs the renewal script once outside the normal schedule.
    /// Any error is printed to standard output.
    public func triggerNow() {
        let task = Process()
        task.executableURL = URL(fileURLWithPath: scriptPath)
        do {
            try task.run()
        } catch {
            print("Certificate renewal failed: \(error)")
        }
    }

    /// Issues a certificate for the given domain using ACME DNS validation.
    /// - Parameters:
    ///   - domain: Fully-qualified domain name to secure.
    ///   - email: Contact email for ACME account registration.
    ///   - dns: Provider capable of creating TXT records via API.
    ///   - acme: Client performing ACME interactions.
    /// - Returns: PEM-encoded certificate chain.
    public func issueCertificate(for domain: String, email: String, dns: DNSProvider, acme: ACMEClient) async throws -> [String] {
        try await acme.createAccount(email: email)
        var order = try await acme.createOrder(for: domain)
        let challenges = try await acme.fetchDNSChallenges(order: order)
        for challenge in challenges {
            try await dns.createRecord(zone: domain, name: challenge.recordName, type: "TXT", value: challenge.recordValue)
        }
        try await acme.validate(order: order)
        order = try await acme.finalize(order: order, domains: [domain])
        return try await acme.downloadCertificates(order: order)
    }
}

// © 2025 Contexter alias Benedikt Eickhoff 🛡️ All rights reserved.
