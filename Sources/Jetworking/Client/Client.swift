import Foundation

/// An error occuring  while sending a request
public enum APIError: Error {
    case unexpectedError
    case responseMissing
    case decodingError(Error)
    case clientError(statusCode: Int, error: Error?, body: Data?)
    case serverError(statusCode: Int, error: Error?, body: Data?)
    case missingResponseBody
    case invalidURLComponents
}

public final class Client {
    public typealias RequestResult<ResponseType> = (HTTPURLResponse?, Result<ResponseType, Error>)
    public typealias RequestCompletion<ResponseType> = (HTTPURLResponse?, Result<ResponseType, Error>) -> Void

    // MARK: - Properties
    private lazy var sessionCache: SessionCache = .init(configuration: configuration)

    private let configuration: Configuration

    private let session: URLSession
    private lazy var responseHandler: ResponseHandler = .init(configuration: configuration)

    private lazy var requestExecuter: RequestExecuter = {
        switch configuration.requestExecuterType {
        case .sync:
            return SyncRequestExecuter(session: session)

        case .async:
            return AsyncRequestExecuter(session: session)

        case let .custom(executerType):
            return executerType.init(session: session)
        }
    }()

    private var executingDownloads: [Int: DownloadHandler] = [:]
    private lazy var downloadExecuter: DownloadExecuter = {
        switch configuration.downloadExecuterType {
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
    }()

    private var executingUploads: [Int: UploadHandler] = [:]
    private lazy var uploadExecuter: UploadExecuter = {
        switch configuration.uploadExecuterType {
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
    }()

    // MARK: - Initialisation
    /**
     * Initialises a new client instance with a default url session.
     *
     * - Parameter configuration: The client configuration.
     * - Parameter session: The URLSession which is used for executing requests
     */
    public init(
        configuration: Configuration,
        session: URLSession = .init(configuration: .default)
    ) {
        self.configuration = configuration
        self.session = session
    }

    // MARK: - Methods
    @discardableResult
    public func get<ResponseType: Decodable>(
        endpoint: Endpoint<ResponseType>,
        andAdditionalHeaderFields additionalHeaderFields: [String: String] = [:],
        _ completion: @escaping RequestCompletion<ResponseType>
    ) -> CancellableRequest? {
        do {
            let request: URLRequest = try createRequest(
                forHttpMethod: .GET,
                and: endpoint,
                andAdditionalHeaderFields: additionalHeaderFields
            )
            return requestExecuter.send(request: request) { [weak self] data, urlResponse, error in
                guard let self = self else { return }

                self.responseHandler.handleDecodableResponse(
                    data: data,
                    urlResponse: urlResponse,
                    error: error,
                    endpoint: endpoint,
                    completion: completion
                )
            }
        } catch {
            enqueue(completion(nil, .failure(error)))
        }

        return nil
    }

    @available(iOS 15.0, macOS 12.0, *)
    public func get<ResponseType: Decodable>(
        endpoint: Endpoint<ResponseType>,
        andAdditionalHeaderFields additionalHeaderFields: [String: String] = [:]
    ) async -> RequestResult<ResponseType> {
        do {
            let request: URLRequest = try createRequest(
                forHttpMethod: .GET,
                and: endpoint,
                andAdditionalHeaderFields: additionalHeaderFields
            )

            let (data, urlResponse) = try await requestExecuter.send(request: request, delegate: nil)
            return await responseHandler.handleDecodableResponse(
                data: data,
                urlResponse: urlResponse,
                endpoint: endpoint
            )
        } catch {
            return (nil, .failure(error))
        }
    }

    @discardableResult
    public func post<BodyType: Encodable, ResponseType: Decodable>(
        endpoint: Endpoint<ResponseType>,
        body: BodyType,
        andAdditionalHeaderFields additionalHeaderFields: [String: String] = [:],
        _ completion: @escaping RequestCompletion<ResponseType>
    ) -> CancellableRequest? {
        do {
            let encoder: Encoder = endpoint.encoder ?? configuration.encoder
            let bodyData: Data = try encoder.encode(body)
            let request: URLRequest = try createRequest(
                forHttpMethod: .POST,
                and: endpoint,
                and: bodyData,
                andAdditionalHeaderFields: additionalHeaderFields
            )
            return requestExecuter.send(request: request) { [weak self] data, urlResponse, error in
                guard let self = self else { return }

                self.responseHandler.handleDecodableResponse(
                    data: data,
                    urlResponse: urlResponse,
                    error: error,
                    endpoint: endpoint,
                    completion: completion
                )
            }
        } catch {
            enqueue(completion(nil, .failure(error)))
        }

        return nil
    }

    @available(iOS 15.0, macOS 12.0, *)
    @discardableResult
    public func post<BodyType: Encodable, ResponseType: Decodable>(
        endpoint: Endpoint<ResponseType>,
        body: BodyType,
        andAdditionalHeaderFields additionalHeaderFields: [String: String] = [:]
    ) async -> RequestResult<ResponseType> {
        do {
            let encoder: Encoder = endpoint.encoder ?? configuration.encoder
            let bodyData: Data = try encoder.encode(body)
            let request: URLRequest = try createRequest(
                forHttpMethod: .POST,
                and: endpoint,
                and: bodyData,
                andAdditionalHeaderFields: additionalHeaderFields
            )

            let (data, urlResponse) = try await requestExecuter.send(request: request, delegate: nil)
            return await responseHandler.handleDecodableResponse(
                data: data,
                urlResponse: urlResponse,
                endpoint: endpoint
            )
        } catch {
            return (nil, .failure(error))
        }
    }

    @discardableResult
    public func post<ResponseType>(
        endpoint: Endpoint<ResponseType>,
        body: ExpressibleByNilLiteral? = nil,
        andAdditionalHeaderFields additionalHeaderFields: [String: String] = [:],
        _ completion: @escaping RequestCompletion<ResponseType>
    ) -> CancellableRequest? {
        do {
            let request: URLRequest = try createRequest(
                forHttpMethod: .POST,
                and: endpoint,
                andAdditionalHeaderFields: additionalHeaderFields
            )
            return requestExecuter.send(request: request) { [weak self] data, urlResponse, error in
                guard let self = self else { return }

                self.responseHandler.handleVoidResponse(
                    data: data,
                    urlResponse: urlResponse,
                    error: error,
                    endpoint: endpoint,
                    completion: completion
                )
            }
        } catch {
            enqueue(completion(nil, .failure(error)))
        }

        return nil
    }

    @available(iOS 15.0, macOS 12.0, *)
    @discardableResult
    public func post<ResponseType: Decodable>(
        endpoint: Endpoint<ResponseType>,
        body: ExpressibleByNilLiteral? = nil,
        andAdditionalHeaderFields additionalHeaderFields: [String: String] = [:]
    ) async -> RequestResult<ResponseType> {
        do {
            let request: URLRequest = try createRequest(
                forHttpMethod: .POST,
                and: endpoint,
                andAdditionalHeaderFields: additionalHeaderFields
            )

            let (data, urlResponse) = try await requestExecuter.send(request: request, delegate: nil)
            return await responseHandler.handleDecodableResponse(
                data: data,
                urlResponse: urlResponse,
                endpoint: endpoint
            )
        } catch {
            return (nil, .failure(error))
        }
    }

    @discardableResult
    public func put<BodyType: Encodable, ResponseType: Decodable>(
        endpoint: Endpoint<ResponseType>,
        body: BodyType,
        andAdditionalHeaderFields additionalHeaderFields: [String: String] = [:],
        _ completion: @escaping RequestCompletion<ResponseType>
    ) -> CancellableRequest? {
        do {
            let encoder: Encoder = endpoint.encoder ?? configuration.encoder
            let bodyData: Data = try encoder.encode(body)
            let request: URLRequest = try createRequest(
                forHttpMethod: .PUT,
                and: endpoint,
                and: bodyData,
                andAdditionalHeaderFields: additionalHeaderFields
            )
            return requestExecuter.send(request: request) { [weak self] data, urlResponse, error in
                guard let self = self else { return }

                self.responseHandler.handleDecodableResponse(
                    data: data,
                    urlResponse: urlResponse,
                    error: error,
                    endpoint: endpoint,
                    completion: completion
                )
            }
        } catch {
            enqueue(completion(nil, .failure(error)))
        }

        return nil
    }

    @available(iOS 15.0, macOS 12.0, *)
    @discardableResult
    public func put<BodyType: Encodable, ResponseType: Decodable>(
        endpoint: Endpoint<ResponseType>,
        body: BodyType,
        andAdditionalHeaderFields additionalHeaderFields: [String: String] = [:]
    ) async -> RequestResult<ResponseType> {
        do {
            let encoder: Encoder = endpoint.encoder ?? configuration.encoder
            let bodyData: Data = try encoder.encode(body)
            let request: URLRequest = try createRequest(
                forHttpMethod: .PUT,
                and: endpoint,
                and: bodyData,
                andAdditionalHeaderFields: additionalHeaderFields
            )

            let (data, urlResponse) = try await requestExecuter.send(request: request, delegate: nil)
            return await responseHandler.handleDecodableResponse(
                data: data,
                urlResponse: urlResponse,
                endpoint: endpoint
            )
        } catch {
            return (nil, .failure(error))
        }
    }

    @discardableResult
    public func patch<BodyType: Encodable, ResponseType: Decodable>(
        endpoint: Endpoint<ResponseType>,
        body: BodyType,
        andAdditionalHeaderFields additionalHeaderFields: [String: String] = [:],
        _ completion: @escaping RequestCompletion<ResponseType>
    ) -> CancellableRequest? {
        do {
            let encoder: Encoder = endpoint.encoder ?? configuration.encoder
            let bodyData: Data = try encoder.encode(body)
            let request: URLRequest = try createRequest(
                forHttpMethod: .PATCH,
                and: endpoint,
                and: bodyData,
                andAdditionalHeaderFields: additionalHeaderFields
            )
            return requestExecuter.send(request: request) { [weak self] data, urlResponse, error in
                guard let self = self else { return }

                self.responseHandler.handleDecodableResponse(
                    data: data,
                    urlResponse: urlResponse,
                    error: error,
                    endpoint: endpoint,
                    completion: completion
                )
            }
        } catch {
            enqueue(completion(nil, .failure(error)))
        }

        return nil
    }

    @available(iOS 15.0, macOS 12.0, *)
    @discardableResult
    public func patch<BodyType: Encodable, ResponseType: Decodable>(
        endpoint: Endpoint<ResponseType>,
        body: BodyType,
        andAdditionalHeaderFields additionalHeaderFields: [String: String] = [:]
    ) async -> RequestResult<ResponseType> {
        do {
            let encoder: Encoder = endpoint.encoder ?? configuration.encoder
            let bodyData: Data = try encoder.encode(body)
            let request: URLRequest = try createRequest(
                forHttpMethod: .PATCH,
                and: endpoint,
                and: bodyData,
                andAdditionalHeaderFields: additionalHeaderFields
            )

            let (data, urlResponse) = try await requestExecuter.send(request: request, delegate: nil)
            return await responseHandler.handleDecodableResponse(
                data: data,
                urlResponse: urlResponse,
                endpoint: endpoint
            )
        } catch {
            return (nil, .failure(error))
        }
    }

    @discardableResult
    public func delete<ResponseType: Decodable>(
        endpoint: Endpoint<ResponseType>,
        parameter: [String: Any] = [:],
        andAdditionalHeaderFields additionalHeaderFields: [String: String] = [:],
        _ completion: @escaping RequestCompletion<ResponseType>
    ) -> CancellableRequest? {
        do {
            let request: URLRequest = try createRequest(
                forHttpMethod: .DELETE,
                and: endpoint,
                andAdditionalHeaderFields: additionalHeaderFields
            )
            return requestExecuter.send(request: request) { [weak self] data, urlResponse, error in
                guard let self = self else { return }

                self.responseHandler.handleDecodableResponse(
                    data: data,
                    urlResponse: urlResponse,
                    error: error,
                    endpoint: endpoint,
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
        return requestExecuter.send(request: request, completion)
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

    private func checkForValidDownloadURL(_ url: URL) -> Bool {
        guard let scheme = URLComponents(string: url.absoluteString)?.scheme else { return false }

        return scheme == "http" || scheme == "https"
    }

    private func createRequest<ResponseType>(
        forHttpMethod httpMethod: HTTPMethod,
        and endpoint: Endpoint<ResponseType>,
        and body: Data? = nil,
        andAdditionalHeaderFields additionalHeaderFields: [String: String]
    ) throws -> URLRequest {
        var request = URLRequest(
            url: try URLFactory.makeURL(from: endpoint, withBaseURL: configuration.baseURLProvider.baseURL),
            httpMethod: httpMethod,
            httpBody: body
        )

        var requestInterceptors: [Interceptor] = configuration.interceptors

        // Extra case: POST-request with empty content
        //
        // Adds custom interceptor after last interceptor for header fields
        // to avoid conflict with other custom interceptor if any.
        if body == nil && httpMethod == .POST {
            let targetIndex = requestInterceptors.lastIndex { $0 is HeaderFieldsInterceptor }
            let indexToInsert = targetIndex.flatMap { requestInterceptors.index(after: $0) }
            requestInterceptors.insert(
                EmptyContentHeaderFieldsInterceptor(),
                at: indexToInsert ?? requestInterceptors.endIndex
            )
        }

        // Append additional header fields.
        additionalHeaderFields.forEach { key, value in
            request.addValue(value, forHTTPHeaderField: key)
        }

        return requestInterceptors.reduce(request) { request, interceptor in
            return interceptor.intercept(request)
        }
    }

    private func enqueue(_ completion: @escaping @autoclosure () -> Void) {
        configuration.responseQueue.async {
            completion()
        }
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
