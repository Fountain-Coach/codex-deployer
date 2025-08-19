import Foundation

public final class QemuRunner: SandboxRunner {
    private let qemu: URL
    private let image: URL
    public private(set) var forwardedPort: UInt16?

    public init(qemu: URL = URL(fileURLWithPath: "/usr/bin/qemu-system-x86_64"),
                image: URL) {
        self.qemu = qemu
        self.image = image
    }

    @discardableResult
    public func run(
        executable: String,
        arguments: [String] = [],
        inputs: [URL] = [],
        workDirectory: URL,
        allowNetwork: Bool = false,
        timeout: TimeInterval? = nil,
        limits: CgroupLimits? = nil
    ) throws -> SandboxResult {
        _ = inputs
        _ = limits
        var args: [String] = []
        #if os(macOS)
        args += ["-accel", "hvf"]
        #else
        args += ["-enable-kvm"]
        #endif
        args += ["-drive", "file=\(image.path),if=virtio,snapshot=on"]
        args += ["-virtfs", "local,path=\(workDirectory.path),mount_tag=work,security_model=none"]
        let port = UInt16.random(in: 40000..<60000)
        forwardedPort = port
        if allowNetwork {
            args += ["-netdev", "user,id=net0,hostfwd=tcp:127.0.0.1:\(port)-:8080",
                     "-device", "virtio-net-pci,netdev=net0"]
        } else {
            args += ["-netdev", "user,id=net0,hostfwd=tcp:127.0.0.1:\(port)-:8080,restrict=on",
                     "-device", "virtio-net-pci,netdev=net0"]
        }
        args += ["-nographic"]
        let command = ([executable] + arguments).joined(separator: " ")
        args += ["-append", command]

        let process = Process()
        process.executableURL = qemu
        process.arguments = args
        let stdout = Pipe()
        let stderr = Pipe()
        process.standardOutput = stdout
        process.standardError = stderr
        try process.run()

        var timedOut = false
        if let timeout = timeout {
            let group = DispatchGroup()
            group.enter()
            process.terminationHandler = { _ in group.leave() }
            if group.wait(timeout: .now() + timeout) == .timedOut {
                timedOut = true
                process.terminate()
                process.waitUntilExit()
            }
        } else {
            process.waitUntilExit()
        }
        if timedOut {
            throw NSError(domain: "QemuRunner", code: 1, userInfo: [NSLocalizedDescriptionKey: "Process timed out"])
        }
        let outData = stdout.fileHandleForReading.readDataToEndOfFile()
        let errData = stderr.fileHandleForReading.readDataToEndOfFile()
        return SandboxResult(
            stdout: String(data: outData, encoding: .utf8) ?? "",
            stderr: String(data: errData, encoding: .utf8) ?? "",
            exitCode: process.terminationStatus
        )
    }
}

// © 2025 Contexter alias Benedikt Eickhoff 🛡️ All rights reserved.
