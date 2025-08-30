import Foundation
import FountainRuntime
import OpenAPICurator
import Yams
#if canImport(FoundationNetworking)
import FoundationNetworking
#endif

private let rulesPath = ProcessInfo.processInfo.environment["CURATOR_RULES_PATH"] ?? "Configuration/curator.yml"
private let rulesURL = URL(fileURLWithPath: rulesPath)
private let initialRules: Rules = {
    let contents = (try? String(contentsOfFile: rulesPath)) ?? ""
    return parseRules(from: contents)
}()
let curatorRulesStore = CuratorRulesStore(initialRules: initialRules, configURL: rulesURL)
var curatorRulesReloader: CuratorRulesReloader? = CuratorRulesReloader(store: curatorRulesStore, url: rulesURL)
curatorRulesReloader?.start(interval: 2.0)

public func metrics_metrics_get() async -> HTTPResponse {
    let uptime = Int(ProcessInfo.processInfo.systemUptime)
    let body = Data("openapi_curator_uptime_seconds \(uptime)\n".utf8)
    return HTTPResponse(status: 200, headers: ["Content-Type": "text/plain"], body: body)
}

func extractOperationIds(from text: String) -> [String] {
    var ops: [String] = []
    for line in text.split(separator: "\n") {
        if let range = line.range(of: "operationId:") {
            let op = line[range.upperBound...].trimmingCharacters(in: .whitespaces)
            if !op.isEmpty { ops.append(String(op)) }
        }
    }
    return ops
}

func queryParams(from path: String) -> [String: String] {
    guard let qIndex = path.firstIndex(of: "?") else { return [:] }
    let query = path[path.index(after: qIndex)...]
    var out: [String: String] = [:]
    for pair in query.split(separator: "&") {
        let parts = pair.split(separator: "=", maxSplits: 1).map(String.init)
        if parts.count == 2 { out[parts[0]] = parts[1] }
    }
    return out
}

public func makeOpenAPICuratorKernel() -> HTTPKernel {
    HTTPKernel { req in
        let env = ProcessInfo.processInfo.environment
        let pathOnly = req.path.split(separator: "?", maxSplits: 1, omittingEmptySubsequences: false).first.map(String.init) ?? req.path
        let segments = pathOnly.split(separator: "/", omittingEmptySubsequences: true)
        do {
            switch (req.method, segments) {
            case ("POST", ["curate"]):
                let obj = try JSONSerialization.jsonObject(with: req.body) as? [String: Any] ?? [:]
                let corpusId = obj["corpusId"] as? String ?? env["DEFAULT_CORPUS_ID"] ?? "tools-factory"
                let submit = (obj["submitToToolsFactory"] as? Bool) ?? false
                let toolsFactoryURL = env["TOOLS_FACTORY_URL"]
                let rawSpecs = obj["specs"] as? [Any] ?? []
                var specs: [Spec] = []
                for item in rawSpecs {
                    if let s = item as? String {
                        let url = URL(string: s).flatMap { $0.scheme != nil ? $0 : nil } ?? URL(fileURLWithPath: s)
                        let data = (try? Data(contentsOf: url)) ?? Data()
                        let text = String(data: data, encoding: .utf8) ?? ""
                        let ops = extractOperationIds(from: text)
                        specs.append(Spec(operations: ops))
                    } else if let dict = item as? [String: Any], let ops = dict["operations"] as? [String] {
                        specs.append(Spec(operations: ops))
                    }
                }
                let rules = await curatorRulesStore.rules
                let result = OpenAPICuratorKit.run(specs: specs, rules: rules)
                let banned: Set<String> = ["metrics_metrics_get", "register_openapi", "list_tools"]
                let filteredOps = result.spec.operations.filter { !banned.contains($0) }

                let storageRoot = env["CURATOR_STORAGE_PATH"] ?? "/data/corpora"
                let ts = ISO8601DateFormatter().string(from: Date())
                let corpusDir = URL(fileURLWithPath: storageRoot).appendingPathComponent(corpusId)
                let outDir = corpusDir.appendingPathComponent(ts)
                try? FileManager.default.createDirectory(at: outDir, withIntermediateDirectories: true)
                let specOut = outDir.appendingPathComponent("curated.yaml")
                let reportOut = outDir.appendingPathComponent("report.json")

                var diff: [String: [String]] = [:]
                let existing = (try? FileManager.default.contentsOfDirectory(atPath: corpusDir.path)) ?? []
                let previous = existing.filter { $0 < ts }.sorted().last
                if let prev = previous {
                    let prevFile = corpusDir.appendingPathComponent(prev).appendingPathComponent("curated.yaml")
                    if let prevText = try? String(contentsOf: prevFile),
                       let prevObj = try? Yams.load(yaml: prevText) as? [String: Any],
                       let prevOps = prevObj["operations"] as? [String] {
                        let prevSet = Set(prevOps)
                        let currSet = Set(filteredOps)
                        let added = Array(currSet.subtracting(prevSet)).sorted()
                        let removed = Array(prevSet.subtracting(currSet)).sorted()
                        if !added.isEmpty || !removed.isEmpty {
                            diff["added"] = added
                            diff["removed"] = removed
                        }
                    }
                }

                if let yaml = try? Yams.dump(object: ["operations": filteredOps]) {
                    try? yaml.write(to: specOut, atomically: true, encoding: .utf8)
                    if submit,
                       let tfURL = toolsFactoryURL,
                       let token = env["TOOLS_FACTORY_TOKEN"],
                       let url = URL(string: "\(tfURL)/tools/register?corpusId=\(corpusId)") {
                        var req = URLRequest(url: url)
                        req.httpMethod = "POST"
                        req.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
                        req.setValue("application/x-yaml", forHTTPHeaderField: "Content-Type")
                        req.httpBody = yaml.data(using: .utf8)
                        _ = try? await URLSession.shared.data(for: req)
                    }
                }

                var reportObj: [String: Any] = [
                    "appliedRules": result.report.appliedRules,
                    "collisions": result.report.collisions
                ]
                if !diff.isEmpty {
                    reportObj["diff"] = diff
                }
                if let reportData = try? JSONSerialization.data(withJSONObject: reportObj, options: [.prettyPrinted]) {
                    try? reportData.write(to: reportOut)
                }
                let respObj: [String: Any] = [
                    "curatedOpenAPI": ["operations": filteredOps],
                    "report": reportObj
                ]
                let json = try JSONSerialization.data(withJSONObject: respObj)
                return HTTPResponse(status: 200, headers: ["Content-Type": "application/json"], body: json)

            case ("POST", ["validate"]):
                let obj = try JSONSerialization.jsonObject(with: req.body) as? [String: Any] ?? [:]
                let rawSpecs = obj["specs"] as? [Any] ?? []
                var specs: [Spec] = []
                for item in rawSpecs {
                    if let s = item as? String {
                        let url = URL(string: s).flatMap { $0.scheme != nil ? $0 : nil } ?? URL(fileURLWithPath: s)
                        let data = (try? Data(contentsOf: url)) ?? Data()
                        let text = String(data: data, encoding: .utf8) ?? ""
                        let ops = extractOperationIds(from: text)
                        specs.append(Spec(operations: ops))
                    } else if let dict = item as? [String: Any], let ops = dict["operations"] as? [String] {
                        specs.append(Spec(operations: ops))
                    }
                }
                let rules = await curatorRulesStore.rules
                let result = OpenAPICuratorKit.run(specs: specs, rules: rules)
                let respObj: [String: Any] = [
                    "report": [
                        "appliedRules": result.report.appliedRules,
                        "collisions": result.report.collisions
                    ]
                ]
                let json = try JSONSerialization.data(withJSONObject: respObj)
                return HTTPResponse(status: 200, headers: ["Content-Type": "application/json"], body: json)

            case ("GET", ["rules"]):
                if let contents = try? String(contentsOfFile: rulesPath),
                   let yamlObj = try? Yams.load(yaml: contents) {
                    let json = try JSONSerialization.data(withJSONObject: yamlObj)
                    return HTTPResponse(status: 200, headers: ["Content-Type": "application/json"], body: json)
                }
                return HTTPResponse(status: 404)

            case ("PUT", ["rules"]):
                if let str = String(data: req.body, encoding: .utf8) {
                    let ok = await curatorRulesStore.replace(with: str)
                    return HTTPResponse(status: ok ? 204 : 400)
                }
                return HTTPResponse(status: 400)

            case ("GET", ["history"]):
                let qp = queryParams(from: req.path)
                let corpusId = qp["corpusId"] ?? env["DEFAULT_CORPUS_ID"] ?? "tools-factory"
                let storageRoot = env["CURATOR_STORAGE_PATH"] ?? "/data/corpora"
                let corpusDir = URL(fileURLWithPath: storageRoot).appendingPathComponent(corpusId)
                let entries = (try? FileManager.default.contentsOfDirectory(atPath: corpusDir.path)) ?? []
                let json = try JSONSerialization.data(withJSONObject: ["snapshots": entries])
                return HTTPResponse(status: 200, headers: ["Content-Type": "application/json"], body: json)

            case ("GET", ["_health"]):
                let json = try JSONSerialization.data(withJSONObject: ["status": "ok"])
                return HTTPResponse(status: 200, headers: ["Content-Type": "application/json"], body: json)

            case ("GET", ["metrics"]):
                return await metrics_metrics_get()

            default:
                return HTTPResponse(status: 404)
            }
        } catch {
            return HTTPResponse(status: 400)
        }
    }
}

// © 2025 Contexter alias Benedikt Eickhoff 🛡️ All rights reserved.
