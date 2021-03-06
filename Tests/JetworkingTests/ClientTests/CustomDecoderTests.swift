import XCTest
import Foundation
@testable import Jetworking

final class CustomDecoderTests: XCTestCase {
    var defaultSession: URLSession = {
        var session = URLSession(configuration: .default)
        session.configuration.timeoutIntervalForRequest = 30
        return session
    }()

    func testCustomDecoderForGet() {
        let testableDecoder = TestableDecoder()
        let client = Client(configuration: Configurations.default(.custom(MockExecuter.self)), session: defaultSession)

        let getDecoderCalledExpectation = expectation(description: "Decoder method called for get")
        let waitForGetExpectation = expectation(description: "Wait for get")

        testableDecoder.decodeCalled = {
            getDecoderCalledExpectation.fulfill()
        }

        client.get(endpoint: Endpoints.get.addQueryParameter(key: "SomeKey", value: "SomeValue").withCustomDecoder(testableDecoder)) { response, result in
            dispatchPrecondition(condition: .onQueue(DispatchQueue.main))

            switch result {
            case .failure:
                XCTFail("Request should not be result in failure!")

            case let .success(resultData):
                XCTAssertNotNil(resultData)
            }

            XCTAssertNotNil(response)
            XCTAssertEqual(response?.statusCode, 200)
            waitForGetExpectation.fulfill()
        }

        waitForExpectations(timeout: 5.0, handler: nil)
    }

    func testCustomDecoderForPost() {
        let testableDecoder = TestableDecoder()
        let client = Client(configuration: Configurations.default(.custom(MockExecuter.self)), session: defaultSession)

        let postDecodingCalledExpectation = expectation(description: "Decoder method called for post")
        let waitForPostExpectation = expectation(description: "Wait for post")

        let body: MockBody = .init(foo1: "bar1", foo2: "bar2")

        testableDecoder.decodeCalled = {
            postDecodingCalledExpectation.fulfill()
        }

        client.post(endpoint: Endpoints.post.withCustomDecoder(testableDecoder), body: body) { response, result in
            dispatchPrecondition(condition: .onQueue(DispatchQueue.main))
            switch result {
            case .failure:
                XCTFail("Request should not be result in failure!")

            case let .success(resultData):
                XCTAssertNotNil(resultData)
            }

            XCTAssertNotNil(response)
            XCTAssertEqual(response?.statusCode, 200)
            waitForPostExpectation.fulfill()
        }

        waitForExpectations(timeout: 5.0, handler: nil)
    }

    func testCustomDecoderForPut() {
        let testableDecoder = TestableDecoder()
        let client = Client(configuration: Configurations.default(.custom(MockExecuter.self)), session: defaultSession)

        let putDecodingCalledExpectation = expectation(description: "Decoder method called for put")
        let waitForPutExpectation = expectation(description: "Wait for put")

        let body: MockBody = .init(foo1: "bar1", foo2: "bar2")
        testableDecoder.decodeCalled = {
            putDecodingCalledExpectation.fulfill()
        }

        client.put(endpoint: Endpoints.put.withCustomDecoder(testableDecoder), body: body) { response, result in
            dispatchPrecondition(condition: .onQueue(DispatchQueue.main))
            switch result {
            case .failure:
                XCTFail("Request should not be result in failure!")

            case let .success(resultData):
                XCTAssertNotNil(resultData)
            }

            XCTAssertNotNil(response)
            XCTAssertEqual(response?.statusCode, 200)
            waitForPutExpectation.fulfill()
        }

        waitForExpectations(timeout: 5.0, handler: nil)
    }

    func testCustomDecoderForPatch() {
        let testableDecoder = TestableDecoder()
        let client = Client(configuration: Configurations.default(.custom(MockExecuter.self)), session: defaultSession)

        let patchDecodingCalledExpectation = expectation(description: "Decoder method called for patch")
        let waitForPatchExpectation = expectation(description: "Wait for patch")

        let body: MockBody = .init(foo1: "bar1", foo2: "bar2")
        testableDecoder.decodeCalled = {
            patchDecodingCalledExpectation.fulfill()
        }

        client.patch(endpoint: Endpoints.patch.withCustomDecoder(testableDecoder), body: body) { response, result in
            dispatchPrecondition(condition: .onQueue(DispatchQueue.main))
            switch result {
            case .failure:
                XCTFail("Request should not be result in failure!")

            case let .success(resultData):
                XCTAssertNotNil(resultData)
            }

            XCTAssertNotNil(response)
            XCTAssertEqual(response?.statusCode, 200)
            waitForPatchExpectation.fulfill()
        }

        waitForExpectations(timeout: 5.0, handler: nil)
    }
}
