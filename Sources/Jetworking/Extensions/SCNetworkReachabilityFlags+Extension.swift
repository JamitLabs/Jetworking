import Foundation
import SystemConfiguration

extension SCNetworkReachabilityFlags {
    var isReachableViaCellular: Bool {
        #if os(iOS)
        return contains(.isWWAN)
        #else
        return false
        #endif
    }

    var isReachableViaNetworkInterface: Bool {
        contains(.reachable) &&
        (!contains(.connectionRequired) || canEstablishConnectionAutomatically)
    }

    private var canEstablishConnection: Bool {
        !intersection([.connectionOnTraffic, .connectionOnDemand]).isEmpty
    }

    private var canEstablishConnectionAutomatically: Bool {
        canEstablishConnection && !contains(.interventionRequired)
    }
}
