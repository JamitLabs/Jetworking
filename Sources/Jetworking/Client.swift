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
        let dataTask = session.dataTask(with: clientConfiguration.baseURL.appendingPathComponent(endpoint)) { [weak self] data, urlResponse, error in
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

    }

    public func put<BodyType: Codable, ResponseType: Codable>(endpoint: String, body: BodyType, _ completion: @escaping (Result<ResponseType, Error>) -> Void) {

    }

    public func patch<BodyType: Codable, ResponseType: Codable>(endpoint: String, body: BodyType, _ completion: @escaping (Result<ResponseType, Error>) -> Void) {

    }

    public func delete<ResponseType: Codable>(endpoint: String, parameter: [String: Any] = [:], _ completion: @escaping (Result<ResponseType, Error>) -> Void) {

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
