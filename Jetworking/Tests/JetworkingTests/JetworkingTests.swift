import XCTest
@testable import Jetworking

final class JetworkingTests: XCTestCase {
    func testExample() {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct
        // results.
        XCTAssertEqual(Jetworking().text, "Hello, World!")
    }

    static var allTests = [
        ("testExample", testExample),
    ]
}
