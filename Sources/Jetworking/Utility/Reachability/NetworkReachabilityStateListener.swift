import Foundation

/// Mutable storage for network status and callback.
struct NetworkReachabilityStateListener {
    /// A closure executed when the network reachability state changes.
    var callback: NetworkReachabilityStateCallback?

    /// A working queue on which listeners will be called.
    var callbackQueue: DispatchQueue?

    /// Network status in previous time.
    var previousStatus: NetworkReachabilityState?

    private let lock: UnfairLock = .init()

    init(
        callback: NetworkReachabilityStateCallback? = nil,
        callbackQueue: DispatchQueue? = nil,
        previousStatus: NetworkReachabilityState? = nil
    ) {
        self.callback = callback
        self.callbackQueue = callbackQueue
        self.previousStatus = previousStatus
    }

    mutating func update(callback: @escaping (inout Self) -> Void) {
        lock.lock()
        defer { lock.unlock() }

        callback(&self)
    }

    mutating func reset() {
        lock.lock()
        defer { lock.unlock() }

        callback = nil
        callbackQueue = nil
        previousStatus = nil
    }
}

/// An implementation of unfair lock in Swift
fileprivate final class UnfairLock {
    private let unfairLock: os_unfair_lock_t

    init() {
        unfairLock = .allocate(capacity: 1)
        unfairLock.initialize(to: os_unfair_lock())
    }

    deinit {
        unfairLock.deinitialize(count: 1)
        unfairLock.deallocate()
    }

    func lock() {
        os_unfair_lock_lock(unfairLock)
    }

    func unlock() {
        os_unfair_lock_unlock(unfairLock)
    }
}
