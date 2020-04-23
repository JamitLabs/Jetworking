import XCTest
@testable import Jetworking

final class JetworkingTests: XCTestCase {
    func testExample() {
        let configuration = ClientConfiguration(baseURL: URL(string: "://")!, encoder: JSONEncoder(), decoder: JSONDecoder())
        let client = Client(clientConfiguration: configuration)

        client.get(endpoint: "") { (result: Result<String, Error>) in
            switch result {
            case .failure:
                break

            case let .success(resultData):
                print(resultData)
            }
        }
    }

    static var allTests = [
        ("testExample", testExample),
    ]
}
