import Foundation

public struct OpenAPISpec: Codable {
    /// Components container storing reusable objects.
    public struct Components: Codable {
        public var schemas: [String: Schema]
        public var securitySchemes: [String: SecurityScheme]?
    }

    /// Top-level server description.
    public struct Server: Codable {
        public var url: String
        public var description: String?
    }

    /// Supported authentication scheme.
    public struct SecurityScheme: Codable {
        public var type: String
        public var scheme: String?
        public var name: String?
        public var location: String?

        enum CodingKeys: String, CodingKey {
            case type, scheme, name
            case location = "in"
        }
    }

    /// Security requirements applied to an operation.
    public struct SecurityRequirement: Codable {
        public var schemes: [String: [String]]

        public init(from decoder: Decoder) throws {
            let container = try decoder.singleValueContainer()
            schemes = try container.decode([String: [String]].self)
        }

        public func encode(to encoder: Encoder) throws {
            var container = encoder.singleValueContainer()
            try container.encode(schemes)
        }
    }

    /// Basic JSON Schema representation used throughout the spec.
    public final class Schema: Codable {
        public final class Property: Codable {
            public var ref: String?
            public var type: String?
            public var enumValues: [String]?
            public var items: Schema?
            public var allOf: [Schema]?
            public var oneOf: [Schema]?
            public var additionalProperties: Schema?

            enum CodingKeys: String, CodingKey {
                case ref = "$ref"
                case type
                case enumValues = "enum"
                case items
                case allOf
                case oneOf
                case additionalProperties
            }

            public init(from decoder: Decoder) throws {
                let container = try decoder.container(keyedBy: CodingKeys.self)
                ref = try container.decodeIfPresent(String.self, forKey: .ref)
                type = try container.decodeIfPresent(String.self, forKey: .type)
                enumValues = try container.decodeIfPresent([String].self, forKey: .enumValues)
                items = try container.decodeIfPresent(Schema.self, forKey: .items)
                allOf = try container.decodeIfPresent([Schema].self, forKey: .allOf)
                oneOf = try container.decodeIfPresent([Schema].self, forKey: .oneOf)
                if let bool = try? container.decode(Bool.self, forKey: .additionalProperties) {
                    additionalProperties = bool ? Schema() : nil
                } else {
                    additionalProperties = try container.decodeIfPresent(Schema.self, forKey: .additionalProperties)
                }
            }

            public init() {}
        }

        public var ref: String?
        public var type: String?
        public var properties: [String: Property]?
        public var enumValues: [String]?
        public var items: Schema?
        public var allOf: [Schema]?
        public var oneOf: [Schema]?
        public var additionalProperties: Schema?

        enum CodingKeys: String, CodingKey {
            case ref = "$ref"
            case type
            case properties
            case enumValues = "enum"
            case items
            case allOf
            case oneOf
            case additionalProperties
        }

        public init(from decoder: Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)
            ref = try container.decodeIfPresent(String.self, forKey: .ref)
            type = try container.decodeIfPresent(String.self, forKey: .type)
            properties = try container.decodeIfPresent([String: Property].self, forKey: .properties)
            enumValues = try container.decodeIfPresent([String].self, forKey: .enumValues)
            items = try container.decodeIfPresent(Schema.self, forKey: .items)
            allOf = try container.decodeIfPresent([Schema].self, forKey: .allOf)
            oneOf = try container.decodeIfPresent([Schema].self, forKey: .oneOf)
            if let bool = try? container.decode(Bool.self, forKey: .additionalProperties) {
                additionalProperties = bool ? Schema() : nil
            } else {
                additionalProperties = try container.decodeIfPresent(Schema.self, forKey: .additionalProperties)
            }
        }

        public init() {}
    }

    /// Parameter object representing path or query parameters.
    public struct Parameter: Codable {
        public var name: String
        public var location: String
        public var required: Bool?
        public var schema: Schema?

        enum CodingKeys: String, CodingKey {
            case name
            case location = "in"
            case required
            case schema
        }
    }

    /// Media type containing a schema.
    public struct MediaType: Codable {
        public var schema: Schema?
    }

    /// Request body container.
    public struct RequestBody: Codable {
        public var content: [String: MediaType]
    }

    /// Response object keyed by status code.
    public struct Response: Codable {
        public var description: String?
        public var content: [String: MediaType]?
    }

    /// Operation including parameters, request body and responses.
    public struct Operation: Codable {
        public var operationId: String
        public var parameters: [Parameter]?
        public var requestBody: RequestBody?
        public var responses: [String: Response]?
        public var security: [SecurityRequirement]?
    }

    /// Path item grouping multiple HTTP methods.
    public struct PathItem: Codable {
        public var get: Operation?
        public var post: Operation?
        public var put: Operation?
        public var delete: Operation?
    }

    public let title: String
    public var servers: [Server]?
    public var components: Components?
    public var paths: [String: PathItem]?
}

extension OpenAPISpec.Schema.Property {
    public var swiftType: String {
        if let ref {
            return ref.components(separatedBy: "/").last ?? ref
        }
        if let first = allOf?.first ?? oneOf?.first {
            return first.swiftType
        }
        guard let type else { return "String" }
        switch type {
        case "string": return "String"
        case "integer": return "Int"
        case "boolean": return "Bool"
        case "array":
            if let itemType = items?.swiftType {
                return "[\(itemType)]"
            } else {
                return "[String]"
            }
        case "object":
            if let additional = additionalProperties {
                return "[String: \(additional.swiftType)]"
            }
            return "[String: String]"
        default: return "String"
        }
    }
}

extension OpenAPISpec.Schema {
    public var swiftType: String {
        if let ref {
            return ref.components(separatedBy: "/").last ?? ref
        }
        if let first = allOf?.first ?? oneOf?.first {
            return first.swiftType
        }
        guard let type else { return "String" }
        switch type {
        case "string": return "String"
        case "integer": return "Int"
        case "boolean": return "Bool"
        case "array":
            if let itemType = items?.swiftType {
                return "[\(itemType)]"
            } else {
                return "[String]"
            }
        case "object":
            if let additional = additionalProperties {
                return "[String: \(additional.swiftType)]"
            }
            return "[String: String]"
        default: return "String"
        }
    }
}

extension OpenAPISpec.Parameter {
    /// Swift identifier-safe name for the parameter.
    public var swiftName: String {
        name.replacingOccurrences(of: "-", with: "_")
    }

    /// Swift type inferred from the associated schema, defaulting to `String`.
    public var swiftType: String {
        schema?.swiftType ?? "String"
    }
}

// © 2025 Contexter alias Benedikt Eickhoff 🛡️ All rights reserved.
