import Foundation

enum ResponseHandler {
    typealias WrappedCompletion<ResponseType> = (HTTPURLResponse, Data?, Decoder, @escaping Client.RequestCompletion<ResponseType>) -> () -> Void
    enum CompletionWrapper {
        static func void<ResponseType>(
            currentURLResponse: HTTPURLResponse,
            data: Data?,
            decoder: Decoder,
            completion: @escaping Client.RequestCompletion<ResponseType>)
        -> () -> Void
        {
            guard ResponseType.self is Void.Type else {
                return { completion(currentURLResponse, .failure(APIError.unexpectedError)) }
            }

            return { completion(currentURLResponse, .success(() as! ResponseType)) }
        }


        static func decodable<ResponseType: Decodable>(
            currentURLResponse: HTTPURLResponse,
            data: Data?,
            decoder: Decoder,
            completion: @escaping Client.RequestCompletion<ResponseType>)
        -> () -> Void
        {
            guard let data = data, let decodedData = try? decoder.decode(ResponseType.self, from: data) else {
                return { (completion(currentURLResponse, .failure(APIError.decodingError))) }
            }
            // Evaluate Header fields --> urlResponse.allHeaderFields

            return { (completion(currentURLResponse, .success(decodedData))) }
        }
    }

    // TODO: Improve this function (Error handling, evaluation of header fields, status code evalutation, ...)
    static func evaluate<ResponseType>(
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
            return self.configuration(configuration, enqueue: completion(nil, .failure(error ?? APIError.responseMissing)))
        }

        if let error = error { return self.configuration(configuration, enqueue: completion(currentURLResponse, .failure(error))) }

        switch HTTPStatusCodeType(statusCode: currentURLResponse.statusCode) {
        case .successful:
            let decoder = endpoint?.decoder ?? configuration.decoder
            self.configuration(configuration, enqueue: completionWrapper(currentURLResponse, data, decoder, completion)())

        case .clientError, .serverError:
            guard let error = error else { return completion(currentURLResponse, .failure(APIError.unexpectedError)) }

            self.configuration(configuration, enqueue: completion(currentURLResponse, .failure(error)))

        default:
            return
        }
    }

    private static func configuration(_ configuration: Configuration, enqueue completion: @escaping @autoclosure () -> Void) {
        configuration.responseQueue.async {
            completion()
        }
    }
}
