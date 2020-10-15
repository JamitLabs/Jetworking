import Foundation

final class SyncRequestExecutor: RequestExecutor {
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

    func download(request: URLRequest, _ completion: @escaping ((URL?, URLResponse?, Error?) -> Void)) -> CancellableRequest? {
        let operation = DownloadOperation(session: session, request: request, completion: completion)
        operationQueue.addOperation(operation)

        return operation
    }
}
