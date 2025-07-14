import XCTest
@testable import Teatro

final class RendererTests: XCTestCase {
    func testHTMLRenderer() {
        let text = Text("Hi")
        let html = HTMLRenderer.render(text)
        XCTAssertTrue(html.contains("<pre>\nHi\n</pre>"))
    }

    func testSVGRenderer() {
        let text = Text("Hi")
        let svg = SVGRenderer.render(text)
        XCTAssertTrue(svg.contains("<svg"))
        XCTAssertTrue(svg.contains("Hi"))
    }
}
