import Foundation

final class DownloadExecutor: NSObject {
    private lazy var session: URLSession = {
        // TODO maybe we should make this identifier configurable as there might occur problems with app extensions
        // see: https://www.avanderlee.com/swift/urlsession-common-pitfalls-with-background-download-upload-tasks/
        let configuration: URLSessionConfiguration = .background(withIdentifier: "com.jamitlabs.jetworking.background")
        /*
         * When transferring large amounts of data, you are encouraged to set the value of this property to true. Doing so lets the system schedule those transfers at times that are more optimal for the device. For example, the system might delay transferring large files until the device is plugged in and connected to the network via Wi-Fi.
         */
        configuration.isDiscretionary = false // TODO we might make this adjustable
        let session: URLSession = .init(configuration: configuration, delegate: self, delegateQueue: nil)
        
        return session
    }()

    private var downloadTask: URLSessionDownloadTask?
    private var completion: ((URL?, URLResponse?, Error?) -> Void)?

    func download(request: URLRequest, _ completion: @escaping ((URL?, URLResponse?, Error?) -> Void)) -> CancellableRequest? {
        self.completion = completion
        downloadTask = session.downloadTask(with: request)
//        if #available(OSX 10.13, *) {
//            downloadTask?.earliestBeginDate = Date()
//            downloadTask?.countOfBytesClientExpectsToSend = 512
//            downloadTask?.countOfBytesClientExpectsToReceive = 1 * 1024 * 1024 * 1024 // 1GB
//        }

        return downloadTask
    }

//    func calculateProgress(completionHandler : @escaping (Float) -> Void) {
//        session.getTasksWithCompletionHandler { (tasks, uploads, downloads) in
//            let bytesReceived = downloads.map{ $0.countOfBytesReceived }.reduce(0, +)
//            let bytesExpectedToReceive = downloads.map{ $0.countOfBytesExpectedToReceive }.reduce(0, +)
//            let progress = bytesExpectedToReceive > 0 ? Float(bytesReceived) / Float(bytesExpectedToReceive) : 0.0
//            completionHandler(progress)
//        }
//    }
}

extension DownloadExecutor: URLSessionDownloadDelegate {
    func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didWriteData bytesWritten: Int64, totalBytesWritten: Int64, totalBytesExpectedToWrite: Int64) {
        if downloadTask == self.downloadTask {
            let calculatedProgress = Float(totalBytesWritten) / Float(totalBytesExpectedToWrite)
            print("Progress \(calculatedProgress)")
        }
    }

    func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didResumeAtOffset fileOffset: Int64, expectedTotalBytes: Int64) {
        // TODO do we need this?
    }

    func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didFinishDownloadingTo location: URL) {
        // check for and handle errors:
        // * downloadTask.response should be an HTTPURLResponse with statusCode in 200..<299

        print("Download finished: \(location)")

        // TODO: Do we need to save the file to a separate directory to have it permanently or is the temp directory sufficient?
        // See https://developer.apple.com/documentation/foundation/url_loading_system/downloading_files_from_websites
        //DispatchQueue.main.async {
            self.completion?(location, nil, nil)
        //}
    }

    func urlSession(_ session: URLSession, task: URLSessionTask, didCompleteWithError error: Error?) {
        print("Task completed: \(task), error: \(error)")
        //completion?(nil, nil, error)
    }
}
