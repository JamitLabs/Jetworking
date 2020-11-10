import SystemConfiguration
import XCTest
@testable import Jetworking

final class NetworkReachabilityStateTests: XCTestCase {
    func testNetworkStatusForNonReachableConnectionThatMustBeEstablishOnDemand() {
        let reachabilityFlags: SCNetworkReachabilityFlags = [.connectionOnDemand]
        XCTAssertEqual(NetworkStatus(reachabilityFlags), .unreachable)
    }

    func testNetworkStatusForReachableConnectionThatRequiresToBeEstablish() {
        let reachabilityFlags: SCNetworkReachabilityFlags = [.reachable, .connectionRequired]
        XCTAssertEqual(NetworkStatus(reachabilityFlags), .unreachable)
    }

    func testNetworkStatusForReachableConnectionThatRequiresToBeEstablishedWithUserIntervention() {
        let reachabilityFlags: SCNetworkReachabilityFlags = [.reachable, .connectionRequired, .interventionRequired]
        XCTAssertEqual(NetworkStatus(reachabilityFlags), .unreachable)
    }

    func testNetworkStatusForReachableConnection() {
        let reachabilityFlags: SCNetworkReachabilityFlags = [.reachable]
        XCTAssertEqual(NetworkStatus(reachabilityFlags), .reachable(.localWiFi))
    }

    func testNetworkStatusForReachableConnectionThatRequiresToBeEstablishedOnDemand() {
        let reachabilityFlags: SCNetworkReachabilityFlags = [.reachable, .connectionRequired, .connectionOnDemand]
        XCTAssertEqual(NetworkStatus(reachabilityFlags), .reachable(.localWiFi))
    }

    func testNetworkStatusForReachableConnectionThatRequiresToBeEstablishedOnTraffic() {
        let reachabilityFlags: SCNetworkReachabilityFlags = [.reachable, .connectionRequired, .connectionOnTraffic]
        XCTAssertEqual(NetworkStatus(reachabilityFlags), .reachable(.localWiFi))
    }

    #if os(iOS)
    func testNetworkStatusForReachableConnectionViaCellular() {
        let reachabilityFlags: SCNetworkReachabilityFlags = [.reachable, .isWWAN]
        XCTAssertEqual(NetworkStatus(reachabilityFlags), .reachable(.cellular))
    }

    func testNetworkStatusForReachableConnectionViaCellularThatRequiresToBeEstablished() {
        let reachabilityFlags: SCNetworkReachabilityFlags = [.reachable, .isWWAN, .connectionRequired]
        XCTAssertEqual(NetworkStatus(reachabilityFlags), .unreachable)
    }
    #endif
}
