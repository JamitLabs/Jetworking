import Foundation

/**
 * # Summary
 *  A background download may be useful when having a lot of data to download and not wanting the user to have to wait for a long time.
 *  It may also be useful to download files in the background when the app does not directly need to use it.
 *  For example when having a music playlist the user wants to download to be able to use it on the go without wasting mobile data.
 *  As this download might take some time and one does not want the user to always have the app in foreground, the background download executor might be a good choice.
 *  Furthermore for video downloads, when wanting to be able to watch them on the go when internet might not be availeble, it might be suitable.
 *
 * Nevertheless this background download executor is still a work in progress approach and needs some optimisations as well as some adjustments to the programmers app itself
 * which need to be investigated further.
 */
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
