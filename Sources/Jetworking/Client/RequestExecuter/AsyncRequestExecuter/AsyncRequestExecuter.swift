import Foundation

final class AsyncRequestExecutor: RequestExecutor {
    internal let session: URLSession

    init(session: URLSession) {
        self.session = session
    }

    func send(request: URLRequest, _ completion: @escaping ((Data?, URLResponse?, Error?) -> Void)) -> CancellableRequest? {
        let dataTask = session.dataTask(with: request, completionHandler: completion)
        dataTask.resume()

        return dataTask
    }

    func download(request: URLRequest, _ completion: @escaping ((URL?, URLResponse?, Error?) -> Void)) -> CancellableRequest? {
        let downloadTask = session.downloadTask(with: request, completionHandler: completion)
        downloadTask.resume()

        return downloadTask
    }
}
