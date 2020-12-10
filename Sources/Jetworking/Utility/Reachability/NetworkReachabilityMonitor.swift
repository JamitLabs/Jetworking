import Foundation

/// A closure executed when the network reachability status changes. The closure takes a single argument: the
/// network reachability status.
public typealias NetworkReachabilityStateCallback = (NetworkReachabilityState) -> Void

public protocol NetworkReachabilityMonitor {
    /// Determines whether the network is currently reachable.
    var isReachable: Bool { get }

    /// Returns the current network reachability state.
    var state: NetworkReachabilityState { get }

    /// Starts listening for changes in network reachability state.
    ///
    /// - Note: Stops and removes any existing listener.
    ///
    /// - Parameters:
    ///   - queue: A queue on which to call the callback closure. Use the main queue by default.
    ///   - callback: A closure called when reachability changes.
    func startListening(
        on queue: DispatchQueue,
        withCallbackOnStateChange callback: @escaping NetworkReachabilityStateCallback
    ) throws

    /// Stops listening for changes in network reachability state.
    func stopListening()
}
