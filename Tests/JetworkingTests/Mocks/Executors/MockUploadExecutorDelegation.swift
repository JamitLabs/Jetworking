import Foundation
import Jetworking

final class MockUploadExecutorDelegation: MockAsyncDelegation, UploadExecutorDelegate {
    func uploadExecutor(_ uploadTask: URLSessionUploadTask, didSendBodyData bytesSent: Int64, totalBytesSent: Int64, totalBytesExpectedToSend: Int64) {
        // Implement this if needed
    }

    func uploadExecutor(didFinishWith uploadTask: URLSessionUploadTask) {
        callback(true)
    }

    func uploadExecutor(_ uploadTask: URLSessionUploadTask, didCompleteWithError error: Error?) {
        callback(error == nil)
    }
}
