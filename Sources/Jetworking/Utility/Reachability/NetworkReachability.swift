import Foundation
import SystemConfiguration

/// Typealias for the state of network reachability.
public typealias NetworkReachabilityState = NetworkReachability.State

/// A container for all enumerations related to network state.
public enum NetworkReachability {
    /// Defines the various connection types detected by reachability flags.
    public enum ConnectionInterface: Equatable {
        /// LAN or WiFi.
        case localWiFi

        /// Cellular connection.
        case cellular
    }

    /// Defines the various states of network reachability.
    public enum State: Equatable {
        /// It could not be determined whether the network is reachable.
        case notDetermined

        /// The network is not reachable.
        case unreachable

        /// The network is reachable over an interface `ConnectionInterface`.
        case reachable(ConnectionInterface)

        init(_ flags: SCNetworkReachabilityFlags) {
            guard flags.isReachableViaNetworkInterface else {
                self = .unreachable
                return
            }

            var networkStatus: Self = .reachable(.localWiFi)
            if flags.isReachableViaCellular {
                networkStatus = .reachable(.cellular)
            }

            self = networkStatus
        }
    }
}
