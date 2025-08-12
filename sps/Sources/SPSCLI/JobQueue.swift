import Foundation

final class SPSJobQueue: @unchecked Sendable {
    static let shared = SPSJobQueue()
    private let queue = DispatchQueue(label: "sps.job.queue", attributes: .concurrent)
    private let storageURL: URL

    enum State: String, Codable { case pending, running, completed, failed }

    struct Job: Codable {
        var id: UUID
        var state: State
        var progress: Double
        var result: String?
        var error: String?
    }

    private var jobs: [UUID: Job] = [:]

    private init() {
        let dir = FileManager.default.temporaryDirectory.appendingPathComponent("sps-jobs", isDirectory: true)
        try? FileManager.default.createDirectory(at: dir, withIntermediateDirectories: true)
        storageURL = dir
        if let files = try? FileManager.default.contentsOfDirectory(at: dir, includingPropertiesForKeys: nil) {
            for file in files where file.pathExtension == "json" {
                if let data = try? Data(contentsOf: file),
                   let job = try? JSONDecoder().decode(Job.self, from: data) {
                    jobs[job.id] = job
                }
            }
        }
    }

    private func persist(_ job: Job) {
        let url = storageURL.appendingPathComponent("\(job.id.uuidString).json")
        if let data = try? JSONEncoder().encode(job) {
            try? data.write(to: url)
        }
    }

    private func update(id: UUID, _ mutate: @escaping @Sendable (inout Job) -> Void) {
        queue.async(flags: .barrier) {
            guard var job = self.jobs[id] else { return }
            mutate(&job)
            self.jobs[id] = job
            self.persist(job)
        }
    }

    func enqueueScan(pdfs: [String], out: String, includeText: Bool, sha256: Bool) -> UUID {
        let id = UUID()
        let job = Job(id: id, state: .pending, progress: 0, result: nil, error: nil)
        queue.sync(flags: .barrier) {
            self.jobs[id] = job
            self.persist(job)
        }

        DispatchQueue.global().async {
            self.update(id: id) { $0.state = .running }
            do {
                var docs: [IndexDoc] = []
                for (idx, path) in pdfs.enumerated() {
                    let url = URL(fileURLWithPath: path)
                    let data = (try? Data(contentsOf: url)) ?? Data()
                    let pages = extractPages(data: data, includeText: includeText)
                    let hash = sha256 ? sha256Hex(data: data) : nil
                    let doc = IndexDoc(id: UUID().uuidString, fileName: url.lastPathComponent, size: data.count, sha256: hash, pages: pages)
                    docs.append(doc)
                    let pct = Double(idx + 1) / Double(pdfs.count)
                    self.update(id: id) { $0.progress = pct }
                }
                let index = IndexRoot(documents: docs)
                let enc = JSONEncoder()
                enc.outputFormatting = [.prettyPrinted, .sortedKeys]
                let json = try enc.encode(index)
                try json.write(to: URL(fileURLWithPath: out))
                self.update(id: id) {
                    $0.state = .completed
                    $0.progress = 1.0
                    $0.result = out
                }
            } catch {
                self.update(id: id) {
                    $0.state = .failed
                    $0.progress = 1.0
                    $0.error = String(describing: error)
                }
            }
        }

        return id
    }

    func status(id: UUID) -> Job? {
        var job: Job?
        queue.sync {
            job = jobs[id]
        }
        return job
    }
}

// © 2025 Contexter alias Benedikt Eickhoff 🛡️ All rights reserved.
