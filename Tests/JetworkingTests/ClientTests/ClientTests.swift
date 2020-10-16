import XCTest
@testable import Jetworking

final class ClientTests: XCTestCase {
    func additionalHeaderFields() -> [String: String] {
        return [
            "Accept": "application/json",
            "Content-Type": "application/json"
        ]
    }

    func testGetRequest() {
        let client = Client(configuration: makeDefaultClientConfiguration()) { session in
            session.configuration.timeoutIntervalForRequest = 30
        }

        let expectation = self.expectation(description: "Wait for get")

        client.get(endpoint: Endpoints.get.addQueryParameter(key: "SomeKey", value: "SomeValue")) { result in
            switch result {
            case .failure:
                break

            case let .success(resultData):
                print(resultData)
            }

            expectation.fulfill()
        }

        waitForExpectations(timeout: 5.0, handler: nil) 
    }

    func testPostRequest() {
        let client = Client(configuration: makeDefaultClientConfiguration())
        let expectation = self.expectation(description: "Wait for post")

        let body: MockBody = .init(foo1: "bar1", foo2: "bar2")
        client.post(endpoint: Endpoints.post, body: body) { result in
            switch result {
            case .failure:
                break

            case let .success(resultData):
                print(resultData)
            }

            expectation.fulfill()
        }

        waitForExpectations(timeout: 5.0, handler: nil)
    }

    func testPutRequest() {
        let client = Client(configuration: makeDefaultClientConfiguration())
        let expectation = self.expectation(description: "Wait for post")

        let body: MockBody = .init(foo1: "bar1", foo2: "bar2")
        client.put(endpoint: Endpoints.put, body: body) { result in
            switch result {
            case .failure:
                break

            case let .success(resultData):
                print(resultData)
            }

            expectation.fulfill()
        }

        waitForExpectations(timeout: 5.0, handler: nil)
    }

    func testPatchRequest() {
        let client = Client(configuration: makeDefaultClientConfiguration())
        let expectation = self.expectation(description: "Wait for post")

        let body: MockBody = .init(foo1: "bar1", foo2: "bar2")
        client.patch(endpoint: Endpoints.patch, body: body) { result in
            switch result {
            case .failure:
                break

            case let .success(resultData):
                print(resultData)
            }

            expectation.fulfill()
        }

        waitForExpectations(timeout: 5.0, handler: nil)
    }
    
    func testDeleteRequest() {
        let client = Client(configuration: makeDefaultClientConfiguration())

        let expectation = self.expectation(description: "Wait for post")

        client.delete(endpoint: Endpoints.delete) { result in
            switch result {
            case .failure:
                break

            case let .success(resultData):
                print(resultData)
            }

            expectation.fulfill()
        }

        waitForExpectations(timeout: 5.0, handler: nil)
    }

    func testRequestCancellation() throws {
        let client = Client(configuration: makeDefaultClientConfiguration())
        let expectation = self.expectation(description: "Wait for get")

        let cancellableRequest = client.get(endpoint: Endpoints.get.addQueryParameter(key: "SomeKey", value: "SomeValue")) { result in
            switch result {
            case let .failure(error as URLError):
                XCTAssertEqual(error.code, URLError.cancelled)

            case .failure:
                XCTFail("Should not executed since error should be URLError")

            case .success:
                XCTFail("Should not succeed due to cancellation")
            }

            expectation.fulfill()
        }

        cancellableRequest?.cancel()

        waitForExpectations(timeout: 5.0, handler: nil)
    }

    func testSequentialRequestsCorrectOrder() {
        let client = Client(configuration: .init(
            baseURL: URL(string: "https://postman-echo.com")!,
            requestInterceptors: [
                AuthenticationRequestInterceptor(
                    authenticationMethod: .basicAuthentication(username: "username", password: "password")
                ),
                HeaderFieldsRequestInterceptor(headerFields: self.additionalHeaderFields()),
                LoggingRequestInterceptor()
            ],
            responseInterceptors: [
                LoggingResponseInterceptor()
            ],
            encoder: JSONEncoder(),
            decoder: JSONDecoder(),
            requestExecutorType: .sync
        ))

        let firstExpectation = expectation(description: "Wait for first get")
        let secondExpectation = expectation(description: "Wait for second get")
        let thirdExpectation = expectation(description: "Wait for third get")
        let fourthExpectation = expectation(description: "Wait for fourth get")

        client.get(endpoint: Endpoints.get) { _ in firstExpectation.fulfill() }
        client.get(endpoint: Endpoints.get) { _ in secondExpectation.fulfill() }
        client.get(endpoint: Endpoints.get) { _ in thirdExpectation.fulfill() }
        client.get(endpoint: Endpoints.get) { _ in fourthExpectation.fulfill() }

        let result = XCTWaiter().wait(
            for: [firstExpectation, secondExpectation, thirdExpectation, fourthExpectation],
            timeout: 20,
            enforceOrder: true
        )

        XCTAssertTrue(result == .completed)
    }
    
    func testIncorrectOrderDueToAsyncRequestExecutor() {
        let client = Client(configuration: makeDefaultClientConfiguration())

        let firstExpectation = expectation(description: "Wait for first get")
        let secondExpectation = expectation(description: "Wait for second get")
        let thirdExpectation = expectation(description: "Wait for third get")
        let fourthExpectation = expectation(description: "Wait for fourth get")

        client.get(endpoint: Endpoints.get) { _ in firstExpectation.fulfill() }
        client.get(endpoint: Endpoints.get) { _ in secondExpectation.fulfill() }
        client.get(endpoint: Endpoints.get) { _ in thirdExpectation.fulfill() }
        client.get(endpoint: Endpoints.get) { _ in fourthExpectation.fulfill() }

        let result = XCTWaiter().wait(
            for: [firstExpectation, secondExpectation, thirdExpectation, fourthExpectation],
            timeout: 20,
            enforceOrder: true
        )

        XCTAssertTrue(result == .incorrectOrder)
    }
}

extension ClientTests {
    func makeDefaultClientConfiguration() -> Configuration {
        return .init(
            baseURL: URL(string: "https://postman-echo.com")!,
            requestInterceptors: [
                AuthenticationRequestInterceptor(
                    authenticationMethod: .basicAuthentication(username: "username", password: "password")
                ),
                HeaderFieldsRequestInterceptor(headerFields: self.additionalHeaderFields()),
                LoggingRequestInterceptor()
            ],
            responseInterceptors: [
                LoggingResponseInterceptor()
            ],
            encoder: JSONEncoder(),
            decoder: JSONDecoder(),
            requestExecutorType: .async
        )
    }
}
