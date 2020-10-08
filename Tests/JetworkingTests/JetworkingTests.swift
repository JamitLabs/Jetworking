import XCTest
@testable import Jetworking

final class JetworkingTests: XCTestCase {
    private struct GetResult: Codable {
        let url: String
    }

    private struct Body: Codable {
        let foo1: String
        let foo2: String
    }

    private struct VoidResult: Codable {}

    func testGetRequest() {
		let configuration = ClientConfiguration(
            baseURL: URL(string: "https://postman-echo.com")!,
            authenticationMethod: .basicAuthentication(username: "username", password: "password"),
            encoder: JSONEncoder(),
            decoder: JSONDecoder()
        )
        let client = Client(clientConfiguration: configuration)

        let expectation = self.expectation(description: "Wait for get")

        client.get(endpoint: "get") { (result: Result<GetResult, Error>) in
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
        let configuration = ClientConfiguration(baseURL: URL(string: "https://postman-echo.com")!, authenticationMethod: .none, encoder: JSONEncoder(), decoder: JSONDecoder())
        let client = Client(clientConfiguration: configuration)

        let expectation = self.expectation(description: "Wait for post")

        let body: Body = .init(foo1: "bar1", foo2: "bar2")
        client.post(endpoint: "post", body: body) { (result: Result<VoidResult, Error>) in
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
        let configuration = ClientConfiguration(baseURL: URL(string: "https://postman-echo.com")!, authenticationMethod: .none, encoder: JSONEncoder(), decoder: JSONDecoder())
        let client = Client(clientConfiguration: configuration)

        let expectation = self.expectation(description: "Wait for post")

        let body: Body = .init(foo1: "bar1", foo2: "bar2")
        client.put(endpoint: "put", body: body) { (result: Result<VoidResult, Error>) in
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
        let configuration = ClientConfiguration(baseURL: URL(string: "https://postman-echo.com")!, authenticationMethod: .none, encoder: JSONEncoder(), decoder: JSONDecoder())
        let client = Client(clientConfiguration: configuration)

        let expectation = self.expectation(description: "Wait for post")

        let body: Body = .init(foo1: "bar1", foo2: "bar2")
        client.patch(endpoint: "patch", body: body) { (result: Result<VoidResult, Error>) in
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
        let configuration = ClientConfiguration(baseURL: URL(string: "https://postman-echo.com")!, authenticationMethod: .none, encoder: JSONEncoder(), decoder: JSONDecoder())
        let client = Client(clientConfiguration: configuration)

        let expectation = self.expectation(description: "Wait for post")

        client.delete(endpoint: "delete") { (result: Result<VoidResult, Error>) in
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
