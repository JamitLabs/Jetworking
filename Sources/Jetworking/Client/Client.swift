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
    public typealias RequestCompletion<ResponseType> = (HTTPURLResponse?, Result<ResponseType, Error>) -> Void
    
    // MARK: - Properties
    public lazy var sessionCache: SessionCache = .init(configuration: configuration)

    public let configuration: Configuration

    public let session: URLSession
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

    /// Perform something on the configuration's response queue.
    public func enqueue(_ completion: @escaping @autoclosure () -> Void) {
        configuration.responseQueue.async {
            completion()
        }
    }
}
