import Foundation

enum CollisionResolver {
    static func resolve(_ api: OpenAPI) -> (OpenAPI, [String]) {
        var seen: Set<String> = []
        var collisions: [String] = []
        var result: [String] = []
        for name in api.operations {
            var candidate = name
            var counter = 1
            while seen.contains(candidate) {
                collisions.append(name)
                candidate = "\(name)_\(counter)"
                counter += 1
            }
            seen.insert(candidate)
            result.append(candidate)
        }
        return (OpenAPI(operations: result), collisions)
    }
}
