import Foundation

final class DefaultUploadExecutor: NSObject, UploadExecutor {
    var delegate: UploadExecutorDelegate?
    var sessionConfiguration: URLSessionConfiguration

    private lazy var session: URLSession = .init(configuration: sessionConfiguration, delegate: self, delegateQueue: nil)

    init(sessionConfiguration: URLSessionConfiguration, uploadExecutorDelegate: UploadExecutorDelegate) {
        self.sessionConfiguration = sessionConfiguration
        self.delegate = uploadExecutorDelegate

        super.init()
    }

    /**
     * # Summary
     *  Uploading the given request and file with the given session configuration on a separate session.
     *
     * - Parameter request:
     *  The request to be uploaded.
     * - Parameter fromFile:
     *  The URL the file is located.
     *
     * - Returns:
     *  The request to be able to cancel if necessary.
     */
    func upload(request: URLRequest, fromFile fileURL: URL) -> CancellableRequest? {
        let uploadTask = session.uploadTask(with: request, fromFile: fileURL)
        uploadTask.resume()
        return uploadTask
    }

    /**
     * # Summary
     *  Uploading the given request and data with the given session configuration on a separate session.
     *
     * - Parameter request:
     *  The request to be uploaded.
     * - Parameter from:
     *  The data to be uploaded.
     *
     * - Returns:
     *  The request to be able to cancel if necessary.
     */
    func upload(request: URLRequest, from bodyData: Data) -> CancellableRequest? {
        let uploadTask = session.uploadTask(with: request, from: bodyData)
        uploadTask.resume()
        return uploadTask
    }
}

extension DefaultUploadExecutor: URLSessionTaskDelegate {
    func urlSession(_ session: URLSession, task: URLSessionTask, didSendBodyData bytesSent: Int64, totalBytesSent: Int64, totalBytesExpectedToSend: Int64) {
        guard let uploadTask = task as? URLSessionUploadTask else { return }

        delegate?.uploadExecutor(uploadTask, didSendBodyData: bytesSent, totalBytesSent: totalBytesSent, totalBytesExpectedToSend: totalBytesExpectedToSend)
    }

    func urlSession(_ session: URLSession, task: URLSessionTask, didCompleteWithError error: Error?) {
        guard let uploadTask = task as? URLSessionUploadTask else { return }

        if let error = error {
            delegate?.uploadExecutor(uploadTask, didCompleteWithError: error)
        } else {
            delegate?.uploadExecutor(didFinishWith: uploadTask)
        }
    }
}
