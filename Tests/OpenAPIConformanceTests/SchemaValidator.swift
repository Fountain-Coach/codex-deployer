import Foundation

struct OpenAPISchemaValidator {
    enum SchemaType: String { case string, integer, boolean, object, array }

    static func validate(object: Any, against schema: [String: Any]) -> Bool {
        guard let typeStr = schema["type"] as? String, let type = SchemaType(rawValue: typeStr) else { return true }
        switch type {
        case .string:
            return object is String
        case .integer:
            return object is Int || object is Int32 || object is Int64
        case .boolean:
            return object is Bool
        case .object:
            guard let obj = object as? [String: Any] else { return false }
            let required = schema["required"] as? [String] ?? []
            for key in required { if obj[key] == nil { return false } }
            if let props = schema["properties"] as? [String: Any] {
                for (k, v) in props {
                    guard let sub = v as? [String: Any], let val = obj[k] else { continue }
                    if !validate(object: val, against: sub) { return false }
                }
            }
            return true
        case .array:
            guard let arr = object as? [Any] else { return false }
            if let items = schema["items"] as? [String: Any] {
                for el in arr { if !validate(object: el, against: items) { return false } }
            }
            return true
        }
    }
}

