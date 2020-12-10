import Foundation

enum ClientTaskError: Error {
    case unexpectedTaskExecution

    static let connectionUnavailable = NSError(
        domain: URLError.errorDomain,
        code: URLError.Code.notConnectedToInternet.rawValue,
        userInfo: nil
    )
}

final class ClientTaskExecutor: NSObject {
    internal static let `default` = ClientTaskExecutor()

    private var reachabilityManager: NetworkReachabilityMonitor?

    init(reachabilityMonitor: NetworkReachabilityMonitor? = NetworkReachabilityManager.default) {
        self.reachabilityManager = reachabilityMonitor
        super.init()

        do {
            try self.reachabilityManager?.startListening(on: .main) { _ in }
        } catch {
            NSLog("[WARNING] Faild to start network monitor. Error: \(error)")
        }
    }

    func perform<T>(_ task: Client.Task, on executor: T) throws -> CancellableRequest? {
        guard reachabilityManager == nil || reachabilityManager?.isReachable == true else {
            throw ClientTaskError.connectionUnavailable
        }

        switch (executor, task) {
            case (is RequestExecutor, let .dataTask(request, completionHandler)) :
                return (executor as! RequestExecutor).send(request: request, completionHandler)

            case (is DownloadExecutor, let .downloadTask(request)):
                return (executor as! DownloadExecutor).download(request: request)

            case (is UploadExecutor, let .uploadDataTask(request, data)):
                return (executor as! UploadExecutor).upload(request: request, from: data)

            case (is UploadExecutor, let .uploadFileTask(request, fileURL)):
                return (executor as! UploadExecutor).upload(request: request, fromFile: fileURL)

            default:
                throw ClientTaskError.unexpectedTaskExecution
        }
    }
}
