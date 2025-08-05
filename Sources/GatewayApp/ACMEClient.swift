import Foundation
import AcmeSwift

/// Represents a DNS-01 challenge requiring publishing a TXT record.
public struct DNSChallenge {
    /// Fully-qualified record name that must be created.
    public let recordName: String
    /// TXT record value proving control of the domain.
    public let recordValue: String

    /// Creates a new DNS challenge description.
    /// - Parameters:
    ///   - recordName: Fully-qualified record name to publish.
    ///   - recordValue: TXT record value for the challenge.
    public init(recordName: String, recordValue: String) {
        self.recordName = recordName
        self.recordValue = recordValue
    }
}

/// Opaque wrapper around an ACME order handled by ``AcmeSwift``.
public struct ACMEOrder {
    internal let state: Any
    /// Creates a new wrapper.
    /// - Parameter state: Underlying order representation.
    public init(state: Any = ()) {
        self.state = state
    }
}

/// Minimal interface required for performing ACME certificate flows.
public protocol ACMEClient {
    /// Creates or reuses an ACME account for the given email address.
    func createAccount(email: String) async throws
    /// Initiates an order for the provided domain.
    func createOrder(for domain: String) async throws -> ACMEOrder
    /// Fetches DNS challenges that must be satisfied for the order.
    func fetchDNSChallenges(order: ACMEOrder) async throws -> [DNSChallenge]
    /// Requests validation of previously published challenges.
    func validate(order: ACMEOrder) async throws
    /// Finalizes the order and returns an updated representation.
    func finalize(order: ACMEOrder, domains: [String]) async throws -> ACMEOrder
    /// Downloads the certificate chain for a validated order.
    func downloadCertificates(order: ACMEOrder) async throws -> [String]
}

extension AcmeSwift: ACMEClient {
    public func createAccount(email: String) async throws {
        _ = try await self.account.create(contacts: ["mailto:\(email)"], acceptTOS: true)
    }

    public func createOrder(for domain: String) async throws -> ACMEOrder {
        let info = try await self.orders.create(domains: [domain])
        return ACMEOrder(state: info)
    }

    public func fetchDNSChallenges(order: ACMEOrder) async throws -> [DNSChallenge] {
        guard let info = order.state as? AcmeOrderInfo else { return [] }
        let descs = try await self.orders.describePendingChallenges(from: info, preferring: .dns)
        return descs.filter { $0.type == .dns }.map { DNSChallenge(recordName: $0.endpoint, recordValue: $0.value) }
    }

    public func validate(order: ACMEOrder) async throws {
        guard let info = order.state as? AcmeOrderInfo else { return }
        _ = try await self.orders.validateChallenges(from: info, preferring: .dns)
    }

    public func finalize(order: ACMEOrder, domains: [String]) async throws -> ACMEOrder {
        guard let info = order.state as? AcmeOrderInfo else { return order }
        let (_, _, finalized) = try await self.orders.finalizeWithEcdsa(order: info, domains: domains)
        return ACMEOrder(state: finalized)
    }

    public func downloadCertificates(order: ACMEOrder) async throws -> [String] {
        guard let info = order.state as? AcmeOrderInfo else { return [] }
        return try await self.certificates.download(for: info)
    }
}

// © 2025 Contexter alias Benedikt Eickhoff 🛡️ All rights reserved.
