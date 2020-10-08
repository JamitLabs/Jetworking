import XCTest
@testable import Jetworking

final class JetworkingTests: XCTestCase {
    private struct GetResult: Codable {
        let url: String
    }

    func testExample() {
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

    static var allTests = [
        ("testExample", testExample),
    ]
}
