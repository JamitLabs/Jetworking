import Foundation
import Jetworking

final class DefaultDownloadExecuter: NSObject, DownloadExecuter {
    var delegate: DownloadExecuterDelegate?
    var sessionConfiguration: URLSessionConfiguration

    private lazy var session: URLSession = .init(configuration: sessionConfiguration, delegate: self, delegateQueue: nil)

    init(sessionConfiguration: URLSessionConfiguration, downloadExecuterDelegate: DownloadExecuterDelegate) {
        self.sessionConfiguration = sessionConfiguration
        self.delegate = downloadExecuterDelegate

        super.init()
    }

    /**
     * # Summary
     *  Downloading the given request with the given session configuration on a separate session.
     *
     * - Parameter request:
     *  The request to be downloaded.
     *
     * - Returns:
     *  The request to be able to cancel it if necessary.
     */
    func download(request: URLRequest) -> CancellableRequest? {
        let downloadTask = session.downloadTask(with: request)
        downloadTask.resume()
        return downloadTask
    }
}

extension DefaultDownloadExecuter: URLSessionDownloadDelegate {
    func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didWriteData bytesWritten: Int64, totalBytesWritten: Int64, totalBytesExpectedToWrite: Int64) {
        delegate?.downloadExecuter(downloadTask, didWriteData: bytesWritten, totalBytesWritten: totalBytesWritten, totalBytesExpectedToWrite: totalBytesExpectedToWrite)
    }

    func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didFinishDownloadingTo location: URL) {
        delegate?.downloadExecuter(downloadTask, didFinishDownloadingTo: location)
    }

    func urlSession(_ session: URLSession, task: URLSessionTask, didCompleteWithError error: Error?) {
        guard let downloadTask = task as? URLSessionDownloadTask else { return }

        delegate?.downloadExecuter(downloadTask, didCompleteWithError: error)
    }
}
