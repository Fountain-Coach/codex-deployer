import Foundation
import Dispatch
import PublishingFrontend

let config = try loadPublishingConfig()
let app = PublishingFrontend(config: config)
Task { @MainActor in
    try await app.start()
}

dispatchMain()

// © 2025 Contexter alias Benedikt Eickhoff 🛡️ All rights reserved.
