#if canImport(SwiftUI)
import Foundation
import Combine

/// Manages the lifecycle of ``dispatcher_v2.py`` and streams log output.
@MainActor
public final class DispatcherManager: ObservableObject {
    @Published public private(set) var isRunning: Bool = false
    @Published public private(set) var logs: [String] = []
    @Published public private(set) var cycleCount: Int = 0
    @Published public private(set) var lastBuildResult: String = ""

    private var process: Process?
    private var logPipe = Pipe()
    private var cancellables = Set<AnyCancellable>()

    public init() {}

    /// Launch the Python dispatcher if not already running.
    public func start() {
        guard !isRunning else { return }
        let proc = Process()
        proc.executableURL = URL(fileURLWithPath: "/usr/bin/python3")
        proc.arguments = ["deploy/dispatcher_v2.py"]
        proc.standardOutput = logPipe
        proc.standardError = logPipe
        proc.terminationHandler = { [weak self] _ in
            DispatchQueue.main.async { self?.isRunning = false }
        }
        do {
            try proc.run()
            captureOutput()
            process = proc
            isRunning = true
        } catch {
            append("Failed to start dispatcher: \(error.localizedDescription)")
        }
    }

    /// Terminate the running dispatcher process.
    public func stop() {
        guard let proc = process, proc.isRunning else { return }
        proc.terminate()
        process = nil
        isRunning = false
    }

    private func captureOutput() {
        logPipe.fileHandleForReading.readabilityHandler = { [weak self] handle in
            let data = handle.availableData
            guard !data.isEmpty, let str = String(data: data, encoding: .utf8) else { return }
            DispatchQueue.main.async {
                self?.append(str)
            }
        }
    }

    private func append(_ line: String) {
        logs.append(contentsOf: line.split(separator: "\n").map(String.init))
        if line.contains("=== New Cycle ===") { cycleCount += 1 }
        if line.contains("swift build succeeded") { lastBuildResult = "✅ build" }
        if line.contains("swift build failed") { lastBuildResult = "❌ build" }
    }
}
#endif
