import Foundation

class RequestOperation : Operation, CancellableRequest {
    private var task: URLSessionTask?

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

    init(session: URLSession, request: URLRequest, completion: @escaping ((Data?, URLResponse?, Error?) -> Void)) {
        super.init()

        task = session.dataTask(with: request) { [weak self] data, response, error in
            completion(data, response, error)

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
