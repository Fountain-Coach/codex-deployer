import Foundation
import FountainRuntime
import OpenAPICurator
import Yams
#if canImport(FoundationNetworking)
import FoundationNetworking
#endif

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

func loadRules() -> Rules {
    let path = ProcessInfo.processInfo.environment["CURATOR_RULES_PATH"] ?? "Configuration/curator.yml"
    if let contents = try? String(contentsOfFile: path),
       let yaml = try? Yams.load(yaml: contents) as? [String: Any] {
        let renames = yaml["renames"] as? [String: String] ?? [:]
        return Rules(renames: renames)
    }
    return Rules()
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
                let rules = loadRules()
                let result = OpenAPICuratorKit.run(specs: specs, rules: rules, submit: submit && toolsFactoryURL != nil)
                let storageBase = env["CURATOR_STORAGE_PATH"] ?? "/data/corpora/\(corpusId)/curator"
                let ts = ISO8601DateFormatter().string(from: Date())
                let outDir = URL(fileURLWithPath: storageBase).appendingPathComponent(ts)
                try? FileManager.default.createDirectory(at: outDir, withIntermediateDirectories: true)
                let specOut = outDir.appendingPathComponent("curated.json")
                let reportOut = outDir.appendingPathComponent("report.json")
                if let specData = try? JSONSerialization.data(withJSONObject: ["operations": result.spec.operations], options: [.prettyPrinted]) {
                    try? specData.write(to: specOut)
                }
                if let reportData = try? JSONSerialization.data(withJSONObject: ["appliedRules": result.report.appliedRules, "collisions": result.report.collisions], options: [.prettyPrinted]) {
                    try? reportData.write(to: reportOut)
                }
                let respObj: [String: Any] = [
                    "curatedOpenAPI": ["operations": result.spec.operations],
                    "report": [
                        "appliedRules": result.report.appliedRules,
                        "collisions": result.report.collisions
                    ]
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
                let rules = loadRules()
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
                let path = env["CURATOR_RULES_PATH"] ?? "Configuration/curator.yml"
                if let contents = try? String(contentsOfFile: path),
                   let yamlObj = try? Yams.load(yaml: contents) {
                    let json = try JSONSerialization.data(withJSONObject: yamlObj)
                    return HTTPResponse(status: 200, headers: ["Content-Type": "application/json"], body: json)
                }
                return HTTPResponse(status: 404)

            case ("PUT", ["rules"]):
                let path = env["CURATOR_RULES_PATH"] ?? "Configuration/curator.yml"
                if let str = String(data: req.body, encoding: .utf8) {
                    try? str.write(toFile: path, atomically: true, encoding: .utf8)
                    return HTTPResponse(status: 204)
                }
                return HTTPResponse(status: 400)

            case ("GET", ["history"]):
                let qp = queryParams(from: req.path)
                let corpusId = qp["corpusId"] ?? env["DEFAULT_CORPUS_ID"] ?? "tools-factory"
                let storageBase = env["CURATOR_STORAGE_PATH"] ?? "/data/corpora/\(corpusId)/curator"
                let entries = (try? FileManager.default.contentsOfDirectory(atPath: storageBase)) ?? []
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
