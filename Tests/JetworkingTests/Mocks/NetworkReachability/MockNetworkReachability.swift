import Foundation
import Jetworking

final class MockNetworkReachabilityMonitor: NetworkReachabilityMonitor {
    var isReachable: Bool { if case .reachable = state { return true } else { return false } }

    var state: NetworkReachabilityState { reachabilityState }

    var reachabilityState: NetworkReachabilityState

    init(state: NetworkReachabilityState = .notDetermined) {
        reachabilityState = state
    }

    func startListening(
        on queue: DispatchQueue,
        withCallbackOnStateChange callback: @escaping NetworkReachabilityStateCallback
    ) throws {
        // Implement this if needed
    }

    func stopListening() {
        // Implement this if needed
    }
}
