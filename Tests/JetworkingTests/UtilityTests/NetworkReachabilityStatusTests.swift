import SystemConfiguration
import XCTest
@testable import Jetworking

final class NetworkReachabilityStateTests: XCTestCase {
    func testNetworkStatusForNonReachableConnectionThatMustBeEstablishOnDemand() {
        let reachabilityFlags: SCNetworkReachabilityFlags = [.connectionOnDemand]
        XCTAssertEqual(NetworkReachabilityState(reachabilityFlags), .unreachable)
    }

    func testNetworkStatusForReachableConnectionThatRequiresToBeEstablish() {
        let reachabilityFlags: SCNetworkReachabilityFlags = [.reachable, .connectionRequired]
        XCTAssertEqual(NetworkReachabilityState(reachabilityFlags), .unreachable)
    }

    func testNetworkStatusForReachableConnectionThatRequiresToBeEstablishedWithUserIntervention() {
        let reachabilityFlags: SCNetworkReachabilityFlags = [.reachable, .connectionRequired, .interventionRequired]
        XCTAssertEqual(NetworkReachabilityState(reachabilityFlags), .unreachable)
    }

    func testNetworkStatusForReachableConnection() {
        let reachabilityFlags: SCNetworkReachabilityFlags = [.reachable]
        XCTAssertEqual(NetworkReachabilityState(reachabilityFlags), .reachable(.wiredOrWirelessLAN))
    }

    func testNetworkStatusForReachableConnectionThatRequiresToBeEstablishedOnDemand() {
        let reachabilityFlags: SCNetworkReachabilityFlags = [.reachable, .connectionRequired, .connectionOnDemand]
        XCTAssertEqual(NetworkReachabilityState(reachabilityFlags), .reachable(.wiredOrWirelessLAN))
    }

    func testNetworkStatusForReachableConnectionThatRequiresToBeEstablishedOnTraffic() {
        let reachabilityFlags: SCNetworkReachabilityFlags = [.reachable, .connectionRequired, .connectionOnTraffic]
        XCTAssertEqual(NetworkReachabilityState(reachabilityFlags), .reachable(.wiredOrWirelessLAN))
    }

    #if os(iOS)
    func testNetworkStatusForReachableConnectionViaCellular() {
        let reachabilityFlags: SCNetworkReachabilityFlags = [.reachable, .isWWAN]
        XCTAssertEqual(NetworkReachabilityState(reachabilityFlags), .reachable(.cellular))
    }

    func testNetworkStatusForReachableConnectionViaCellularThatRequiresToBeEstablished() {
        let reachabilityFlags: SCNetworkReachabilityFlags = [.reachable, .isWWAN, .connectionRequired]
        XCTAssertEqual(NetworkReachabilityState(reachabilityFlags), .unreachable)
    }
    #endif
}
