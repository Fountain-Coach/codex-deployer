import XCTest
@testable import FountainCore

final class FountainCoreTests: XCTestCase {
    func testTodoDecoding() throws {
        let json = #"{"id":1,"name":"Task"}"#.data(using: .utf8)!
        let todo = try JSONDecoder().decode(Todo.self, from: json)
        XCTAssertEqual(todo.id, 1)
        XCTAssertEqual(todo.name, "Task")
    }

    func testTodoEncodingRoundTrip() throws {
        let original = Todo(id: 42, name: "Answer")
        let data = try JSONEncoder().encode(original)
        let decoded = try JSONDecoder().decode(Todo.self, from: data)
        XCTAssertEqual(decoded, original)
    }
}


// © 2025 Contexter alias Benedikt Eickhoff 🛡️ All rights reserved.
