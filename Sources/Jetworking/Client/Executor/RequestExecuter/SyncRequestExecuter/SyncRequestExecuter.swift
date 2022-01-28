import Foundation

final class SyncRequestExecuter: RequestExecuter {
    internal let session: URLSession

    private lazy var operationQueue: OperationQueue = {
        let operationQueue = OperationQueue()
        operationQueue.maxConcurrentOperationCount = 1
        return operationQueue
    }()

    init(session: URLSession) {
        self.session = session
    }

    func send(request: URLRequest, _ completion: @escaping ((Data?, URLResponse?, Error?) -> Void)) -> CancellableRequest? {
        let operation = RequestOperation(session: session, request: request, completion: completion)
        operationQueue.addOperation(operation)

        return operation
    }

    @available(iOS 13.0, macOS 10.15.0, *)
    func send(request: URLRequest, delegate: URLSessionTaskDelegate?) async throws -> (Data?, URLResponse?) {
        return (nil, nil)
    }
}
