import Foundation

// The delegate protocol for the `UploadExecuter`.
public protocol UploadExecuterDelegate: AnyObject {
    /**
     * # Summary
     *  Delegate which gets called when a progress update happens.
     *
     * - Parameter uploadTask:
     *  The upload task the upload is executed on.
     * - Parameter didSendBodyData:
     *  The bytes currently send.
     * - Parameter totalBytesSent:
     *  The bytes totally sent.
     * - Parameter totalBytesExpectedToSend:
     *  The total bytes expected to send.
     */
    func uploadExecuter(_ uploadTask: URLSessionUploadTask, didSendBodyData bytesSent: Int64, totalBytesSent: Int64, totalBytesExpectedToSend: Int64)

    /**
     * # Summary
     *  Delegate which gets called when an upload did finish.
     *
     * - Parameter downloadTask:
     *  The upload task the upload is executed on..
     */
    func uploadExecuter(didFinishWith uploadTask: URLSessionUploadTask)

    /**
     * # Summary
     *  Delegate which gets called when an upload fails.
     *
     * - Parameter downloadTask:
     *  The upload task the upload is executed on.
     * - Parameter didCompleteWithError:
     *  The error which was thrown while uploading.
     */
    func uploadExecuter(_ uploadTask: URLSessionUploadTask, didCompleteWithError error: Error?)
}
