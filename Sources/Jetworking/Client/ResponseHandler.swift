import Foundation

enum ResponseHandler {
    private typealias WrappedCompletion<ResponseType> = (HTTPURLResponse, Data?, Error?, Decoder, @escaping Client.RequestCompletion<ResponseType>) -> () -> Void

    static func handleVoidResponse<ResponseType>(
        data: Data?,
        urlResponse: URLResponse?,
        error: Error?,
        endpoint: Endpoint<ResponseType>? = nil,
        configuration: Configuration,
        completion: @escaping Client.RequestCompletion<ResponseType>
    ) {
        evaluate(data: data, urlResponse: urlResponse, error: error, endpoint: endpoint, configuration: configuration, completionWrapper: Self.makeVoidCompletionWrapper, completion: completion)
    }

    static func handleDecodableResponse<ResponseType: Decodable>(
    data: Data?,
    urlResponse: URLResponse?,
    error: Error?,
    endpoint: Endpoint<ResponseType>? = nil,
    configuration: Configuration,
    completion: @escaping Client.RequestCompletion<ResponseType>
    ) {
        evaluate(data: data, urlResponse: urlResponse, error: error, endpoint: endpoint, configuration: configuration, completionWrapper: Self.makeDecodableCompletionWrapper, completion: completion)
    }

    private static func makeVoidCompletionWrapper<ResponseType>(
        currentURLResponse: HTTPURLResponse?,
        data: Data?,
        error: Error?,
        decoder: Decoder,
        completion: @escaping Client.RequestCompletion<ResponseType>
    ) -> () -> Void
    {
        guard ResponseType.self is Void.Type else {
            return { completion(currentURLResponse, .failure(APIError.unexpectedError)) }
        }

        return { completion(currentURLResponse, .success(() as! ResponseType)) }
    }

    private static func makeDecodableCompletionWrapper<ResponseType: Decodable>(
        currentURLResponse: HTTPURLResponse?,
        data: Data?,
        error: Error?,
        decoder: Decoder,
        completion: @escaping Client.RequestCompletion<ResponseType>
    ) -> () -> Void
    {
        guard
            let data = data,
            let decodedData = try? decoder.decode(ResponseType.self, from: data)
        else {
            return { (completion(currentURLResponse, .failure(APIError.decodingError))) }
        }
        // Evaluate Header fields --> urlResponse.allHeaderFields

        return { (completion(currentURLResponse, .success(decodedData))) }
    }

    // TODO: Improve this function (Error handling, evaluation of header fields, status code evalutation, ...)
    private static func evaluate<ResponseType>(
        data: Data?,
        urlResponse: URLResponse?,
        error: Error?,
        endpoint: Endpoint<ResponseType>? = nil,
        configuration: Configuration,
        completionWrapper: @escaping WrappedCompletion<ResponseType>,
        completion: @escaping Client.RequestCompletion<ResponseType>
    ) {
        let interceptedResponse = configuration.responseInterceptors.reduce(urlResponse) { response, component in
            return component.intercept(data: data, response: response, error: error)
        }

        guard let currentURLResponse = interceptedResponse as? HTTPURLResponse else {
            return self.enqueue(completion(nil, .failure(error ?? APIError.responseMissing)), inDispatchQueue: configuration.responseQueue)
        }

        if let error = error { return self.enqueue(completion(currentURLResponse, .failure(error)), inDispatchQueue: configuration.responseQueue) }

        switch HTTPStatusCodeType(statusCode: currentURLResponse.statusCode) {
        case .successful:
            let decoder = endpoint?.decoder ?? configuration.decoder
            self.enqueue(completionWrapper(currentURLResponse, data, nil, decoder, completion)(), inDispatchQueue: configuration.responseQueue)

        case .clientError, .serverError:
            guard let error = error else { return completion(currentURLResponse, .failure(APIError.unexpectedError)) }

            self.enqueue(completion(currentURLResponse, .failure(error)), inDispatchQueue: configuration.responseQueue)

        default:
            return
        }
    }

    private static func enqueue(_ completion: @escaping @autoclosure () -> Void, inDispatchQueue queue: DispatchQueue) {
        queue.async {
            completion()
        }
    }
}
