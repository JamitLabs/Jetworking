import Foundation

/// The protocol request executers need to conform to to be able to be used to send requests.
public protocol RequestExecuter {
    /// The session the request will be send on
    var session: URLSession { get }

    /**
     * # Summary
     *  The initialiser of the `RequestExecuter`.
     *
     * - Parameter session:
     *  The session the request will be send on.
     *
     */
    init(session: URLSession)

    /**
     * # Summary
     *  Sending the given request
     *
     * - Parameter request:
     *  The request to be send.
     * - Parameter completion:
     *  The completion which will be called when the request was sent.
     *
     * - Returns:
     *  The request to be able to cancel it if necessary.
     */
    func send(request: URLRequest, _ completion: @escaping ((Data?, URLResponse?, Error?) -> Void)) -> CancellableRequest?

    @available(iOS 13.0, macOS 10.15.0, *)
    func send(request: URLRequest, delegate: URLSessionTaskDelegate?) async throws -> (Data?, URLResponse?)
}
