import Foundation
import Jetworking

final class MockDownloadExecutorDelegation: MockAsyncDelegation, DownloadExecutorDelegate {
    func downloadExecutor(_ downloadTask: URLSessionDownloadTask, didWriteData bytesWritten: Int64, totalBytesWritten: Int64, totalBytesExpectedToWrite: Int64) {
        // Implement this if needed
    }

    func downloadExecutor(_ downloadTask: URLSessionDownloadTask, didFinishDownloadingTo location: URL) {
        callback(true)
    }

    func downloadExecutor(_ downloadTask: URLSessionDownloadTask, didCompleteWithError error: Error?) {
        callback(error == nil)
    }
}
