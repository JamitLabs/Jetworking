import Foundation
import Jetworking

private let executingUploadsAss = AssociatedObject<[Int: UploadHandler]>()
private let uploadExecuterAss = AssociatedObject<UploadExecuter>()

extension Client {
    private var executingUploads: [Int: UploadHandler] {
        get { executingUploadsAss[self, [:]] }
        set { executingUploadsAss[self] = newValue }
    }

    private var uploadExecuter: UploadExecuter {
        get { uploadExecuterAss[self, createInitialExecuter(uploadExecuterType: .default)] }
        set { uploadExecuterAss[self] = newValue }
    }

    /// Call this method at most once, and before calling `upload`.
    /// If you do not call this method and call `upload`, the default upload executor type is used.
    public func setupForUploading(uploadExecuterType: UploadExecuterType) {
        guard uploadExecuterAss[self] == nil else { fatalError("Only call `setupForUploading` once per Client.") }

        uploadExecuter = createInitialExecuter(uploadExecuterType: uploadExecuterType)
    }

    private func createInitialExecuter(uploadExecuterType: UploadExecuterType) -> UploadExecuter {
        switch uploadExecuterType {
        case .default:
            return DefaultUploadExecuter(
                sessionConfiguration: session.configuration,
                uploadExecuterDelegate: self
            )

        case .background:
            return BackgroundUploadExecuter(
                sessionConfiguration: session.configuration,
                uploadExecuterDelegate: self
            )

        case let .custom(executerType):
            return executerType.init(
                sessionConfiguration: session.configuration,
                uploadExecuterDelegate: self
            )
        }
    }

    @discardableResult
    public func upload(
        url: URL,
        fileURL: URL,
        progressHandler: UploadHandler.ProgressHandler,
        _ completion: @escaping UploadHandler.CompletionHandler
    ) -> CancellableRequest? {
        let request: URLRequest = .init(url: url, httpMethod: .POST)
        let task = uploadExecuter.upload(request: request, fromFile: fileURL)
        task.flatMap {
            executingUploads[$0.identifier] = UploadHandler(
                progressHandler: progressHandler,
                completionHandler: completion
            )
        }
        return task
    }

    @discardableResult
    public func upload(
        url: URL,
        fileURL: URL,
        multipartType: MultipartType,
        multipartFileContentType: MultipartContentType,
        formData: [String: String],
        progressHandler: UploadHandler.ProgressHandler,
        _ completion: @escaping UploadHandler.CompletionHandler
    ) -> CancellableRequest? {
        let boundary = UUID().uuidString

        guard let multipartData = Data(
                boundary: boundary,
                formData: formData,
                fileURL: fileURL,
                multipartFileContentType: multipartFileContentType
        ) else {
            return nil
        }

        var request: URLRequest = .init(url: url, httpMethod: .POST)
        // TODO: Extract into constants
        request.setValue("\(multipartType.rawValue); boundary=\(boundary)", forHTTPHeaderField: "Content-Type")

        let task = uploadExecuter.upload(request: request, from: multipartData)
        task.flatMap {
            executingUploads[$0.identifier] = UploadHandler(
                progressHandler: progressHandler,
                completionHandler: completion
            )
        }
        return task
    }
}

extension Client: UploadExecuterDelegate {
    public func uploadExecuter(
        _ uploadTask: URLSessionUploadTask,
        didSendBodyData bytesSent: Int64,
        totalBytesSent: Int64,
        totalBytesExpectedToSend: Int64
    ) {
        guard let progressHandler = executingUploads[uploadTask.identifier]?.progressHandler else { return }
        enqueue(progressHandler(totalBytesSent, totalBytesExpectedToSend))
    }

    public func uploadExecuter(didFinishWith uploadTask: URLSessionUploadTask) {
        // TODO handle response before calling the completion
        guard let completionHandler = executingUploads[uploadTask.identifier]?.completionHandler else { return }
        enqueue(completionHandler(uploadTask.response, uploadTask.error))
    }

    public func uploadExecuter(_ uploadTask: URLSessionUploadTask, didCompleteWithError error: Error?) {
        // TODO handle response before calling the completion
        guard let completionHandler = executingUploads[uploadTask.identifier]?.completionHandler else { return }
        enqueue(completionHandler(uploadTask.response, error))
    }
}
