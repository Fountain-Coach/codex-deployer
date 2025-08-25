import Foundation
#if canImport(Network)
import Network

public final class RTPMidiSession: MIDITransport, @unchecked Sendable {
    public var onReceiveUMP: (([UInt32]) -> Void)? {
        didSet {
            if let cb = onReceiveUMP {
                onReceiveUmps = { umps in
                    for u in umps { cb(u) }
                }
            } else {
                onReceiveUmps = nil
            }
        }
    }
    public var onReceiveUmps: (([[UInt32]]) -> Void)?

    private let localName: String
    private let mtu: Int
    private let enableDiscovery: Bool
    private let enableCINegotiation: Bool
    private let queue = DispatchQueue(label: "RTPMidiSessionQueue")
    private var listener: NWListener?
    private var browser: NWBrowser?
    private var connection: NWConnection?
    private var incoming: [NWConnection] = []
    private var discovered: Set<String> = []

    private var localID = UUID()
    private var remoteID: UUID?
    private var protocolVersion: UInt8 = 0
    private var negotiatedGroup: UInt8 = 0
    private var negotiatedChannel: UInt8 = 0

    public init(localName: String,
                mtu: Int = 1500,
                enableDiscovery: Bool = true,
                enableCINegotiation: Bool = true) {
        self.localName = localName
        self.mtu = mtu
        self.enableDiscovery = enableDiscovery
        self.enableCINegotiation = enableCINegotiation
    }

    public func open() throws {
        let params = NWParameters.udp
        let ready = DispatchSemaphore(value: 0)
        listener = try NWListener(using: params, on: .any)
        if enableDiscovery {
            listener?.service = NWListener.Service(name: localName, type: "_rtp-midi._udp")
        }
        listener?.stateUpdateHandler = { [weak self] state in
            switch state {
            case .ready:
                guard let self else { return }
                if let port = self.listener?.port {
                    let host = NWEndpoint.Host("127.0.0.1")
                    let conn = NWConnection(host: host, port: port, using: params)
                    conn.start(queue: self.queue)
                    if self.enableCINegotiation {
                        self.startMIDICINegotiation(on: conn)
                    }
                    self.configureReceive(on: conn)
                    self.connection = conn
                }
                ready.signal()
            default:
                break
            }
        }
        listener?.newConnectionHandler = { [weak self] newConn in
            guard let self else { return }
            self.incoming.append(newConn)
            newConn.start(queue: self.queue)
            if self.enableCINegotiation {
                self.startMIDICINegotiation(on: newConn)
            }
            self.configureReceive(on: newConn)
        }
        listener?.start(queue: queue)
        if enableDiscovery { startBonjourDiscovery() }
        ready.wait()
    }

    public func close() throws {
        connection?.cancel()
        listener?.cancel()
        browser?.cancel()
        incoming.forEach { $0.cancel() }
        incoming.removeAll()
    }

    public func send(umpWords: [UInt32]) throws {
        try send(umps: [umpWords])
    }

    public func send(umps: [[UInt32]]) throws {
        guard let connection else { return }
        var buffer: [UInt32] = []
        var bufferBytes = 0
        func flush() {
            guard !buffer.isEmpty else { return }
            var payload = Data()
            for w in buffer {
                var be = w.bigEndian
                payload.append(Data(bytes: &be, count: 4))
            }
            buffer.removeAll()
            bufferBytes = 0
            let header = Data([0x80, 0x61, 0x00, 0x00,
                               0x00, 0x00, 0x00, 0x00,
                               0x00, 0x00, 0x00, 0x00])
            let packet = header + payload
            connection.send(content: packet, completion: .contentProcessed { _ in })
        }
        for ump in umps {
            let bytes = ump.count * 4
            if bufferBytes + bytes + 12 > mtu { // 12-byte RTP header
                flush()
            }
            buffer.append(contentsOf: ump)
            bufferBytes += bytes
        }
        flush()
    }

    private func configureReceive(on connection: NWConnection) {
        let handler: (Data?, NWConnection.ContentContext?, Bool, NWError?) -> Void = { [weak self] data, _, _, _ in
            if let data = data, data.count >= 12 {
                let payload = data.subdata(in: 12..<data.count)
                var umps: [[UInt32]] = []
                var idx = payload.startIndex
                while idx < payload.endIndex {
                    var ump: [UInt32] = []
                    for _ in 0..<4 {
                        guard idx + 4 <= payload.endIndex else { break }
                        let word = payload[idx..<idx+4].withUnsafeBytes { $0.load(as: UInt32.self) }
                        ump.append(UInt32(bigEndian: word))
                        idx += 4
                    }
                    if !ump.isEmpty { umps.append(ump) }
                }
                self?.onReceiveUmps?(umps)
            }
            self?.configureReceive(on: connection)
        }
        connection.receiveMessage(completion: handler)
    }

    private func startBonjourDiscovery() {
        guard listener != nil else { return }
        browser = NWBrowser(for: .bonjour(type: "_rtp-midi._udp", domain: nil), using: .udp)
        browser?.browseResultsChangedHandler = { [weak self] results, _ in
            guard let self else { return }
            self.discovered = Set(results.compactMap { result in
                if case let .service(name: name, type: _, domain: _, interface: _) = result.endpoint {
                    return name
                }
                return nil
            })
        }
        browser?.start(queue: queue)
    }

    private func startMIDICINegotiation(on connection: NWConnection) {
        var msg = Data([0x4D, 0x43, 0x01]) // "MC" + protocol version
        var uuid = localID.uuid
        withUnsafeBytes(of: &uuid) { msg.append(contentsOf: $0) }
        msg.append(contentsOf: [negotiatedGroup, negotiatedChannel])

        let sem = DispatchSemaphore(value: 0)
        let negotiationHandler: (Data?, NWConnection.ContentContext?, Bool, NWError?) -> Void = { [weak self] data, _, _, _ in
            if let data = data, data.count >= 21 {
                self?.protocolVersion = data[2]
                var uuidBytes = uuid_t()
                _ = withUnsafeMutableBytes(of: &uuidBytes) {
                    data.copyBytes(to: $0, from: 3..<19)
                }
                self?.remoteID = UUID(uuid: uuidBytes)
                self?.negotiatedGroup = data[19]
                self?.negotiatedChannel = data[20]
            }
            sem.signal()
        }
        connection.receiveMessage(completion: negotiationHandler)
        connection.send(content: msg, completion: .contentProcessed { _ in })
        sem.wait()
    }
}
#else

public final class RTPMidiSession: MIDITransport {
    public var onReceiveUMP: (([UInt32]) -> Void)?
    public var onReceiveUmps: (([[UInt32]]) -> Void)?

    public init(localName: String, mtu: Int = 1500, enableDiscovery: Bool = true, enableCINegotiation: Bool = true) {}

    public func open() throws {}

    public func close() throws {}

    public func send(umpWords: [UInt32]) throws {
        onReceiveUMP?(umpWords)
        onReceiveUmps?([umpWords])
    }

    public func send(umps: [[UInt32]]) throws {
        for u in umps { try send(umpWords: u) }
    }
}
#endif

// © 2025 Contexter alias Benedikt Eickhoff 🛡️ All rights reserved.
