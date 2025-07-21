import Teatro
#if canImport(SwiftUI)
import SwiftUI
import TypesenseClient

/// Displays live Typesense metrics and health status.
@MainActor
public struct OpsDashboardView: View {
    private let service: TypesenseService?
    @State private var stats: APIStatsResponse?
    @State private var health: HealthStatus?
    @State private var errorMessage: String?

    /// Runtime initializer using a live service.
    public init(service: TypesenseService) {
        self.service = service
    }

    /// Preview initializer using static data.
    public init(stats: APIStatsResponse, health: HealthStatus) {
        self.service = nil
        self._stats = State(initialValue: stats)
        self._health = State(initialValue: health)
    }

    public var body: some View {
        ScrollView {
            if let stats, let health {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Node Status: \(health.ok ? "🟢" : "🔴")")
                    Text("Requests/s: \(stats.total_requests_per_second)")
                    Text("Search Latency: \(stats.search_latency_ms) ms")
                }
                .padding()
            } else if let errorMessage {
                Text(errorMessage)
                    .padding()
            } else {
                ProgressView()
                    .padding()
            }
        }
        .task { await loadIfNeeded() }
    }

    private func loadIfNeeded() async {
        guard let service else { return }
        do {
            stats = try await service.apiStats()
            health = try await service.fetchHealth()
        } catch {
            errorMessage = error.localizedDescription
        }
    }
}

#if DEBUG
public struct OpsDashboardView_Previews: PreviewProvider {
    public static var previews: some View {
        let stats = APIStatsResponse(
            delete_latency_ms: "0",
            delete_requests_per_second: "0",
            import_latency_ms: "0",
            import_requests_per_second: "0",
            latency_ms: [:],
            overloaded_requests_per_second: "0",
            pending_write_batches: "0",
            requests_per_second: [:],
            search_latency_ms: "10",
            search_requests_per_second: "5",
            total_requests_per_second: "5",
            write_latency_ms: "0",
            write_requests_per_second: "0"
        )
        let health = HealthStatus(ok: true)
        OpsDashboardView(stats: stats, health: health)
    }
}
#endif
#endif
