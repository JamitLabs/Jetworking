import Foundation

enum APIError: Error {
    case unexpectedError
    case responseMissing
    case decodingError
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
    public func get<ResponseType>(endpoint: Endpoint<ResponseType>, _ completion: @escaping (Result<ResponseType, Error>) -> Void) {
        let request: URLRequest = createRequest(forHttpMethod: .GET, andPathComponent: endpoint.pathComponent)
        let dataTask = session.dataTask(with: request) { [weak self] data, urlResponse, error in
            self?.handleResponse(data: data, urlResponse: urlResponse, error: error, endpoint: endpoint, completion: completion)
        }

        dataTask.resume()
    }

    public func post<BodyType: Encodable, ResponseType>(endpoint: Endpoint<ResponseType>, body: BodyType, _ completion: @escaping (Result<ResponseType, Error>) -> Void) {
        let request: URLRequest = createRequest(forHttpMethod: .POST, andPathComponent: endpoint.pathComponent)
        let bodyData: Data = try! clientConfiguration.encoder.encode(body) // TODO: remove force unwrap --> Error handling
        let dataTask = session.uploadTask(with: request, from: bodyData) { [weak self] data, urlResponse, error in
            self?.handleResponse(data: data, urlResponse: urlResponse, error: error, endpoint: endpoint, completion: completion)
        }

        dataTask.resume()
    }

    public func put<BodyType: Encodable, ResponseType>(endpoint: Endpoint<ResponseType>, body: BodyType, _ completion: @escaping (Result<ResponseType, Error>) -> Void) {
        let request: URLRequest = createRequest(forHttpMethod: .PUT, andPathComponent: endpoint.pathComponent)
        let bodyData: Data = try! clientConfiguration.encoder.encode(body) // TODO: remove force unwrap --> Error handling
        let dataTask = session.uploadTask(with: request, from: bodyData) { [weak self] data, urlResponse, error in
            self?.handleResponse(data: data, urlResponse: urlResponse, error: error, endpoint: endpoint, completion: completion)
        }

        dataTask.resume()
    }

    public func patch<BodyType: Encodable, ResponseType>(endpoint: Endpoint<ResponseType>, body: BodyType, _ completion: @escaping (Result<ResponseType, Error>) -> Void) {
        let request: URLRequest = createRequest(forHttpMethod: .PATCH, andPathComponent: endpoint.pathComponent)
        let bodyData: Data = try! clientConfiguration.encoder.encode(body) // TODO: remove force unwrap --> Error handling
        let dataTask = session.uploadTask(with: request, from: bodyData) { [weak self] data, urlResponse, error in
            self?.handleResponse(data: data, urlResponse: urlResponse, error: error, endpoint: endpoint, completion: completion)
        }

        dataTask.resume()
    }

    public func delete<ResponseType>(endpoint: Endpoint<ResponseType>, parameter: [String: Any] = [:], _ completion: @escaping (Result<ResponseType, Error>) -> Void) {
        let request: URLRequest = createRequest(forHttpMethod: .DELETE, andPathComponent: endpoint.pathComponent)
        let dataTask = session.dataTask(with: request) { [weak self] data, urlResponse, error in
            self?.handleResponse(data: data, urlResponse: urlResponse, error: error, endpoint: endpoint, completion: completion)
        }

        dataTask.resume()
    }

    private func createRequest(forHttpMethod httpMethod: HTTPMethod, andPathComponent pathComponent: String) -> URLRequest {
        return .init(
            url: clientConfiguration.baseURL.appendingPathComponent(pathComponent),
            httpMethod: httpMethod,
            headerFields: getHeaderFields()
        )
    }

    private func getHeaderFields() -> [String: String] {
        var headerFields: [String: String] = [
            "Accept": "application/json",
            "Content-Type": "application/json"
        ]

        if
            let authorizationHeader: [String: String] = getAuthorizationHeader(),
            let authorizationKey = authorizationHeader.keys.first,
            let authorizationValue = authorizationHeader.values.first
        {
            headerFields[authorizationKey] = authorizationValue
        }

        return headerFields
    }

    private func getAuthorizationHeader() -> [String: String]? {
        let authorizationHeaderKey: String = "Authorization"

        switch clientConfiguration.authenticationMethod {
        case .none:
            return nil

        case let .basicAuthentication(username, password):
            var authString: String = ""
            let credentialsString = "\(username):\(password)"
            if let credentialsData = credentialsString.data(using: .utf8) {
                let base64Credentials = credentialsData.base64EncodedString(options: [])
                authString = "Basic \(base64Credentials)"
            }

            return [authorizationHeaderKey: authString]

        case let .bearerToken(token):
            return [authorizationHeaderKey: "Bearer \(token)"]

        case let .custom(headerKey, headerValue):
            return [headerKey: headerValue]
        }
    }

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
