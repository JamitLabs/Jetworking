import XCTest
import Foundation
@testable import Jetworking

final class CustomDecoderTests: XCTestCase {
    func testCustomDecoderForGet() {
        let testableDecoder = TestableDecoder()
        let client = Client(configuration: Configurations.default(.custom(MockExecuter.self))) { session in
            session.configuration.timeoutIntervalForRequest = 30
        }

        let getDecoderCalledExpectation = expectation(description: "Decoder method called for get")
        let waitForGetExpectation = expectation(description: "Wait for get")

        testableDecoder.decodeCalled = {
            getDecoderCalledExpectation.fulfill()
        }

        client.get(endpoint: Endpoints.get.addQueryParameter(key: "SomeKey", value: "SomeValue").withCustomDecoder(testableDecoder)) { response, result in
            dispatchPrecondition(condition: .onQueue(DispatchQueue.main))

            switch result {
            case .failure:
                break

            case let .success(resultData):
                print(resultData)
            }

            XCTAssertNotNil(response)
            XCTAssertEqual(response?.statusCode, 200)
            waitForGetExpectation.fulfill()
        }

        waitForExpectations(timeout: 5.0, handler: nil)
    }

    func testCustomDecoderForPost() {
        let testableDecoder = TestableDecoder()
        let client = Client(configuration: Configurations.default(.custom(MockExecuter.self))) { session in
            session.configuration.timeoutIntervalForRequest = 30
        }

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
                break

            case let .success(resultData):
                print(resultData)
            }

            XCTAssertNotNil(response)
            XCTAssertEqual(response?.statusCode, 200)
            waitForPostExpectation.fulfill()
        }

        waitForExpectations(timeout: 5.0, handler: nil)
    }

    func testCustomDecoderForPut() {
        let testableDecoder = TestableDecoder()
        let client = Client(configuration: Configurations.default(.custom(MockExecuter.self))) { session in
            session.configuration.timeoutIntervalForRequest = 30
        }

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
                break

            case let .success(resultData):
                print(resultData)
            }

            XCTAssertNotNil(response)
            XCTAssertEqual(response?.statusCode, 200)
            waitForPutExpectation.fulfill()
        }

        waitForExpectations(timeout: 5.0, handler: nil)
    }

    func testCustomDecoderForPatch() {
        let testableDecoder = TestableDecoder()
        let client = Client(configuration: Configurations.default(.custom(MockExecuter.self))) { session in
            session.configuration.timeoutIntervalForRequest = 30
        }

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
