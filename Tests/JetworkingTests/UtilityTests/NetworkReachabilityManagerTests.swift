import XCTest
@testable import Jetworking

final class NetworkReachabilityManagerTests: XCTestCase {
    var timeout: TimeInterval = 10

    func testManagerInitializedWithHost() {
        let manager: NetworkReachabilityManager? = try? .init(host: "localhost")

        XCTAssertNotNil(manager)
    }

    func testManagerInitializedWithAddress() {
        let manager: NetworkReachabilityManager? = try? .init()

        XCTAssertNotNil(manager)
    }

    func testHostManagerStartWithReachableStatus() {
        let manager: NetworkReachabilityManager? = try? .init(host: "localhost")

        XCTAssertEqual(manager?.isReachable, true)
        XCTAssertEqual(manager?.state, .reachable(.wiredOrWirelessLAN))
    }

    func testAddressManagerStartWithReachableStatus() {
        let manager: NetworkReachabilityManager? = try? .init()

        XCTAssertEqual(manager?.isReachable, true)
        XCTAssertEqual(manager?.state, .reachable(.wiredOrWirelessLAN))
    }

    func testHostManagerRestart() {
        let manager: NetworkReachabilityManager? = try? .init(host: "localhost")
        let firstCallbackExpectation = expectation(description: "First callback should be called")
        let secondCallbackExpectation = expectation(description: "Second callback should be called")

        try? manager?.startListening { _ in
            firstCallbackExpectation.fulfill()
        }
        wait(for: [firstCallbackExpectation], timeout: timeout)

        manager?.stopListening()

        try? manager?.startListening { _ in
            secondCallbackExpectation.fulfill()
        }
        wait(for: [secondCallbackExpectation], timeout: timeout)

        XCTAssertEqual(manager?.state, .reachable(.wiredOrWirelessLAN))
    }

    func testAddressManagerRestart() {
        let manager: NetworkReachabilityManager? = try? .init()
        let firstCallbackExpectation = expectation(description: "First callback should be called")
        let secondCallbackExpectation = expectation(description: "Second callback should be called")

        try? manager?.startListening { _ in
            firstCallbackExpectation.fulfill()
        }
        wait(for: [firstCallbackExpectation], timeout: timeout)

        manager?.stopListening()

        try? manager?.startListening { _ in
            secondCallbackExpectation.fulfill()
        }
        wait(for: [secondCallbackExpectation], timeout: timeout)

        XCTAssertEqual(manager?.state, .reachable(.wiredOrWirelessLAN))
    }

    func testHostManagerDeinitialized() {
        let expect = expectation(description: "Reachability queue should get cleared")
        var manager: NetworkReachabilityManager? = try? .init(host: "localhost")
        weak var weakManager = manager

        try? manager?.startListening(withCallbackOnStateChange: { _ in })
        manager?.stopListening()
        manager?.reachabilityQueue.async { expect.fulfill() }
        manager = nil

        waitForExpectations(timeout: timeout)

        XCTAssertNil(manager)
        XCTAssertNil(weakManager)
    }

    func testAddressManagerDeinitialized() {
        let expect = expectation(description: "Reachability queue should get clear")
        var manager: NetworkReachabilityManager? = try? .init()
        weak var weakManager = manager

        try? manager?.startListening(withCallbackOnStateChange: { _ in })
        manager?.stopListening()
        manager?.reachabilityQueue.async { expect.fulfill() }
        manager = nil

        waitForExpectations(timeout: timeout)

        XCTAssertNil(manager)
        XCTAssertNil(weakManager)
    }
}
