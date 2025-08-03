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

    func testTodoEquality() {
        let a = Todo(id: 1, name: "A")
        let b = Todo(id: 1, name: "A")
        XCTAssertEqual(a, b)
    }

    func testTodoDecodingFailsForMissingName() {
        let json = #"{"id":1}"#.data(using: .utf8)!
        XCTAssertThrowsError(try JSONDecoder().decode(Todo.self, from: json))
    }

    /// Ensures decoding fails when the `id` field is absent.
    func testTodoDecodingFailsForMissingID() {
        let json = #"{"name":"Task"}"#.data(using: .utf8)!
        XCTAssertThrowsError(try JSONDecoder().decode(Todo.self, from: json))
    }

    func testTodosNotEqualWithDifferentID() {
        let a = Todo(id: 1, name: "A")
        let b = Todo(id: 2, name: "A")
        XCTAssertNotEqual(a, b)
    }

    func testTodoEncodingProducesExpectedJSON() throws {
        let todo = Todo(id: 7, name: "Seven")
        let encoder = JSONEncoder()
        if #available(macOS 10.13, *) {
            encoder.outputFormatting = [.sortedKeys]
        }
        let json = try encoder.encode(todo)
        let string = String(data: json, encoding: .utf8)
        XCTAssertEqual(string, "{\"id\":7,\"name\":\"Seven\"}")
    }
}


// © 2025 Contexter alias Benedikt Eickhoff 🛡️ All rights reserved.
