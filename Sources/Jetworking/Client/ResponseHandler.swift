import Foundation

final class ResponseHandler {
    private typealias WrappedCompletion<ResponseType> = (HTTPURLResponse, Data?, Error?, Decoder, @escaping Client.RequestCompletion<ResponseType>) -> () -> Void

    private let configuration: Configuration

    init(configuration: Configuration) {
        self.configuration = configuration
    }

    func handleVoidResponse<ResponseType>(
        data: Data?,
        urlResponse: URLResponse?,
        error: Error?,
        endpoint: Endpoint<ResponseType>? = nil,
        completion: @escaping Client.RequestCompletion<ResponseType>
    ) {
        evaluate(data: data, urlResponse: urlResponse, error: error, endpoint: endpoint, completionWrapper: makeVoidCompletionWrapper, completion: completion)
    }

    func handleDecodableResponse<ResponseType: Decodable>(
        data: Data?,
        urlResponse: URLResponse?,
        error: Error?,
        endpoint: Endpoint<ResponseType>? = nil,
        completion: @escaping Client.RequestCompletion<ResponseType>
    ) {
        evaluate(data: data, urlResponse: urlResponse, error: error, endpoint: endpoint, completionWrapper: makeDecodableCompletionWrapper, completion: completion)
    }

    @available(iOS 13.0, macOS 10.15.0, *)
    func handleDecodableResponse<ResponseType: Decodable>(
        data: Data?,
        urlResponse: URLResponse?,
        endpoint: Endpoint<ResponseType>? = nil
    ) async -> (HTTPURLResponse?, Result<ResponseType, Error>) {
        await evaluate(data: data, urlResponse: urlResponse, endpoint: endpoint)
    }

    private func makeVoidCompletionWrapper<ResponseType>(
        currentURLResponse: HTTPURLResponse?,
        data: Data?,
        error: Error?,
        decoder: Decoder,
        completion: @escaping Client.RequestCompletion<ResponseType>
    ) -> () -> Void {
        guard ResponseType.self is Void.Type else {
            return { completion(currentURLResponse, .failure(APIError.unexpectedError)) }
        }

        return { completion(currentURLResponse, .success(() as! ResponseType)) }
    }

    private func makeDecodableCompletionWrapper<ResponseType: Decodable>(
        currentURLResponse: HTTPURLResponse?,
        data: Data?,
        error: Error?,
        decoder: Decoder,
        completion: @escaping Client.RequestCompletion<ResponseType>
    ) -> () -> Void {
        guard let data = data else {
            return { (completion(currentURLResponse, .failure(APIError.missingResponseBody))) }
        }

        do {
            let decodedData = try decoder.decode(ResponseType.self, from: data)
            return { (completion(currentURLResponse, .success(decodedData))) }
        } catch {
            return { (completion(currentURLResponse, .failure(APIError.decodingError(error)))) }
        }
    }

    // TODO: Improve this function (Error handling, evaluation of header fields, status code evalutation, ...)
    private func evaluate<ResponseType>(
        data: Data?,
        urlResponse: URLResponse?,
        error: Error?,
        endpoint: Endpoint<ResponseType>? = nil,
        completionWrapper: @escaping WrappedCompletion<ResponseType>,
        completion: @escaping Client.RequestCompletion<ResponseType>
    ) {
        let interceptedResponse = configuration.interceptors.reduce(urlResponse) { response, component in
            return component.intercept(response: response, data: data, error: error)
        }

        guard let currentURLResponse = interceptedResponse as? HTTPURLResponse else {
            return enqueue(
                completion(nil, .failure(error ?? APIError.responseMissing)),
                inDispatchQueue: configuration.responseQueue
            )
        }

        if let error = error { return enqueue(completion(currentURLResponse, .failure(error)), inDispatchQueue: configuration.responseQueue) }

        switch HTTPStatusCodeType(statusCode: currentURLResponse.statusCode) {
        case .successful:
            let decoder = endpoint?.decoder ?? configuration.decoder
            enqueue(
                completionWrapper(currentURLResponse, data, nil, decoder, completion)(),
                inDispatchQueue: configuration.responseQueue
            )

        case .serverError:
            let apiError: APIError = APIError.serverError(
                statusCode: currentURLResponse.statusCode,
                error: error,
                body: data
            )

            return enqueue(
                completion(currentURLResponse, .failure(apiError)),
                inDispatchQueue: configuration.responseQueue
            )

        case .clientError:
            let apiError: APIError = APIError.clientError(
                statusCode: currentURLResponse.statusCode,
                error: error,
                body: data
            )

            enqueue(
                completion(currentURLResponse, .failure(apiError)),
                inDispatchQueue: configuration.responseQueue
            )

        default:
            return
        }
    }

    @available(iOS 13.0, macOS 10.15.0, *)
    private func evaluate<ResponseType: Decodable>(
        data: Data?,
        urlResponse: URLResponse?,
        endpoint: Endpoint<ResponseType>? = nil
    ) async -> (HTTPURLResponse?, Result<ResponseType, Error>) {
        let interceptedResponse = configuration.interceptors.reduce(urlResponse) { response, component in
            return component.intercept(response: response, data: data, error: nil)
        }

        guard let currentURLResponse = interceptedResponse as? HTTPURLResponse else {
            return (nil, .failure(APIError.responseMissing))
        }

        switch HTTPStatusCodeType(statusCode: currentURLResponse.statusCode) {
        case .successful:
            guard let data = data else { return (nil, .failure(APIError.missingResponseBody)) }
            let decoder = endpoint?.decoder ?? configuration.decoder
            do {
                let responseType = try decoder.decode(ResponseType.self, from: data)
                return (currentURLResponse, .success(responseType))
            } catch {
                return (nil, .failure(APIError.decodingError(error)))
            }

        case .serverError:
            let apiError: APIError = APIError.serverError(
                statusCode: currentURLResponse.statusCode,
                error: nil,
                body: data
            )

            return (currentURLResponse, .failure(apiError))

        case .clientError:
            let apiError: APIError = APIError.clientError(
                statusCode: currentURLResponse.statusCode,
                error: nil,
                body: data
            )

            return (currentURLResponse, .failure(apiError))

        default:
            return (nil, .failure(APIError.unexpectedError))
        }
    }

    private func enqueue(_ completion: @escaping @autoclosure () -> Void, inDispatchQueue queue: DispatchQueue) {
        queue.async {
            completion()
        }
    }
}
