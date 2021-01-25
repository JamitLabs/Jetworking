import Foundation
@testable import Jetworking
import XCTest

class SyncRequestExecuterTests: XCTestCase {
    var session: URLSession {
        let configuration = URLSessionConfiguration.default
        configuration.protocolClasses = [MockURLProtocol.self]
        return URLSession.init(configuration: configuration)
    }

    func testOrderDueToAsyncRequestExecuter() {
        let requestExecuter: SyncRequestExecutor = .init(session: session)
        let firstTestPath: String = "https://www.jamitlabs.com/somePath0"
        let secondTestPath: String = "https://www.jamitlabs.com/somePath1"
        let thirdTestPath: String = "https://www.jamitlabs.com/somePath2"
        let fourthTestPath: String = "https://www.jamitlabs.com/somePath3"

        MockURLProtocol.requestHandler = { request in
            let waitTime: [String: TimeInterval] = [
                firstTestPath: 2,
                secondTestPath: 0,
                thirdTestPath: 3,
                fourthTestPath: 1
            ]
            guard
                let url = request.url,
                let timeToWait = waitTime[url.absoluteString]
            else {
                throw MockURLProtocol.MockError.invalidConfiguration
            }

            let response: HTTPURLResponse = HTTPURLResponse(
                url: url,
                statusCode: 200,
                httpVersion: nil,
                headerFields: nil
            )!

            return (response, nil, timeToWait)
        }

        let firstExpectation = expectation(description: "Wait for first get")
        _ = requestExecuter.send(
            request: URLRequest(
                url: URL(string: firstTestPath)!,
                httpMethod: HTTPMethod.GET
            )
        ) { data, response, error in
            firstExpectation.fulfill()
        }

        let secondExpectation = expectation(description: "Wait for second get")
        _ = requestExecuter.send(
            request: URLRequest(
                url: URL(string: secondTestPath)!,
                httpMethod: HTTPMethod.GET
            )
        ) { data, response, error in
            secondExpectation.fulfill()
        }

        let thirdExpectation = expectation(description: "Wait for third get")
        _ = requestExecuter.send(
            request: URLRequest(
                url: URL(string: thirdTestPath)!,
                httpMethod: HTTPMethod.GET
            )
        ) { data, response, error in
            thirdExpectation.fulfill()
        }

        let fourthExpectation = expectation(description: "Wait for fourth get")
        _ = requestExecuter.send(
            request: URLRequest(
                url: URL(string: fourthTestPath)!,
                httpMethod: HTTPMethod.GET
            )
        ) { data, response, error in
            fourthExpectation.fulfill()
        }

        let result = XCTWaiter().wait(
            for: [firstExpectation, secondExpectation, thirdExpectation, fourthExpectation],
            timeout: 20,
            enforceOrder: true
        )

        XCTAssertTrue(result == .completed)
    }
}
