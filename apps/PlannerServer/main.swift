import Foundation
import Dispatch
import FountainRuntime
import Yams
import TypesensePersistence
import PlannerService

struct PlannerConfig: Codable {
    var typesenseURLs: [String]
    var apiKey: String
    var debug: Bool
}

func loadPlannerConfig() -> PlannerConfig? {
    let fileURL = URL(fileURLWithPath: "Configuration/planner.yml")
    if FileManager.default.fileExists(atPath: fileURL.path) {
        if let contents = try? String(contentsOf: fileURL, encoding: .utf8) {
            let sanitized = contents
                .split(separator: "\n", omittingEmptySubsequences: false)
                .filter { !$0.trimmingCharacters(in: .whitespaces).hasPrefix("©") }
                .joined(separator: "\n")
            if let yaml = try? Yams.load(yaml: sanitized) as? [String: Any] {
                let urls = (yaml["typesenseURLs"] as? [String]) ?? []
                let apiKey = (yaml["apiKey"] as? String) ?? ""
                let debug = (yaml["debug"] as? Bool) ?? false
                return PlannerConfig(typesenseURLs: urls, apiKey: apiKey, debug: debug)
            }
        }
    }
    let env = ProcessInfo.processInfo.environment
    let urls = env["TYPESENSE_URLS"].map { $0.split(separator: ",").map { String($0) } }
        ?? env["TYPESENSE_URL"].map { [ $0 ] }
        ?? []
    let apiKey = env["TYPESENSE_API_KEY"] ?? ""
    let debug = (env["PLANNER_DEBUG"] ?? "").lowercased() == "true"
    if urls.isEmpty || apiKey.isEmpty { return nil }
    return PlannerConfig(typesenseURLs: urls, apiKey: apiKey, debug: debug)
}

func buildService() -> TypesensePersistenceService {
    if let cfg = loadPlannerConfig() {
        #if canImport(Typesense)
        let client = RealTypesenseClient(nodes: cfg.typesenseURLs, apiKey: cfg.apiKey, debug: cfg.debug)
        return TypesensePersistenceService(client: client)
        #else
        return TypesensePersistenceService(client: MockTypesenseClient())
        #endif
    } else {
        FileHandle.standardError.write(Data("[planner] Warning: TYPESENSE_URL(S) or TYPESENSE_API_KEY not set; using in-memory mock.\n".utf8))
        return TypesensePersistenceService(client: MockTypesenseClient())
    }
}

let svc = buildService()
Task {
    await svc.ensureCollections()
    let kernel = makePlannerKernel(service: svc)
    let server = NIOHTTPServer(kernel: kernel)
    do {
        _ = try await server.start(port: 8083)
        print("planner server listening on port 8083")
    } catch {
        FileHandle.standardError.write(Data("[planner] Failed to start: \(error)\n".utf8))
    }
}
dispatchMain()

// © 2025 Contexter alias Benedikt Eickhoff 🛡️ All rights reserved.
