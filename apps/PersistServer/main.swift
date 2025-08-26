import Foundation
import FountainCodex
import Yams
import TypesensePersistence

struct PersistConfig: Codable {
    var typesenseURLs: [String]
    var apiKey: String
    var debug: Bool
}

func loadPersistConfig() -> PersistConfig? {
    // Prefer YAML file if present, else read from env
    let fileURL = URL(fileURLWithPath: "Configuration/persist.yml")
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
                return PersistConfig(typesenseURLs: urls, apiKey: apiKey, debug: debug)
            }
        }
    }
    let env = ProcessInfo.processInfo.environment
    let urls = env["TYPESENSE_URLS"].map { $0.split(separator: ",").map { String($0) } }
        ?? env["TYPESENSE_URL"].map { [ $0 ] }
        ?? []
    let apiKey = env["TYPESENSE_API_KEY"] ?? ""
    let debug = (env["PERSIST_DEBUG"] ?? "").lowercased() == "true"
    if urls.isEmpty || apiKey.isEmpty { return nil }
    return PersistConfig(typesenseURLs: urls, apiKey: apiKey, debug: debug)
}

@main
enum Main {
    static func buildService() -> TypesensePersistenceService {
        if let cfg = loadPersistConfig() {
            #if canImport(Typesense)
            let client = RealTypesenseClient(nodes: cfg.typesenseURLs, apiKey: cfg.apiKey, debug: cfg.debug)
            return TypesensePersistenceService(client: client)
            #else
            return TypesensePersistenceService(client: MockTypesenseClient())
            #endif
        } else {
            FileHandle.standardError.write(Data("[persist] Warning: TYPESENSE_URL(S) or TYPESENSE_API_KEY not set; using in-memory mock.\n".utf8))
            return TypesensePersistenceService(client: MockTypesenseClient())
        }
    }

    static func main() async {
        let svc = buildService()
        await svc.ensureCollections()

        let kernel = HTTPKernel { req in
            let segments = req.path.split(separator: "/", omittingEmptySubsequences: true)
            do {
                switch (req.method, segments) {
                case ("GET", ["metrics"]):
                    let body = Data("persist_requests_total 0\n".utf8)
                    return HTTPResponse(status: 200, headers: ["Content-Type": "text/plain"], body: body)

                case ("GET", ["corpora"]):
                    let qp = Self.queryParams(from: req.path)
                    let limit = min(max(Int(qp["limit"] ?? "50") ?? 50, 1), 200)
                    let offset = max(Int(qp["offset"] ?? "0") ?? 0, 0)
                    let (total, corpora) = try await svc.listCorpora(limit: limit, offset: offset)
                    let json = try JSONSerialization.data(withJSONObject: ["total": total, "corpora": corpora])
                    return HTTPResponse(status: 200, headers: ["Content-Type": "application/json"], body: json)

                case ("POST", ["corpora"]):
                    let reqObj = try JSONDecoder().decode(CorpusCreateRequest.self, from: req.body)
                    let resp = try await svc.createCorpus(reqObj)
                    let json = try JSONEncoder().encode(resp)
                    return HTTPResponse(status: 201, headers: ["Content-Type": "application/json"], body: json)

                case ("GET", let seg) where seg.count == 3 && seg[0] == "corpora" && seg[2] == "baselines":
                    let corpusId = String(seg[1])
                    let qp = Self.queryParams(from: req.path)
                    let limit = min(max(Int(qp["limit"] ?? "50") ?? 50, 1), 200)
                    let offset = max(Int(qp["offset"] ?? "0") ?? 0, 0)
                    let (total, baselines) = try await svc.listBaselines(corpusId: corpusId, limit: limit, offset: offset)
                    let obj: [String: Any] = [
                        "total": total,
                        "baselines": try baselines.map { try JSONSerialization.jsonObject(with: JSONEncoder().encode($0)) }
                    ]
                    let json = try JSONSerialization.data(withJSONObject: obj)
                    return HTTPResponse(status: 200, headers: ["Content-Type": "application/json"], body: json)

                case ("POST", let seg) where seg.count == 3 && seg[0] == "corpora" && seg[2] == "baselines":
                    let corpusId = String(seg[1])
                    var baseline = try JSONDecoder().decode(Baseline.self, from: req.body)
                    if baseline.corpusId != corpusId {
                        // if mismatch, override to path param for safety
                        baseline = Baseline(corpusId: corpusId, baselineId: baseline.baselineId, content: baseline.content)
                    }
                    let resp = try await svc.addBaseline(baseline)
                    let json = try JSONEncoder().encode(resp)
                    return HTTPResponse(status: 200, headers: ["Content-Type": "application/json"], body: json)

                case ("GET", let seg) where seg.count == 3 && seg[0] == "corpora" && seg[2] == "reflections":
                    let corpusId = String(seg[1])
                    let qp = Self.queryParams(from: req.path)
                    let limit = min(max(Int(qp["limit"] ?? "50") ?? 50, 1), 200)
                    let offset = max(Int(qp["offset"] ?? "0") ?? 0, 0)
                    let (total, reflections) = try await svc.listReflections(corpusId: corpusId, limit: limit, offset: offset)
                    let obj: [String: Any] = [
                        "total": total,
                        "reflections": try reflections.map { try JSONSerialization.jsonObject(with: JSONEncoder().encode($0)) }
                    ]
                    let json = try JSONSerialization.data(withJSONObject: obj)
                    return HTTPResponse(status: 200, headers: ["Content-Type": "application/json"], body: json)

                case ("POST", let seg) where seg.count == 3 && seg[0] == "corpora" && seg[2] == "reflections":
                    let corpusId = String(seg[1])
                    var reflection = try JSONDecoder().decode(Reflection.self, from: req.body)
                    if reflection.corpusId != corpusId {
                        reflection = Reflection(corpusId: corpusId, reflectionId: reflection.reflectionId, question: reflection.question, content: reflection.content)
                    }
                    let resp = try await svc.addReflection(reflection)
                    let json = try JSONEncoder().encode(resp)
                    return HTTPResponse(status: 200, headers: ["Content-Type": "application/json"], body: json)

                case ("POST", let seg) where seg.count == 3 && seg[0] == "corpora" && seg[2] == "functions":
                    // Currently functions are global; we ignore corpusId for storage but accept the path.
                    _ = String(seg[1])
                    let function = try JSONDecoder().decode(FunctionModel.self, from: req.body)
                    let resp = try await svc.addFunction(function)
                    let json = try JSONEncoder().encode(resp)
                    return HTTPResponse(status: 200, headers: ["Content-Type": "application/json"], body: json)

                case ("GET", ["functions"]):
                    let qp = Self.queryParams(from: req.path)
                    let limit = min(max(Int(qp["limit"] ?? "50") ?? 50, 1), 200)
                    let offset = max(Int(qp["offset"] ?? "0") ?? 0, 0)
                    let (total, functions) = try await svc.listFunctions(limit: limit, offset: offset)
                    let obj: [String: Any] = [
                        "total": total,
                        "functions": try functions.map { try JSONSerialization.jsonObject(with: JSONEncoder().encode($0)) }
                    ]
                    let json = try JSONSerialization.data(withJSONObject: obj)
                    return HTTPResponse(status: 200, headers: ["Content-Type": "application/json"], body: json)

                case ("GET", let seg) where seg.count == 2 && seg[0] == "functions":
                    let functionId = String(seg[1])
                    if let f = try await svc.getFunctionDetails(functionId: functionId) {
                        let json = try JSONEncoder().encode(f)
                        return HTTPResponse(status: 200, headers: ["Content-Type": "application/json"], body: json)
                    }
                    return HTTPResponse(status: 404)

                default:
                    return HTTPResponse(status: 404)
                }
            } catch {
                return HTTPResponse(status: 400)
            }
        }

        let server = NIOHTTPServer(kernel: kernel)
        do {
            _ = try await server.start(port: 8005)
            print("persist server listening on port 8005")
            dispatchMain()
        } catch {
            FileHandle.standardError.write(Data("[persist] Failed to start: \(error)\n".utf8))
        }
    }

    private static func queryParams(from path: String) -> [String: String] {
        guard let qIndex = path.firstIndex(of: "?") else { return [:] }
        let query = path[path.index(after: qIndex)...]
        var out: [String: String] = [:]
        for pair in query.split(separator: "&") {
            let parts = pair.split(separator: "=", maxSplits: 1).map(String.init)
            if parts.count == 2 { out[parts[0]] = parts[1] }
        }
        return out
    }
}

// © 2025 Contexter alias Benedikt Eickhoff 🛡️ All rights reserved.

