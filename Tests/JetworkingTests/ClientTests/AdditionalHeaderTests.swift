import Foundation
import XCTest
import Foundation
@testable import Jetworking

final class AdditionalHeaderTests: XCTestCase {
    let testHeader: [String: String] = ["SomeHeaderKey": "SomeHeaderValue"]
    var defaultSession: URLSession = {
        var session = URLSession(configuration: .default)
        session.configuration.timeoutIntervalForRequest = 30
        return session
    }()

    override class func tearDown() {
        super.tearDown()

        MockExecuter.validateHeaderFields = nil
    }

    func testAdditionalHeadersForGet() {
        let client = Client(configuration: Configurations.default(), session: defaultSession)
        let validatedHeaders = self.expectation(description: "Headers are validated")
        MockExecuter.validateHeaderFields = { [unowned self] requestHeaders in
            self.testHeader.forEach { headerEntry in
                XCTAssertEqual(requestHeaders?[headerEntry.key], headerEntry.value)
            }

            validatedHeaders.fulfill()
        }

        let expectation = self.expectation(description: "Wait for get")
        client.get(
            endpoint: Endpoints.get.addQueryParameter(key: "SomeKey", value: "SomeValue"),
            andAdditionalHeaderFields: testHeader
        ) { response, result in
            switch result {
            case .failure:
                XCTFail("Request should not result in failure!")

            case let .success(resultData):
                XCTAssertEqual(MockBody(foo1: "SomeFoo", foo2: "AnotherFoo"), resultData)
            }

            expectation.fulfill()
        }

        wait(for: [expectation, validatedHeaders], timeout: 2)
    }

    func testAdditionalHeadersShouldBeMergedWithGlobalOnes() {
        let globalHeaderFields: [String: String] = ["GlobalHeaderKey": "GlobalHeaderValue"]
        let configuration: Configuration = Configurations.default(globalHeaderFields: globalHeaderFields)
        let client = Client(configuration: configuration, session: defaultSession)

        let validatedHeaders = self.expectation(description: "Headers are validated")

        let mergedHeaders: [String: String] = globalHeaderFields.merging(testHeader) { lhs, rhs in
            // Merging of header values is switched in URLRequest
            return [rhs, lhs].joined(separator: ",")
        }

        MockExecuter.validateHeaderFields = { requestHeaders in
            mergedHeaders.forEach { headerEntry in
                XCTAssertEqual(requestHeaders?[headerEntry.key], headerEntry.value)
            }

            validatedHeaders.fulfill()
        }

        let expectation = self.expectation(description: "Wait for get")
        client.get(
            endpoint: Endpoints.get.addQueryParameter(key: "SomeKey", value: "SomeValue"),
            andAdditionalHeaderFields: testHeader
        ) { response, result in
            switch result {
            case .failure:
                XCTFail("Request should not result in failure!")

            case let .success(resultData):
                XCTAssertEqual(MockBody(foo1: "SomeFoo", foo2: "AnotherFoo"), resultData)
            }

            expectation.fulfill()
        }

        wait(for: [expectation, validatedHeaders], timeout: 2)
    }

    func testAdditionalHeadersShouldBeMergedWithGlobalJoinedKeys() {
        let globalHeaderFields: [String: String] = ["SomeHeaderKey": "GlobalHeaderValue"]
        let configuration: Configuration = Configurations.default(globalHeaderFields: globalHeaderFields)
        let client = Client(configuration: configuration, session: defaultSession)

        let validatedHeaders = self.expectation(description: "Headers are validated")

        let mergedHeaders: [String: String] = globalHeaderFields.merging(testHeader) { lhs, rhs in
            // Merging of header values is switched in URLRequest
            return [rhs, lhs].joined(separator: ",")
        }

        MockExecuter.validateHeaderFields = { requestHeaders in
            mergedHeaders.forEach { headerEntry in
                XCTAssertEqual(requestHeaders?[headerEntry.key], headerEntry.value)
            }

            validatedHeaders.fulfill()
        }

        let expectation = self.expectation(description: "Wait for get")
        client.get(
            endpoint: Endpoints.get.addQueryParameter(key: "SomeKey", value: "SomeValue"),
            andAdditionalHeaderFields: testHeader
        ) { response, result in
            switch result {
            case .failure:
                XCTFail("Request should not result in failure!")

            case let .success(resultData):
                XCTAssertEqual(MockBody(foo1: "SomeFoo", foo2: "AnotherFoo"), resultData)
            }

            expectation.fulfill()
        }

        wait(for: [expectation, validatedHeaders], timeout: 2)
    }
}
