import XCTest
@testable import FountainCodex

final class NormativeLinkerTests: XCTestCase {
    func testEntityRegistryHandlesConflicts() {
        var registry = EntityRegistry()
        let entity = Entity(name: "MSG001", type: .messageID, definition: "First message")
        registry.register(entity)
        registry.register(entity) // duplicate identical definition
        XCTAssertNil(registry.conflicts(for: "MSG001"))

        let conflicting = Entity(name: "MSG001", type: .messageID, definition: "Different")
        registry.register(conflicting)
        let conflicts = registry.conflicts(for: "MSG001")
        XCTAssertNotNil(conflicts)
        XCTAssertEqual(conflicts?.count, 2)
    }

    func testLinkerMatchesEntitiesInTextAndTables() {
        let entities = [
            Entity(name: "MSG001", type: .messageID, definition: "First"),
            Entity(name: "temperature", type: .term, definition: "Ambient")
        ]
        let sections = [
            NormativeSection(id: "1", text: "Use message MSG001 to initiate."),
            NormativeSection(id: "2", text: "", table: [["Name", "Description"], ["temperature", "Ambient temperature"]])
        ]
        let links = NormativeLinker.link(sections: sections, entities: entities)
        XCTAssertEqual(links.count, 2)
        let section1 = links.first { $0.section.id == "1" }
        XCTAssertEqual(section1?.entities.first?.name, "MSG001")
        let section2 = links.first { $0.section.id == "2" }
        XCTAssertEqual(section2?.entities.first?.name, "temperature")
    }
}

// © 2025 Contexter alias Benedikt Eickhoff 🛡️ All rights reserved.
