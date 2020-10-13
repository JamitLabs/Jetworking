import Foundation

enum APIError: Error {
    case unexpectedError
    case responseMissing
    case decodingError
    case invalidURLComponents
}

public final class Client {
    // MARK: - Properties
    private let clientConfiguration: ClientConfiguration

    private lazy var session: URLSession = .init(
        configuration: .default
    )

    // MARK: - Initialisation
    init(clientConfiguration: ClientConfiguration) {
        self.clientConfiguration = clientConfiguration
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
            let request: URLRequest = try createRequest(forHttpMethod: .POST, and: endpoint)
            let bodyData: Data = try clientConfiguration.encoder.encode(body)
            let dataTask = session.uploadTask(with: request, from: bodyData) { [weak self] data, urlResponse, error in
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
            let request: URLRequest = try createRequest(forHttpMethod: .PUT, and: endpoint)
            let bodyData: Data = try clientConfiguration.encoder.encode(body)
            let dataTask = session.uploadTask(with: request, from: bodyData) { [weak self] data, urlResponse, error in
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
            let request: URLRequest = try createRequest(forHttpMethod: .PATCH, and: endpoint)
            let bodyData: Data = try clientConfiguration.encoder.encode(body)
            let dataTask = session.uploadTask(with: request, from: bodyData) { [weak self] data, urlResponse, error in
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

    private func createRequest<ResponseType>(forHttpMethod httpMethod: HTTPMethod, and endpoint: Endpoint<ResponseType>) throws -> URLRequest {
        let request = URLRequest(
            url: try URLFactory.makeURL(from: endpoint, withBaseURL: clientConfiguration.baseURL),
            httpMethod: httpMethod
        )
        return clientConfiguration.requestInterceptors.reduce(request) { request, interceptor in
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
        if let error = error { return completion(.failure(error)) }

        guard let urlResponse = urlResponse as? HTTPURLResponse else { return completion(.failure(APIError.responseMissing)) }

        let statusCode = HTTPStatusCodeType(statusCode: urlResponse.statusCode)

        switch statusCode {
        case .successful:
            guard
                let data = data,
                let decodedData = try? clientConfiguration.decoder.decode(ResponseType.self, from: data)
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
