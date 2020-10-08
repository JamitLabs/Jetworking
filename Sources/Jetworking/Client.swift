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
        let url = clientConfiguration.baseURL.appendingPathComponent(endpoint)
        let request: URLRequest = .init(url: url, clientConfiguration: clientConfiguration)
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
        var request: URLRequest = .init(url: clientConfiguration.baseURL.appendingPathComponent(endpoint))
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

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
        var request: URLRequest = .init(url: clientConfiguration.baseURL.appendingPathComponent(endpoint))
        request.httpMethod = "PUT"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

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
        var request: URLRequest = .init(url: clientConfiguration.baseURL.appendingPathComponent(endpoint))
        request.httpMethod = "PATCH"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

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
        var request: URLRequest = .init(url: clientConfiguration.baseURL.appendingPathComponent(endpoint))
        request.httpMethod = "DELETE"

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
