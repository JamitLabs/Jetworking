import Foundation

final class AsyncRequestExecuter: RequestExecuter {
    internal let session: URLSession

    init(session: URLSession) {
        self.session = session
    }

    func send(request: URLRequest, _ completion: @escaping ((Data?, URLResponse?, Error?) -> Void)) -> CancellableRequest? {
        let dataTask = session.dataTask(with: request, completionHandler: completion)
        dataTask.resume()

        return dataTask
    }
}
