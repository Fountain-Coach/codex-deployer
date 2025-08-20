import Foundation
#if canImport(Network)
import Network

public final class RTPMidiSession: MIDITransport {
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
    private let queue = DispatchQueue(label: "RTPMidiSessionQueue")
    private var listener: NWListener?
    private var connection: NWConnection?
    private var incoming: [NWConnection] = []

    public init(localName: String, mtu: Int = 1500) {
        self.localName = localName
        self.mtu = mtu
    }

    public func open() throws {
        startBonjourDiscovery()
        startMIDICINegotiation()

        let params = NWParameters.udp
        let ready = DispatchSemaphore(value: 0)
        listener = try NWListener(using: params, on: .any)
        listener?.stateUpdateHandler = { [weak self] state in
            switch state {
            case .ready:
                guard let self else { return }
                if let port = self.listener?.port {
                    let host = NWEndpoint.Host("127.0.0.1")
                    let conn = NWConnection(host: host, port: port, using: params)
                    self.configureReceive(on: conn)
                    conn.start(queue: self.queue)
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
            self.configureReceive(on: newConn)
            newConn.start(queue: self.queue)
        }
        listener?.start(queue: queue)
        ready.wait()
    }

    public func close() throws {
        connection?.cancel()
        listener?.cancel()
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
            var header = Data([0x80, 0x61, 0x00, 0x00,
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
        connection.receiveMessage { [weak self] data, _, _, _ in
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
    }

    private func startBonjourDiscovery() {
        // TODO: Advertise and browse RTP-MIDI sessions via Bonjour/mDNS
    }

    private func startMIDICINegotiation() {
        // TODO: Implement MIDI-CI negotiation handshake
    }
}
#else

public final class RTPMidiSession: MIDITransport {
    public var onReceiveUMP: (([UInt32]) -> Void)?
    public var onReceiveUmps: (([[UInt32]]) -> Void)?

    public init(localName: String, mtu: Int = 1500) {}

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
