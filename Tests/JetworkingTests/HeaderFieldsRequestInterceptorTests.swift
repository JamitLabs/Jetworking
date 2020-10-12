import XCTest
@testable import Jetworking

final class HeaderFieldsRequestInterceptorTests: XCTestCase {
    static var allTests = [
        ("testHeaderFields", testHeaderFields)
    ]
    
    func testHeaderFields() {
        let headerFieldsRequestInterceptor: HeaderFieldsRequestInterceptor = .init(
            headerFields: [
                "Accept": "application/json",
                "Content-Type": "application/json"
            ]
        )
        
        var request: URLRequest = .init(url: URL(string: "https://www.google.com")!)
        request = headerFieldsRequestInterceptor.intercept(request)
        
        XCTAssert(((request.allHTTPHeaderFields?.contains(where: { $0.key == "Accept" && $0.value == "application/json" })) != nil))
        XCTAssert(((request.allHTTPHeaderFields?.contains(where: { $0.key == "Content-Type" && $0.value == "application/json" })) != nil))
    }
}
