import XCTest
@testable import Jetworking

final class JetworkingTests: XCTestCase {
    private struct GetResult: Codable {
        let url: String
    }

    private enum Endpoints {
        static let get: Endpoint<GetResult> = .init(pathComponent: "get")
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

    func testGetRequest() {
		let configuration = ClientConfiguration(
            baseURL: URL(string: "https://postman-echo.com")!,
            middlewareComponents: [
                AuthenticationMiddlewareComponent(authenticationMethod: .basicAuthentication(username: "username", password: "password")),
                HeaderFieldsMiddlewareComponent(
                    headerFields: [
                        "Accept": "application/json",
                        "Content-Type": "application/json"
                    ]
                )
            ],
            encoder: JSONEncoder(),
            decoder: JSONDecoder()
        )
        let client = Client(clientConfiguration: configuration)

        let expectation = self.expectation(description: "Wait for get")

        client.get(endpoint: Endpoints.get) { result in
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
        let configuration = ClientConfiguration(
            baseURL: URL(string: "https://postman-echo.com")!,
            middlewareComponents: [
                AuthenticationMiddlewareComponent(authenticationMethod: .none),
                HeaderFieldsMiddlewareComponent(
                    headerFields: [
                        "Accept": "application/json",
                        "Content-Type": "application/json"
                    ]
                )
            ],
            encoder: JSONEncoder(),
            decoder: JSONDecoder()
        )
        let client = Client(clientConfiguration: configuration)

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
        let configuration = ClientConfiguration(
            baseURL: URL(string: "https://postman-echo.com")!,
            middlewareComponents: [
                AuthenticationMiddlewareComponent(authenticationMethod: .none),
                HeaderFieldsMiddlewareComponent(
                    headerFields: [
                        "Accept": "application/json",
                        "Content-Type": "application/json"
                    ]
                )
            ],
            encoder: JSONEncoder(),
            decoder: JSONDecoder()
        )
        let client = Client(clientConfiguration: configuration)

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
        let configuration = ClientConfiguration(
            baseURL: URL(string: "https://postman-echo.com")!,
            middlewareComponents: [
                AuthenticationMiddlewareComponent(authenticationMethod: .none),
                HeaderFieldsMiddlewareComponent(
                    headerFields: [
                        "Accept": "application/json",
                        "Content-Type": "application/json"
                    ]
                )
            ],
            encoder: JSONEncoder(),
            decoder: JSONDecoder()
        )
        let client = Client(clientConfiguration: configuration)

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
        let configuration = ClientConfiguration(
            baseURL: URL(string: "https://postman-echo.com")!,
            middlewareComponents: [
                AuthenticationMiddlewareComponent(authenticationMethod: .none),
                HeaderFieldsMiddlewareComponent(
                    headerFields: [
                        "Accept": "application/json",
                        "Content-Type": "application/json"
                    ]
                )
            ],
            encoder: JSONEncoder(),
            decoder: JSONDecoder()
        )
        let client = Client(clientConfiguration: configuration)

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

    static var allTests = [
        ("testGetRequest", testGetRequest),
        ("testPostRequest", testPostRequest),
        ("testPutRequest", testPutRequest),
        ("testPatchRequest", testPatchRequest),
        ("testDeleteRequest", testDeleteRequest)
    ]
}
