import XCTest
#if canImport(SwiftUI) && canImport(WebKit)
@testable import TeatroPreviewUI

final class TeatroPreviewUITests: XCTestCase {
    func testInit() {
        let view = AnimatedSVGPreview(svg: "<svg></svg>")
        XCTAssertNotNil(view)
    }
}
#endif
