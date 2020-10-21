import Foundation

/// The protocol an upload executor has to conform to to be used to upload.
public protocol UploadExecutor: AnyObject {
    /// The delegate to set to receive updates on uploads.
    var delegate: UploadExecutorDelegate? { get }
    /// The session configuration to use to upload.
    var sessionConfiguration: URLSessionConfiguration { get }

    /**
     * # Summary
     *  Initialises an upload executor to upload.
     *
     * - Parameter sessionConfiguration:
     *  The session configuration to use within the upload executor.
     * - Parameter downloadExecutorDelegate:
     *  The delegate to send the upload updates to.
     */
    init(sessionConfiguration: URLSessionConfiguration, uploadExecutorDelegate: UploadExecutorDelegate)

    /**
     * # Summary
     *  Uploading the given request and file.
     *
     * - Parameter request:
     *  The request to be uploaded.
     * - Parameter fromFile:
     *  The file to be uploaded.
     *
     * - Returns:
     *  The request to be able to cancel if necessary.
     */
    func upload(request: URLRequest, fromFile fileURL: URL) -> CancellableRequest?

    /**
     * # Summary
     *  Uploading the given request and data.
     *
     * - Parameter request:
     *  The request to be uploaded.
     * - Parameter from:
     *  The data to be uploaded.
     *
     * - Returns:
     *  The request to be able to cancel if necessary.
     */
    func upload(request: URLRequest, from bodyData: Data) -> CancellableRequest?
}
