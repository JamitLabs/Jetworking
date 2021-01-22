import Foundation

/// The protocol a download executer has to conform to to be used to download.
public protocol DownloadExecuter: AnyObject {
    /// The delegate to set to receive updates on downloads.
    var delegate: DownloadExecuterDelegate? { get }
    /// The session configuration to use to download.
    var sessionConfiguration: URLSessionConfiguration { get }

    /**
     * # Summary
     *  Initialises a download executer to download.
     *
     * - Parameter sessionConfiguration:
     *  The session configuration to use within the download executer.
     * - Parameter downloadExecuterDelegate:
     *  The delegate to send the download updates to.
     */
    init(sessionConfiguration: URLSessionConfiguration, downloadExecuterDelegate: DownloadExecuterDelegate)

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
