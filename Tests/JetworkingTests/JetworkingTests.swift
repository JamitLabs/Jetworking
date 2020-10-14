import XCTest
@testable import Jetworking

final class JetworkingTests: XCTestCase {
    private struct GetResult: Codable {
        let url: String
    }

    private enum Endpoints {
        static var get: Endpoint<GetResult> = .init(pathComponent: "get")
        static let post: Endpoint<VoidResult> = .init(pathComponent: "post")
        static let patch: Endpoint<VoidResult> = .init(pathComponent: "patch")
        static let put: Endpoint<VoidResult> = .init(pathComponent: "put")
        static let delete: Endpoint<VoidResult> = .init(pathComponent: "delete")
    }

    private struct Body: Codable {
        let foo1: String
        let foo2: String
    }

    private struct VoidResult: Codable {}
    
    func getAuthenticationMethod() -> AuthenticationRequestInterceptor.AuthenticationMethod {
        return .basicAuthentication(username: "username", password: "password")
    }
    
    func getHeaderFields() -> [String: String] {
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
                print(resultData.url)
            }

            expectation.fulfill()
        }

        waitForExpectations(timeout: 5.0, handler: nil) 
    }

    func testPostRequest() {
        let client = Client(configuration: makeDefaultClientConfiguration())
        let expectation = self.expectation(description: "Wait for post")

        let body: Body = .init(foo1: "bar1", foo2: "bar2")
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

        let body: Body = .init(foo1: "bar1", foo2: "bar2")
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

        let body: Body = .init(foo1: "bar1", foo2: "bar2")
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

    static var allTests = [
        ("testGetRequest", testGetRequest),
        ("testPostRequest", testPostRequest),
        ("testPutRequest", testPutRequest),
        ("testPatchRequest", testPatchRequest),
        ("testDeleteRequest", testDeleteRequest)
    ]
}

extension JetworkingTests {
    func makeDefaultClientConfiguration() -> Configuration {
        return .init(
            baseURL: URL(string: "https://postman-echo.com")!,
            requestInterceptors: [
                AuthenticationRequestInterceptor(authenticationMethod: .none),
                HeaderFieldsRequestInterceptor(headerFields: self.getHeaderFields()),
                LoggingRequestInterceptor()
            ],
            responseInterceptors: [
                LoggingResponseInterceptor()
            ],
            encoder: JSONEncoder(),
            decoder: JSONDecoder()
        )
    }
}
