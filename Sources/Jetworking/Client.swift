import Foundation

public final class Client {
    // MARK: - Properties
    private let clientConfiguration: ClientConfiguration

    // MARK: - Initialisation
    init(clientConfiguration: ClientConfiguration) {
        self.clientConfiguration = clientConfiguration
    }

    // MARK: - Methods
    public func get<ResponseType: Codable>(endpoint: String, _ completion: @escaping (Result<ResponseType, Error>) -> Void) {
    }

    public func post<BodyType: Codable, ResponseType: Codable>(endpoint: String, body: BodyType, _ completion: @escaping (Result<ResponseType, Error>) -> Void) {

    }

    public func put<BodyType: Codable, ResponseType: Codable>(endpoint: String, body: BodyType, _ completion: @escaping (Result<ResponseType, Error>) -> Void) {

    }

    public func patch<BodyType: Codable, ResponseType: Codable>(endpoint: String, body: BodyType, _ completion: @escaping (Result<ResponseType, Error>) -> Void) {

    }

    public func delete<ResponseType: Codable>(endpoint: String, parameter: [String: Any] = [:], _ completion: @escaping (Result<ResponseType, Error>) -> Void) {

    }
}
