// Copyright © 2022 Jamit Labs GmbH. All rights reserved.

import Combine
import Foundation
import Jetworking

var cancellables: Set<AnyCancellable> = .init()

/// This is a helper class that wraps a `Client` instance
public final class ExampleClient {
    // MARK: - Properties
    static let `default`: ExampleClient = .init(baseURL: URL(string: "https://jsonplaceholder.typicode.com")!)

    private let httpClient: Client

    // MARK: - Initializers
    init(baseURL: URL) {
        let configuration: Configuration = .init(
            baseURLProvider: baseURL,
            interceptors: [
                // LoggingInterceptor(),
                StatusCodeLoggingInterceptor(),
                AuthenticationInterceptor(authenticationMethod: .bearerToken(token: "exampleToken"))
            ]
        )

        let urlSessionConfiguration: URLSessionConfiguration = .default
        urlSessionConfiguration.timeoutIntervalForRequest = 60
        urlSessionConfiguration.timeoutIntervalForResource = 60

        let session: URLSession = .init(
            configuration: urlSessionConfiguration,
            delegate: nil,
            delegateQueue: nil
        )

        httpClient = .init(configuration: configuration, session: session)
    }

    // MARK: - Methods: Completion Handler Variants
    func getAllTodos(completion: @escaping Client.RequestCompletion<[Todo]>) {
        httpClient.get(endpoint: Endpoints.todos, completion)
    }

    func getSingleTodo(id: Int, completion: @escaping Client.RequestCompletion<Todo>) {
        httpClient.get(endpoint: Endpoints.todo(id: id), completion)
    }

    func deleteSingleTodo(id: Int, completion: @escaping Client.RequestCompletion<Jetworking.Empty>) {
        httpClient.delete(endpoint: Endpoints.todoDelete(id: id), completion)
    }

    // MARK: Combine Variants
    func getAllTodos() -> AnyPublisher<[Todo], Error> {
        var request: CancellableRequest?

        return Future { [weak self] promise in
            request = self?.httpClient.get(endpoint: Endpoints.todos) { _, result in
                promise(result)
            }
        }
        .mapError { (error: Error) -> Error in
            if case APIError.clientError(statusCode: 401, error: _, body: _) = error {
                // Here it is e. g. possible to map to a custom error type
                return error
            } else {
                return error
            }
        }
        .handleEvents(receiveCancel: { request?.cancel() })
        .eraseToAnyPublisher()
    }

    func getSingleTodo(id: Int) -> AnyPublisher<Todo, Error> {
        var request: CancellableRequest?

        return Future { [weak self] promise in
            request = self?.httpClient.get(endpoint: Endpoints.todo(id: id)) { _, result in
                promise(result)
            }
        }
        .handleEvents(receiveCancel: { request?.cancel() })
        .eraseToAnyPublisher()
    }

    func deleteSingleTodo(id: Int) -> AnyPublisher<Jetworking.Empty, Error> {
        var request: CancellableRequest?

        return Future { [weak self] promise in
            request = self?.httpClient.delete(endpoint: Endpoints.todoDelete(id: id)) { _, result in
                promise(result)
            }
        }
        .handleEvents(receiveCancel: { request?.cancel() })
        .eraseToAnyPublisher()
    }
}
