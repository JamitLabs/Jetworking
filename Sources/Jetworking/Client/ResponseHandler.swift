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
            return { (completion(currentURLResponse, .failure(error))) }
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
        let interceptedResponse = configuration.responseInterceptors.reduce(urlResponse) { response, component in
            return component.intercept(data: data, response: response, error: error)
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

        case .clientError, .serverError:
            guard let error = error else {
                return enqueue(
                    completion(currentURLResponse, .failure(APIError.unexpectedError)),
                    inDispatchQueue: configuration.responseQueue
                )
            }

            enqueue(
                completion(currentURLResponse, .failure(error)),
                inDispatchQueue: configuration.responseQueue
            )

        default:
            return
        }
    }

    private func enqueue(_ completion: @escaping @autoclosure () -> Void, inDispatchQueue queue: DispatchQueue) {
        queue.async {
            completion()
        }
    }
}
