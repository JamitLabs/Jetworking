import Foundation

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
    public func get<ResponseType: Codable>(endpoint: String, _ completion: @escaping (Result<ResponseType, Error>) -> Void) {
        let request: URLRequest = .init(
            url: clientConfiguration.baseURL.appendingPathComponent(endpoint),
            httpMethod: .GET,
            headerFields: getHeaderFields()
        )
        let dataTask = session.dataTask(with: request) { [weak self] data, urlResponse, error in
            if let error = error { return completion(.failure(error)) }

            guard let urlResponse = urlResponse else { return print("URLResonse is nil") }

            self?.handleURLResponse(urlResponse) { result in
                switch result {
                case let .success(header):
                    guard
                        let data = data,
                        let decodedData = try? self?.clientConfiguration.decoder.decode(ResponseType.self, from: data)
                    else { return print("Couldn't decode data") }
                    // Evaluate Header fields

                    completion(.success(decodedData))

                case let .failure(error):
                    break
                }
            }
        }

        dataTask.resume()
    }

    public func post<BodyType: Codable, ResponseType: Codable>(endpoint: String, body: BodyType, _ completion: @escaping (Result<ResponseType, Error>) -> Void) {
        let request: URLRequest = .init(
            url: clientConfiguration.baseURL.appendingPathComponent(endpoint),
            httpMethod: .POST,
            headerFields: getHeaderFields()
        )

        let bodyData: Data = try! clientConfiguration.encoder.encode(body)
        let dataTask = session.uploadTask(with: request, from: bodyData) { [weak self] data, urlResponse, error in
            if let error = error { return completion(.failure(error)) }

            guard let urlResponse = urlResponse else { return print("URLResonse is nil") }

            self?.handleURLResponse(urlResponse) { result in
                switch result {
                case let .success(header):
                    guard
                        let data = data,
                        let decodedData = try? self?.clientConfiguration.decoder.decode(ResponseType.self, from: data)
                    else { return print("Couldn't decode data") }
                    // Evaluate Header fields

                    completion(.success(decodedData))

                case let .failure(error):
                    break
                }
            }
        }

        dataTask.resume()
    }

    public func put<BodyType: Codable, ResponseType: Codable>(endpoint: String, body: BodyType, _ completion: @escaping (Result<ResponseType, Error>) -> Void) {
        let request: URLRequest = .init(
            url: clientConfiguration.baseURL.appendingPathComponent(endpoint),
            httpMethod: .PUT,
            headerFields: getHeaderFields()
        )

        let bodyData: Data = try! clientConfiguration.encoder.encode(body)
        let dataTask = session.uploadTask(with: request, from: bodyData) { [weak self] data, urlResponse, error in
            if let error = error { return completion(.failure(error)) }

            guard let urlResponse = urlResponse else { return print("URLResonse is nil") }

            self?.handleURLResponse(urlResponse) { result in
                switch result {
                case let .success(header):
                    guard
                        let data = data,
                        let decodedData = try? self?.clientConfiguration.decoder.decode(ResponseType.self, from: data)
                    else { return print("Couldn't decode data") }
                    // Evaluate Header fields

                    completion(.success(decodedData))

                case let .failure(error):
                    break
                }
            }
        }

        dataTask.resume()
    }

    public func patch<BodyType: Codable, ResponseType: Codable>(endpoint: String, body: BodyType, _ completion: @escaping (Result<ResponseType, Error>) -> Void) {
        let request: URLRequest = .init(
            url: clientConfiguration.baseURL.appendingPathComponent(endpoint),
            httpMethod: .PATCH,
            headerFields: getHeaderFields()
        )

        let bodyData: Data = try! clientConfiguration.encoder.encode(body)
        let dataTask = session.uploadTask(with: request, from: bodyData) { [weak self] data, urlResponse, error in
            if let error = error { return completion(.failure(error)) }

            guard let urlResponse = urlResponse else { return print("URLResonse is nil") }

            self?.handleURLResponse(urlResponse) { result in
                switch result {
                case let .success(header):
                    guard
                        let data = data,
                        let decodedData = try? self?.clientConfiguration.decoder.decode(ResponseType.self, from: data)
                    else { return print("Couldn't decode data") }
                    // Evaluate Header fields

                    completion(.success(decodedData))

                case let .failure(error):
                    break
                }
            }
        }

        dataTask.resume()
    }

    public func delete<ResponseType: Codable>(endpoint: String, parameter: [String: Any] = [:], _ completion: @escaping (Result<ResponseType, Error>) -> Void) {
        let request: URLRequest = .init(
            url: clientConfiguration.baseURL.appendingPathComponent(endpoint),
            httpMethod: .DELETE,
            headerFields: getHeaderFields()
        )

        let dataTask = session.dataTask(with: request) { [weak self] data, urlResponse, error in
            if let error = error { return completion(.failure(error)) }

            guard let urlResponse = urlResponse else { return print("URLResonse is nil") }

            self?.handleURLResponse(urlResponse) { result in
                switch result {
                case let .success(header):
                    guard
                        let data = data,
                        let decodedData = try? self?.clientConfiguration.decoder.decode(ResponseType.self, from: data)
                    else { return print("Couldn't decode data") }
                    // Evaluate Header fields

                    completion(.success(decodedData))

                case let .failure(error):
                    break
                }
            }
        }

        dataTask.resume()
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

    private func handleURLResponse(_ response: URLResponse, responseHandler: @escaping (Result<[AnyHashable: Any], Error>) -> Void) {
        guard let httpURLResponse = response as? HTTPURLResponse else { return print("Couldn't cast to HTTPURLResponse") }
        let statusCode = HTTPStatusCodeType(statusCode: httpURLResponse.statusCode)

        switch statusCode {
        case .successful:
            responseHandler(.success(httpURLResponse.allHeaderFields))

        default:
            return
        }
    }
}
