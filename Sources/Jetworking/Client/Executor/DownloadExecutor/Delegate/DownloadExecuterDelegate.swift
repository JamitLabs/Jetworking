import Foundation

// The delegate protocol for the `DownloadExecuter`.
public protocol DownloadExecuterDelegate: AnyObject {
    /**
     * # Summary
     *  Delegate which gets called when a progress update happens.
     *
     * - Parameter downloadTask:
     *  The download task the download is executed on.
     * - Parameter didWriteData:
     *  The bytes already written.
     * - Parameter totalBytesWritten:
     *  The bytes totally written.
     * - Parameter totalBytesExpectedToWrite:
     *  The total bytes expected to write.
     */
    func downloadExecuter(_ downloadTask: URLSessionDownloadTask, didWriteData bytesWritten: Int64, totalBytesWritten: Int64, totalBytesExpectedToWrite: Int64)

    /**
     * # Summary
     *  Delegate which gets called when a download did finish.
     *
     * - Parameter downloadTask:
     *  The download task the download is executed on.
     * - Parameter didFinishDownloadingTo:
     *  The location the file was downloaded to.
     */
    func downloadExecuter(_ downloadTask: URLSessionDownloadTask, didFinishDownloadingTo location: URL)

    /**
     * # Summary
     *  Delegate which gets called when a download fails.
     *
     * - Parameter downloadTask:
     *  The download task the download is executed on.
     * - Parameter didCompleteWithError:
     *  The error which was thrown while downloading.
     */
    func downloadExecuter(_ downloadTask: URLSessionDownloadTask, didCompleteWithError error: Error?)
}
