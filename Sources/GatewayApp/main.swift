import Foundation

import Dispatch

let server = GatewayServer()
Task { @MainActor in
    try await server.start(port: 8080)
}

dispatchMain()

// © 2025 Contexter alias Benedikt Eickhoff 🛡️ All rights reserved.
