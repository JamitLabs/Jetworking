import Foundation

enum APIError: Error {
    case unexpectedError
    case responseMissing
    case decodingError
    case invalidURLComponents
}

public final class Client {
    // MARK: - Properties
    private let configuration: ClientConfiguration

    private lazy var session: URLSession = .init(configuration: .default)

    // MARK: - Initialisation
    /**
     * Initializes a new client instance with a default url session.
     *
     * - Parameter configuration: The client configuration.
     * - Parameter sessionConfiguration: A function to configure the URLSession as inout parameter.
     */
    init(
        configuration: ClientConfiguration,
        sessionConfiguration: ((inout URLSession) -> Void)? = nil
    ) {
        self.configuration = configuration
        sessionConfiguration?(&session)
    }

    // MARK: - Methods
    @discardableResult
    public func get<ResponseType>(endpoint: Endpoint<ResponseType>, _ completion: @escaping (Result<ResponseType, Error>) -> Void) -> CancellableRequest? {
        do {
            let request: URLRequest = try createRequest(forHttpMethod: .GET, and: endpoint)
            let dataTask = session.dataTask(with: request) { [weak self] data, urlResponse, error in
                self?.handleResponse(data: data, urlResponse: urlResponse, error: error, endpoint: endpoint, completion: completion)
            }

            dataTask.resume()

            return dataTask
        } catch {
            completion(.failure(error))
        }

        return nil
    }

    @discardableResult
    public func post<BodyType: Encodable, ResponseType>(endpoint: Endpoint<ResponseType>, body: BodyType, _ completion: @escaping (Result<ResponseType, Error>) -> Void) -> CancellableRequest? {
        do {
            let bodyData: Data = try configuration.encoder.encode(body)
            let request: URLRequest = try createRequest(forHttpMethod: .POST, and: endpoint, and: bodyData)
            let dataTask = session.dataTask(with: request) { [weak self] data, urlResponse, error in
                self?.handleResponse(data: data, urlResponse: urlResponse, error: error, endpoint: endpoint, completion: completion)
            }

            dataTask.resume()

            return dataTask
        } catch {
            completion(.failure(error))
        }

        return nil
    }

    @discardableResult
    public func put<BodyType: Encodable, ResponseType>(endpoint: Endpoint<ResponseType>, body: BodyType, _ completion: @escaping (Result<ResponseType, Error>) -> Void) -> CancellableRequest? {
        do {
            let bodyData: Data = try configuration.encoder.encode(body)
            let request: URLRequest = try createRequest(forHttpMethod: .PUT, and: endpoint, and: bodyData)
            let dataTask = session.dataTask(with: request) { [weak self] data, urlResponse, error in
                self?.handleResponse(data: data, urlResponse: urlResponse, error: error, endpoint: endpoint, completion: completion)
            }

            dataTask.resume()

            return dataTask
        } catch {
            completion(.failure(error))
        }

        return nil
    }

    @discardableResult
    public func patch<BodyType: Encodable, ResponseType>(
        endpoint: Endpoint<ResponseType>,
        body: BodyType,
        _ completion: @escaping (Result<ResponseType, Error>) -> Void
    ) -> CancellableRequest? {
        do {
            let bodyData: Data = try configuration.encoder.encode(body)
            let request: URLRequest = try createRequest(forHttpMethod: .PATCH, and: endpoint, and: bodyData)
            let dataTask = session.dataTask(with: request) { [weak self] data, urlResponse, error in
                self?.handleResponse(data: data, urlResponse: urlResponse, error: error, endpoint: endpoint, completion: completion)
            }

            dataTask.resume()

            return dataTask
        } catch {
            completion(.failure(error))
        }

        return nil
    }

    @discardableResult
    public func delete<ResponseType>(endpoint: Endpoint<ResponseType>, parameter: [String: Any] = [:], _ completion: @escaping (Result<ResponseType, Error>) -> Void) -> CancellableRequest? {
        do {
            let request: URLRequest = try createRequest(forHttpMethod: .DELETE, and: endpoint)
            let dataTask = session.dataTask(with: request) { [weak self] data, urlResponse, error in
                self?.handleResponse(data: data, urlResponse: urlResponse, error: error, endpoint: endpoint, completion: completion)
            }

            dataTask.resume()

            return dataTask
        } catch {
            completion(.failure(error))
        }

        return nil
    }

    private func createRequest<ResponseType>(forHttpMethod httpMethod: HTTPMethod, and endpoint: Endpoint<ResponseType>, and body: Data? = nil) throws -> URLRequest {
        let request = URLRequest(
            url: try URLFactory.makeURL(from: endpoint, withBaseURL: configuration.baseURL),
            httpMethod: httpMethod,
            httpBody: body
        )
        return configuration.requestInterceptors.reduce(request) { request, interceptor in
            return interceptor.intercept(request)
        }
    }

    // TODO: Improve this function (Error handling, evaluation of header fields, status code evalutation, ...)
    private func handleResponse<ResponseType>(
        data: Data?,
        urlResponse: URLResponse?,
        error: Error?,
        endpoint: Endpoint<ResponseType>,
        completion: @escaping (Result<ResponseType, Error>) -> Void
    ) {
        var currentURLResponse = urlResponse
        configuration.responseInterceptors.forEach { component in
            currentURLResponse = component.intercept(data: data, response: currentURLResponse, error: error)
        }

        if let error = error { return completion(.failure(error)) }
        
        guard let urlResponse = urlResponse as? HTTPURLResponse else { return completion(.failure(APIError.responseMissing)) }

        let statusCode = HTTPStatusCodeType(statusCode: urlResponse.statusCode)

        switch statusCode {
        case .successful:
            guard
                let data = data,
                let decodedData = try? configuration.decoder.decode(ResponseType.self, from: data)
            else { return completion(.failure(APIError.decodingError)) }
            // Evaluate Header fields --> urlResponse.allHeaderFields

            completion(.success(decodedData))
            
        case .clientError, .serverError:
            guard let error = error else { return completion(.failure(APIError.unexpectedError)) }

            completion(.failure(error))

        default:
            return
        }
    }
}
