import Foundation

final class BackgroundDownloadExecutor: NSObject, DownloadExecutor {
    var delegate: DownloadExecutorDelegate?
    var sessionConfiguration: URLSessionConfiguration

    private var backgroundIdentifier: String
    private var isDiscretionary: Bool = false
    private lazy var session: URLSession = {
        let configuration: URLSessionConfiguration = .background(
            withIdentifier: backgroundIdentifier,
            andIsDiscretionaryFlag: isDiscretionary,
            andConfiguration: sessionConfiguration
        )
        let session: URLSession = .init(configuration: configuration, delegate: self, delegateQueue: nil)
        return session
    }()

    init(sessionConfiguration: URLSessionConfiguration, downloadExecutorDelegate: DownloadExecutorDelegate) {
        self.sessionConfiguration = sessionConfiguration
        self.delegate = downloadExecutorDelegate
        self.backgroundIdentifier = "com.jamitlabs.jetworking.background"
        self.isDiscretionary = false

        super.init()
    }

    /**
     * # Summary
     *  Initialises a download executor to download.
     *
     * - Parameter sessionConfiguration:
     *  The session configuration to use within the download executor.
     * - Parameter downloadExecutorDelegate:
     *  The delegate to send the download updates to.
     * - Parameter backgroundIdentifier:
     *  When having an app extension which also handles download functionality make sure to set different background Identifiers as otherwise problems might occur
     * - Parameter isDiscretionary:
     *  When transferring large amounts of data, you are encouraged to set the value of this property to true.
     *  Doing so lets the system schedule those transfers at times that are more optimal for the device.
     *  For example, the system might delay transferring large files until the device is plugged in and connected to the network via Wi-Fi.
     *  Default value is `false`
     */
    init(
        sessionConfiguration: URLSessionConfiguration,
        downloadExecutorDelegate: DownloadExecutorDelegate,
        backgroundIdentifier: String = "com.jamitlabs.jetworking.background",
        isDiscretionary: Bool = false
    ) {
        self.sessionConfiguration = sessionConfiguration
        self.delegate = downloadExecutorDelegate
        self.backgroundIdentifier = backgroundIdentifier
        self.isDiscretionary = isDiscretionary

        super.init()
    }

    /**
     * # Summary
     *  Downloading the given request with the given session configuration on a separate background session.
     *
     * - Parameter request:
     *  The request to be downloaded.
     *
     * - Returns:
     *  The request to be able to cancel it if necessary.
     */
    func download(request: URLRequest) -> CancellableRequest? {
        return session.downloadTask(with: request)
    }
}

extension BackgroundDownloadExecutor: URLSessionDownloadDelegate {
    func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didWriteData bytesWritten: Int64, totalBytesWritten: Int64, totalBytesExpectedToWrite: Int64) {
        delegate?.downloadExecutor(downloadTask, didWriteData: bytesWritten, totalBytesWritten: totalBytesWritten, totalBytesExpectedToWrite: totalBytesExpectedToWrite)
    }

    func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didFinishDownloadingTo location: URL) {
        delegate?.downloadExecutor(downloadTask, didFinishDownloadingTo: location)
    }

    func urlSession(_ session: URLSession, task: URLSessionTask, didCompleteWithError error: Error?) {
        guard let downloadTask = task as? URLSessionDownloadTask else { return }

        delegate?.downloadExecutor(downloadTask, didCompleteWithError: error)
    }
}
