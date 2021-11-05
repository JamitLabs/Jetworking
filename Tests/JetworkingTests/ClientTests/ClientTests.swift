import XCTest
import Foundation
@testable import Jetworking

final class ClientTests: XCTestCase {
    var defaultSession: URLSession = {
        var session = URLSession(configuration: .default)
        session.configuration.timeoutIntervalForRequest = 30
        return session
    }()

    override func setUp() {
        super.setUp()

        MockExecuter.responseCodeForRequest = { request in
            switch request.url?.absoluteString {
            case .some("https://www.jamitlabs.com/somePathClientError"):
                return 403

            case .some("https://www.jamitlabs.com/somePathServerError"):
                return 500

            default:
                return 200
            }
        }
    }

    func testGetRequest() {
        let client = Client(configuration: Configurations.default(), session: defaultSession)
        let expectation = self.expectation(description: "Wait for get")

        client.get(endpoint: Endpoints.get.addQueryParameter(key: "SomeKey", value: "SomeValue")) { response, result in

            dispatchPrecondition(condition: .onQueue(DispatchQueue.main))
            switch result {
            case .failure:
                XCTFail("Request should not result in failure!")

            case let .success(resultData):
                XCTAssertEqual(MockBody(foo1: "SomeFoo", foo2: "AnotherFoo"), resultData)
            }

            XCTAssertNotNil(response)
            XCTAssertEqual(response?.statusCode, 200)
            expectation.fulfill()
        }

        waitForExpectations(timeout: 5.0, handler: nil)
    }

    func testPostRequest() {
        let client = Client(configuration: Configurations.default())
        let expectation = self.expectation(description: "Wait for post")

        let body: MockBody = .init(foo1: "bar1", foo2: "bar2")
        client.post(endpoint: Endpoints.post, body: body) { response, result in
            dispatchPrecondition(condition: .onQueue(DispatchQueue.main))
            switch result {
            case .failure:
                XCTFail("Request should not result in failure!")

            case let .success(resultData):
                XCTAssertNotNil(resultData)
            }

            XCTAssertNotNil(response)
            XCTAssertEqual(response?.statusCode, 200)
            expectation.fulfill()
        }

        waitForExpectations(timeout: 5.0, handler: nil)
    }

    func testPostRequestWithEmptyContent() {
        let client = Client(configuration: Configurations.default())
        let expectation = self.expectation(description: "Wait for post with empty content")

        client.post(endpoint: Endpoints.voidPost) { response, result in
            dispatchPrecondition(condition: .onQueue(DispatchQueue.main))
            switch result {
            case .failure:
                XCTFail("Request should not result in failure!")

            case let .success(resultData):
                XCTAssertNotNil(resultData)
            }

            XCTAssertNotNil(response)
            XCTAssertEqual(response?.statusCode, 200)
            expectation.fulfill()
        }

        waitForExpectations(timeout: 5.0, handler: nil)
    }

    func testPutRequest() {
        let client = Client(configuration: Configurations.default())
        let expectation = self.expectation(description: "Wait for post")

        let body: MockBody = .init(foo1: "bar1", foo2: "bar2")
        client.put(endpoint: Endpoints.put, body: body) { response, result in
            dispatchPrecondition(condition: .onQueue(DispatchQueue.main))
            switch result {
            case .failure:
                XCTFail("Request should not result in failure!")

            case let .success(resultData):
                XCTAssertNotNil(resultData)
            }

            XCTAssertNotNil(response)
            XCTAssertEqual(response?.statusCode, 200)
            expectation.fulfill()
        }

        waitForExpectations(timeout: 5.0, handler: nil)
    }

    func testPatchRequest() {
        let client = Client(configuration: Configurations.default())
        let expectation = self.expectation(description: "Wait for post")

        let body: MockBody = .init(foo1: "bar1", foo2: "bar2")
        client.patch(endpoint: Endpoints.patch, body: body) { response, result in
            dispatchPrecondition(condition: .onQueue(DispatchQueue.main))
            switch result {
            case .failure:
                XCTFail("Request should not result in failure!")

            case let .success(resultData):
                XCTAssertNotNil(resultData)
            }

            XCTAssertNotNil(response)
            XCTAssertEqual(response?.statusCode, 200)
            expectation.fulfill()
        }

        waitForExpectations(timeout: 5.0, handler: nil)
    }

    func testDeleteRequest() {
        let client = Client(configuration: Configurations.default())

        let expectation = self.expectation(description: "Wait for post")

        client.delete(endpoint: Endpoints.delete) { response, result in
            dispatchPrecondition(condition: .onQueue(DispatchQueue.main))
            switch result {
            case .failure:
                XCTFail("Request should not result in failure!")

            case let .success(resultData):
                XCTAssertNotNil(resultData)
            }

            XCTAssertNotNil(response)
            XCTAssertEqual(response?.statusCode, 200)
            expectation.fulfill()
        }

        waitForExpectations(timeout: 5.0, handler: nil)
    }

    func testExternalRequest() {
        let defaultConfiguration = Configurations.default()
        let client = Client(configuration: defaultConfiguration)

        let expectation = self.expectation(description: "Wait for an external request")

        let url = try? URLFactory.makeURL(from: Endpoints.delete, withBaseURL: defaultConfiguration.baseURLProvider.baseURL)
        guard let targetURL = url else {
            XCTFail("URL not available")
            return
        }

        var request = URLRequest(url: targetURL, httpMethod: .DELETE)
        request = defaultConfiguration.interceptors.reduce(request) { $1.intercept($0) }

        client.send(request: request) { (data: Data?, response: URLResponse?, error: Error?) -> Void in
            XCTAssertNotNil(response)
            if let httpUrlResponse = response as? HTTPURLResponse {
                XCTAssertEqual(httpUrlResponse.statusCode, 200)
            }

            expectation.fulfill()
        }

        waitForExpectations(timeout: 5.0, handler: nil)
    }

    func testPostRequestWithRequestWithServerError() {
        let client = Client(configuration: Configurations.default())

        let expectation = self.expectation(description: "Wait for post with empty content")
        client.post(endpoint: Endpoints.voidPostServerError) { response, result in
            dispatchPrecondition(condition: .onQueue(DispatchQueue.main))

            switch result {
            case .failure(APIError.serverError(statusCode: 500, error: _, body: _)):
                XCTAssertNotNil(response)
                XCTAssertEqual(response?.statusCode, 500)
                expectation.fulfill()

            case .failure:
                XCTFail("Request should not result in failure without status code 500!")

            case .success:
                XCTFail("Request should not result in success!")
            }
        }

        waitForExpectations(timeout: 5.0, handler: nil)
    }

    func testPostRequestWithRequestWithClientError() {
        let client = Client(configuration: Configurations.default())
        let expectation = self.expectation(description: "Wait for post with empty content")
        client.post(endpoint: Endpoints.voidPostClientError) { response, result in
            dispatchPrecondition(condition: .onQueue(DispatchQueue.main))

            switch result {
            case .failure(APIError.clientError(statusCode: 403, error: _, body: _)):
                XCTAssertNotNil(response)
                XCTAssertEqual(response?.statusCode, 403)
                expectation.fulfill()

            case .failure:
                XCTFail("Request should not result in failure without 403 status code!")

            case .success:
                XCTFail("Request should not result in succes!")
            }
        }

        waitForExpectations(timeout: 5.0, handler: nil)
    }

    func testRequestCancellation() throws {
        let client = Client(configuration: Configurations.default())
        let expectation = self.expectation(description: "Wait for get")

        let cancellableRequest = client.get(
            endpoint: Endpoints.get.addQueryParameter(key: "SomeKey", value: "SomeValue")
        ) { response, result in
            dispatchPrecondition(condition: .onQueue(DispatchQueue.main))
            XCTAssertNil(response)

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

    func testCustomEncoder() {
        let testableEncoder = TestableEncoder()
        let client = Client(configuration: Configurations.default())

        let postEncodingCalledExpectation = expectation(description: "Encoder method called for post")
        let putEncodingCalledExpectation = expectation(description: "Encoder method called for put")
        let patchEncodingCalledExpectation = expectation(description: "Encoder method called for patch")

        let waitForPostExpectation = expectation(description: "Wait for post")
        let waitForPutExpectation = expectation(description: "Wait for put")
        let waitForPatchExpectation = expectation(description: "Wait for patch")

        testableEncoder.encodeCalled = {
            postEncodingCalledExpectation.fulfill()
        }

        let body: MockBody = .init(foo1: "bar1", foo2: "bar2")
        client.post(endpoint: Endpoints.post.withCustomEncoder(testableEncoder), body: body) { response, result in
            dispatchPrecondition(condition: .onQueue(DispatchQueue.main))
            switch result {
            case .failure:
                break

            case let .success(resultData):
                print(resultData)
            }

            XCTAssertNotNil(response)
            XCTAssertEqual(response?.statusCode, 200)
            waitForPostExpectation.fulfill()
        }

        testableEncoder.encodeCalled = {
            putEncodingCalledExpectation.fulfill()
        }

        client.put(endpoint: Endpoints.put.withCustomEncoder(testableEncoder), body: body) { response, result in
            dispatchPrecondition(condition: .onQueue(DispatchQueue.main))
            switch result {
            case .failure:
                break

            case let .success(resultData):
                print(resultData)
            }

            XCTAssertNotNil(response)
            XCTAssertEqual(response?.statusCode, 200)
            waitForPutExpectation.fulfill()
        }

        testableEncoder.encodeCalled = {
            patchEncodingCalledExpectation.fulfill()
        }

        client.patch(endpoint: Endpoints.patch.withCustomEncoder(testableEncoder), body: body) { response, result in
            dispatchPrecondition(condition: .onQueue(DispatchQueue.main))
            switch result {
            case .failure:
                break

            case let .success(resultData):
                print(resultData)
            }

            XCTAssertNotNil(response)
            XCTAssertEqual(response?.statusCode, 200)
            waitForPatchExpectation.fulfill()
        }

        waitForExpectations(timeout: 5.0, handler: nil)
    }
}
