import Foundation
import Jetworking

private let executingDownloadsAss = AssociatedObject<[Int: DownloadHandler]>()
private let downloadExecuterAss = AssociatedObject<DownloadExecuter>()

extension Client {
    private var executingDownloads: [Int: DownloadHandler] {
        get { executingDownloadsAss[self, [:]] }
        set { executingDownloadsAss[self] = newValue }
    }

    private var downloadExecuter: DownloadExecuter {
        get { downloadExecuterAss[self, createInitialExecuter(downloadExecuterType: .default)] }
        set { downloadExecuterAss[self] = newValue }
    }

    /// Call this method at most once, and before calling `download`.
    /// If you do not call this method and call `download`, the default download executor type is used.
    public func setupForDownloading(downloadExecutorType: DownloadExecuterType) {
        guard downloadExecuterAss[self] == nil else { fatalError("Only call `setupForDownloading` once per Client.") }

        downloadExecuter = createInitialExecuter(downloadExecuterType: downloadExecutorType)
    }

    private func createInitialExecuter(downloadExecuterType: DownloadExecuterType) -> DownloadExecuter {
        switch downloadExecuterType {
        case .default:
            return DefaultDownloadExecuter(
                sessionConfiguration: session.configuration,
                downloadExecuterDelegate: self
            )

        case .background:
            return BackgroundDownloadExecuter(
                sessionConfiguration: session.configuration,
                downloadExecuterDelegate: self
            )

        case let .custom(executerType):
            return executerType.init(
                sessionConfiguration: session.configuration,
                downloadExecuterDelegate: self
            )
        }
    }

    @discardableResult
    public func download(
        url: URL,
        isForced: Bool = false,
        progressHandler: DownloadHandler.ProgressHandler,
        _ completion: @escaping DownloadHandler.CompletionHandler
    ) -> CancellableRequest? {
        // TODO: Add correct error handling
        guard checkForValidDownloadURL(url) else { return nil }

        let request: URLRequest = .init(url: url)

        // Looks up in cache (if no forced download) and
        // performs completion handler immediately with cached URL if available,
        // otherwise executes the download request
        if !isForced, let url = sessionCache.queryResourceItemURL(for: request) {
            let response = sessionCache.queryCachedResponse(for: request)?.response
            enqueue(completion(url, response, nil))
            return nil
        } else {
            let task = downloadExecuter.download(request: request)
            task.flatMap {
                executingDownloads[$0.identifier] = DownloadHandler(
                    progressHandler: progressHandler,
                    completionHandler: completion
                )
            }

            return task
        }
    }

    private func checkForValidDownloadURL(_ url: URL) -> Bool {
        guard let scheme = URLComponents(string: url.absoluteString)?.scheme else { return false }

        return scheme == "http" || scheme == "https"
    }
}

extension Client: DownloadExecuterDelegate {
    public func downloadExecuter(
        _ downloadTask: URLSessionDownloadTask,
        didWriteData bytesWritten: Int64,
        totalBytesWritten: Int64,
        totalBytesExpectedToWrite: Int64
    ) {
        guard let progressHandler = executingDownloads[downloadTask.identifier]?.progressHandler else { return }
        enqueue(progressHandler(totalBytesWritten, totalBytesExpectedToWrite))
    }

    public func downloadExecuter(_ downloadTask: URLSessionDownloadTask, didFinishDownloadingTo location: URL) {
        // TODO handle response before calling the completion
        guard let completionHandler = executingDownloads[downloadTask.identifier]?.completionHandler else { return }

        do {
            // `location` is a URL containing a path with `tmp` directory.
            // The files in this folder may occasionally get cleared after leaving the delegation.
            // It is recommended to store downloaded file persistently after each download.
            let request = downloadTask.originalRequest ?? downloadTask.currentRequest
            let fileURL = try cacheDownloadFile(local: location, origin: request?.url)

            sessionCache.store(fileURL, from: downloadTask)
            enqueue(completionHandler(fileURL, downloadTask.response, downloadTask.error))
        } catch {
            enqueue(completionHandler(nil, downloadTask.response, error))
        }
    }

    public func downloadExecuter(_ downloadTask: URLSessionDownloadTask, didCompleteWithError error: Error?) {
        // TODO handle response before calling the completion
        guard let completionHandler = executingDownloads[downloadTask.identifier]?.completionHandler else { return }
        enqueue(completionHandler(nil, downloadTask.response, error))
    }

    private func cacheDownloadFile(local fileURL: URL, origin originfileURL: URL?) throws -> URL {
        // Uses cache folder to store downloaded file.
        let cacheURL = try FileManager.default.url(
            for: .cachesDirectory,
            in: .userDomainMask,
            appropriateFor: nil,
            create: true
        )

        // Restores file name if possible.
        let fileName = (originfileURL ?? fileURL).lastPathComponent
        let destinationURL = cacheURL.appendingPathComponent(fileName)

        // Removes old file if any.
        if FileManager.default.fileExists(atPath: destinationURL.path) {
            try FileManager.default.removeItem(at: destinationURL)
        }

        // Moves file to `Library/Caches` directory.
        try FileManager.default.moveItem(at: fileURL, to: destinationURL)

        return destinationURL
    }
}
