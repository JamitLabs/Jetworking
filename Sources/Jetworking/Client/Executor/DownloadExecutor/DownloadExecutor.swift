import Foundation

/// The protocol a download executor has to conform to to be used to download.
public protocol DownloadExecutor: AnyObject {
    /// The delegate to set to receive updates on downloads.
    var delegate: DownloadExecutorDelegate? { get }
    /// The session configuration to use to download.
    var sessionConfiguration: URLSessionConfiguration { get }

    /**
     * # Summary
     *  Initialises a download executor to download.
     *
     * - Parameter sessionConfiguration:
     *  The session configuration to use within the download executor.
     * - Parameter downloadExecutorDelegate:
     *  The delegate to send the download updates to.
     */
    init(sessionConfiguration: URLSessionConfiguration, downloadExecutorDelegate: DownloadExecutorDelegate)

    /**
     * # Summary
     *  Downloading the given request
     *
     * - Parameter request:
     *  The request to be downloaded.
     *
     * - Returns:
     *  The request to be able to cancel it if necessary.
     */
    func download(request: URLRequest) -> CancellableRequest?
}
