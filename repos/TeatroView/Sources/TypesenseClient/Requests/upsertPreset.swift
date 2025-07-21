import Foundation

public struct upsertPresetParameters: Codable {
    public let presetId: String
}

public struct upsertPreset: APIRequest {
    public typealias Body = PresetUpsertSchema
    public typealias Response = PresetSchema
    public var method: String { "PUT" }
    public var parameters: upsertPresetParameters
    public var path: String {
        "/presets/\(parameters.presetId)"
    }
    public var body: Body?

    public init(parameters: upsertPresetParameters, body: Body? = nil) {
        self.parameters = parameters
        self.body = body
    }
}
