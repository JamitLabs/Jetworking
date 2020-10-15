import Foundation

final class DownloadOperation : Operation, CancellableRequest {
    private var task: URLSessionDownloadTask?

    enum OperationState : Int {
        case ready
        case executing
        case finished
    }

    private var state: OperationState = .ready {
        willSet {
            self.willChangeValue(forKey: "isExecuting")
            self.willChangeValue(forKey: "isFinished")
        }

        didSet {
            self.didChangeValue(forKey: "isExecuting")
            self.didChangeValue(forKey: "isFinished")
        }
    }

    override var isReady: Bool { return state == .ready }
    override var isExecuting: Bool { return state == .executing }
    override var isFinished: Bool { return state == .finished }

    init(session: URLSession, request: URLRequest, completion: @escaping ((URL?, URLResponse?, Error?) -> Void)) {
        super.init()

        task = session.downloadTask(with: request) { [weak self] url, response, error in
            completion(url, response, error)
            
            self?.state = .finished
        }
    }

    override func start() {
        guard !isCancelled else { return state = .finished }

        state = .executing

        task?.resume()
    }

    override func cancel() {
        super.cancel()

        task?.cancel()
    }
}
