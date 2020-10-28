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

        MockURLProtocol.requestHandler = { request in
            let waitTime: [String: TimeInterval] = [
                "https://www.jamitlabs.com/somePath0": 2,
                "https://www.jamitlabs.com/somePath1": 0,
                "https://www.jamitlabs.com/somePath2": 3,
                "https://www.jamitlabs.com/somePath3": 1
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
                url: URL(string: "https://www.jamitlabs.com/somePath0")!,
                httpMethod: HTTPMethod.GET
            )
        ) { data, response, error in
            firstExpectation.fulfill()
        }

        let secondExpectation = expectation(description: "Wait for second get")
        _ = requestExecuter.send(
            request: URLRequest(
                url: URL(string: "https://www.jamitlabs.com/somePath1")!,
                httpMethod: HTTPMethod.GET
            )
        ) { data, response, error in
            secondExpectation.fulfill()
        }

        let thirdExpectation = expectation(description: "Wait for third get")
        _ = requestExecuter.send(
            request: URLRequest(
                url: URL(string: "https://www.jamitlabs.com/somePath2")!,
                httpMethod: HTTPMethod.GET
            )
        ) { data, response, error in
            thirdExpectation.fulfill()
        }

        let fourthExpectation = expectation(description: "Wait for fourth get")
        _ = requestExecuter.send(
            request: URLRequest(
                url: URL(string: "https://www.jamitlabs.com/somePath3")!,
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
