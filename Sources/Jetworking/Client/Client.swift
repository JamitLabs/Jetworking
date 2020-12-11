import Foundation

enum APIError: Error {
    case unexpectedError
    case responseMissing
    case decodingError
    case invalidURLComponents
}

public final class Client {
    public typealias RequestCompletion<ResponseType> = (HTTPURLResponse?, Result<ResponseType, Error>) -> Void
    private typealias SuccessHandler<ResponseType> = (HTTPURLResponse, Endpoint<ResponseType>?, Data?, @escaping RequestCompletion<ResponseType>) -> Void
    // MARK: - Properties
    private lazy var sessionCache: SessionCache = .init(configuration: configuration)

    private let configuration: Configuration

    private lazy var session: URLSession = .init(configuration: .default)

    private lazy var requestExecutor: RequestExecutor = {
        switch configuration.requestExecutorType {
        case .sync:
            return SyncRequestExecutor(session: session)

        case .async:
            return AsyncRequestExecutor(session: session)

        case let .custom(executorType):
            return executorType.init(session: session)
        }
    }()

    private var executingDownloads: [Int: DownloadHandler] = [:]
    private lazy var downloadExecutor: DownloadExecutor = {
        switch configuration.downloadExecutorType {
        case .default:
            return DefaultDownloadExecutor(
                sessionConfiguration: session.configuration,
                downloadExecutorDelegate: self
            )

        case .background:
            return BackgroundDownloadExecutor(
                sessionConfiguration: session.configuration,
                downloadExecutorDelegate: self
            )

        case let .custom(executorType):
            return executorType.init(
                sessionConfiguration: session.configuration,
                downloadExecutorDelegate: self
            )
        }
    }()

    private var executingUploads: [Int: UploadHandler] = [:]
    private lazy var uploadExecutor: UploadExecutor = {
        switch configuration.uploadExecutorType {
        case .default:
            return DefaultUploadExecutor(
                sessionConfiguration: session.configuration,
                uploadExecutorDelegate: self
            )

        case .background:
            return BackgroundUploadExecutor(
                sessionConfiguration: session.configuration,
                uploadExecutorDelegate: self
            )

        case let .custom(executorType):
            return executorType.init(
                sessionConfiguration: session.configuration,
                uploadExecutorDelegate: self
            )
        }
    }()

    // MARK: - Initialisation
    /**
     * Initialises a new client instance with a default url session.
     *
     * - Parameter configuration: The client configuration.
     * - Parameter sessionConfiguration: A function to configure the URLSession as inout parameter.
     */
    public init(
        configuration: Configuration,
        sessionConfiguration: ((inout URLSession) -> Void)? = nil
    ) {
        self.configuration = configuration
        sessionConfiguration?(&session)
    }

    // MARK: - Methods
    @discardableResult
    public func get<ResponseType: Decodable>(endpoint: Endpoint<ResponseType>, _ completion: @escaping RequestCompletion<ResponseType>) -> CancellableRequest? {
        do {
            let request: URLRequest = try createRequest(forHttpMethod: .GET, and: endpoint)
            return requestExecutor.send(request: request) { [weak self] data, urlResponse, error in
                guard let self = self else { return }
                self.handleResponse(
                    data: data,
                    urlResponse: urlResponse,
                    error: error,
                    endpoint: endpoint,
                    successHandler: self.handleSuccessDecodable,
                    completion: completion
                )
            }
        } catch {
            enqueue(completion(nil, .failure(error)))
        }

        return nil
    }

    @discardableResult
    public func post<BodyType: Encodable, ResponseType: Decodable>(endpoint: Endpoint<ResponseType>, body: BodyType, _ completion: @escaping RequestCompletion<ResponseType>) -> CancellableRequest? {
        do {
            let encoder: Encoder = endpoint.encoder ?? configuration.encoder
            let bodyData: Data = try encoder.encode(body)
            let request: URLRequest = try createRequest(forHttpMethod: .POST, and: endpoint, and: bodyData)
            return requestExecutor.send(request: request) { [weak self] data, urlResponse, error in
                guard let self = self else { return }

                self.handleResponse(
                    data: data,
                    urlResponse: urlResponse,
                    error: error,
                    endpoint: endpoint,
                    successHandler: self.handleSuccessDecodable,
                    completion: completion
                )
            }
        } catch {
            enqueue(completion(nil, .failure(error)))
        }

        return nil
    }

    @discardableResult
    public func post<ResponseType>(endpoint: Endpoint<ResponseType>, body: ExpressibleByNilLiteral? = nil, _ completion: @escaping RequestCompletion<ResponseType>) -> CancellableRequest? {
        do {
            let request: URLRequest = try createRequest(forHttpMethod: .POST, and: endpoint)
            return requestExecutor.send(request: request) { [weak self] data, urlResponse, error in
                guard let self = self else { return }

                self.handleResponse(
                    data: data,
                    urlResponse: urlResponse,
                    error: error,
                    endpoint: endpoint,
                    successHandler: self.handleSuccessVoid,
                    completion: completion
                )
            }
        } catch {
            enqueue(completion(nil, .failure(error)))
        }

        return nil
    }

    @discardableResult
    public func put<BodyType: Encodable, ResponseType: Decodable>(endpoint: Endpoint<ResponseType>, body: BodyType, _ completion: @escaping RequestCompletion<ResponseType>) -> CancellableRequest? {
        do {
            let encoder: Encoder = endpoint.encoder ?? configuration.encoder
            let bodyData: Data = try encoder.encode(body)
            let request: URLRequest = try createRequest(forHttpMethod: .PUT, and: endpoint, and: bodyData)
            return requestExecutor.send(request: request) { [weak self] data, urlResponse, error in
                guard let self = self else { return }

                self.handleResponse(
                    data: data,
                    urlResponse: urlResponse,
                    error: error,
                    endpoint: endpoint,
                    successHandler: self.handleSuccessDecodable,
                    completion: completion
                )
            }
        } catch {
            enqueue(completion(nil, .failure(error)))
        }

        return nil
    }

    @discardableResult
    public func patch<BodyType: Encodable, ResponseType: Decodable>(
        endpoint: Endpoint<ResponseType>,
        body: BodyType,
        _ completion: @escaping RequestCompletion<ResponseType>
    ) -> CancellableRequest? {
        do {
            let encoder: Encoder = endpoint.encoder ?? configuration.encoder
            let bodyData: Data = try encoder.encode(body)
            let request: URLRequest = try createRequest(forHttpMethod: .PATCH, and: endpoint, and: bodyData)
            return requestExecutor.send(request: request) { [weak self] data, urlResponse, error in
                guard let self = self else { return }

                self.handleResponse(
                    data: data,
                    urlResponse: urlResponse,
                    error: error,
                    endpoint: endpoint,
                    successHandler: self.handleSuccessDecodable,
                    completion: completion
                )
            }
        } catch {
            enqueue(completion(nil, .failure(error)))
        }

        return nil
    }

    @discardableResult
    public func delete<ResponseType: Decodable>(endpoint: Endpoint<ResponseType>, parameter: [String: Any] = [:], _ completion: @escaping RequestCompletion<ResponseType>) -> CancellableRequest? {
        do {
            let request: URLRequest = try createRequest(forHttpMethod: .DELETE, and: endpoint)
            return requestExecutor.send(request: request) { [weak self] data, urlResponse, error in
                guard let self = self else { return }

                self.handleResponse(
                    data: data,
                    urlResponse: urlResponse,
                    error: error,
                    endpoint: endpoint,
                    successHandler: self.handleSuccessDecodable,
                    completion: completion
                )
            }
        } catch {
            enqueue(completion(nil, .failure(error)))
        }

        return nil
    }

    @discardableResult
    public func send(request: URLRequest, _ completion: @escaping (Data?, URLResponse?, Error?) -> Void) -> CancellableRequest? {
        return requestExecutor.send(request: request, completion)
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
            let task = downloadExecutor.download(request: request)
            task.flatMap {
                executingDownloads[$0.identifier] = DownloadHandler(
                    progressHandler: progressHandler,
                    completionHandler: completion
                )
            }

            return task
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
        let task = uploadExecutor.upload(request: request, fromFile: fileURL)
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

        let task = uploadExecutor.upload(request: request, from: multipartData)
        task.flatMap {
            executingUploads[$0.identifier] = UploadHandler(
                progressHandler: progressHandler,
                completionHandler: completion
            )
        }
        return task
    }
    
    private func checkForValidDownloadURL(_ url: URL) -> Bool {
        guard let scheme = URLComponents(string: url.absoluteString)?.scheme else { return false }

        return scheme == "http" || scheme == "https"
    }

    private func createRequest<ResponseType>(
        forHttpMethod httpMethod: HTTPMethod,
        and endpoint: Endpoint<ResponseType>,
        and body: Data? = nil
    ) throws -> URLRequest {
        let request = URLRequest(
            url: try URLFactory.makeURL(from: endpoint, withBaseURL: configuration.baseURL),
            httpMethod: httpMethod,
            httpBody: body
        )

        var requestInterceptors: [RequestInterceptor] = configuration.requestInterceptors

        // Extra case: POST-request with empty content
        //
        // Adds custom interceptor after last interceptor for header fields
        // to avoid conflict with other custom interceptor if any.
        if body == nil && httpMethod == .POST {
            let targetIndex = requestInterceptors.lastIndex { $0 is HeaderFieldsRequestInterceptor }
            let indexToInsert = targetIndex.flatMap { requestInterceptors.index(after: $0) }
            requestInterceptors.insert(
                EmptyContentHeaderFieldsRequestInterceptor(),
                at: indexToInsert ?? requestInterceptors.endIndex
            )
        }

        return requestInterceptors.reduce(request) { request, interceptor in
            return interceptor.intercept(request)
        }
    }

    // TODO: Improve this function (Error handling, evaluation of header fields, status code evalutation, ...)
    private func handleResponse<ResponseType>(
        data: Data?,
        urlResponse: URLResponse?,
        error: Error?,
        endpoint: Endpoint<ResponseType>? = nil,
        successHandler: @escaping SuccessHandler<ResponseType>,
        completion: @escaping RequestCompletion<ResponseType>
    ) {
        let interceptedResponse = configuration.responseInterceptors.reduce(urlResponse) { response, component in
            return component.intercept(data: data, response: response, error: error)
        }

        guard let currentURLResponse = interceptedResponse as? HTTPURLResponse else {
            return enqueue(completion(nil, .failure(error ?? APIError.responseMissing)))
        }

        if let error = error { return enqueue(completion(currentURLResponse, .failure(error))) }

        switch HTTPStatusCodeType(statusCode: currentURLResponse.statusCode) {
        case .successful:
            successHandler(currentURLResponse, endpoint, data, completion)

        case .clientError, .serverError:
            guard let error = error else { return completion(currentURLResponse, .failure(APIError.unexpectedError)) }

            enqueue(completion(currentURLResponse, .failure(error)))

        default:
            return
        }
    }

    private func handleSuccessVoid<ResponseType>(currentURLResponse: HTTPURLResponse, endpoint: Endpoint<ResponseType>?, data: Data?, completion: @escaping RequestCompletion<ResponseType>) {
        if ResponseType.self is Void.Type {
            return enqueue(completion(currentURLResponse, .success(() as! ResponseType)))
        }

        enqueue(completion(currentURLResponse, .failure(APIError.unexpectedError)))
    }

    func handleSuccessDecodable<ResponseType: Decodable>(currentURLResponse: HTTPURLResponse, endpoint: Endpoint<ResponseType>?, data: Data?, completion: @escaping RequestCompletion<ResponseType>) {
        let decoder: Decoder = endpoint?.decoder ?? configuration.decoder

        guard let decodedData = try? decodeResponse(ResponseType.self, with: decoder, from: data) else {
            return enqueue(completion(currentURLResponse, .failure(APIError.decodingError)))
        }
        // Evaluate Header fields --> urlResponse.allHeaderFields

        enqueue(completion(currentURLResponse, .success(decodedData)))
    }

    private func enqueue(_ completion: @escaping @autoclosure () -> Void) {
        configuration.responseQueue.async {
            completion()
        }
    }

    /// Decodes an instance of the given type.
    private func decodeResponse<ResponseType>(_ dataType: ResponseType.Type, with decoder: Decoder, from data: Data?) throws -> ResponseType where ResponseType: Decodable {
        guard let data = data else { throw APIError.decodingError }

        return try decoder.decode(dataType, from: data)
    }
}

extension Client: DownloadExecutorDelegate {
    public func downloadExecutor(
        _ downloadTask: URLSessionDownloadTask,
        didWriteData bytesWritten: Int64,
        totalBytesWritten: Int64,
        totalBytesExpectedToWrite: Int64
    ) {
        guard let progressHandler = executingDownloads[downloadTask.identifier]?.progressHandler else { return }
        enqueue(progressHandler(totalBytesWritten, totalBytesExpectedToWrite))
    }

    public func downloadExecutor(_ downloadTask: URLSessionDownloadTask, didFinishDownloadingTo location: URL) {
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

    public func downloadExecutor(_ downloadTask: URLSessionDownloadTask, didCompleteWithError error: Error?) {
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

extension Client: UploadExecutorDelegate {
    public func uploadExecutor(
        _ uploadTask: URLSessionUploadTask,
        didSendBodyData bytesSent: Int64,
        totalBytesSent: Int64,
        totalBytesExpectedToSend: Int64
    ) {
        guard let progressHandler = executingUploads[uploadTask.identifier]?.progressHandler else { return }
        enqueue(progressHandler(totalBytesSent, totalBytesExpectedToSend))
    }
    
    public func uploadExecutor(didFinishWith uploadTask: URLSessionUploadTask) {
        // TODO handle response before calling the completion
        guard let completionHandler = executingUploads[uploadTask.identifier]?.completionHandler else { return }
        enqueue(completionHandler(uploadTask.response, uploadTask.error))
    }
    
    public func uploadExecutor(_ uploadTask: URLSessionUploadTask, didCompleteWithError error: Error?) {
        // TODO handle response before calling the completion
        guard let completionHandler = executingUploads[uploadTask.identifier]?.completionHandler else { return }
        enqueue(completionHandler(uploadTask.response, error))
    }
}
