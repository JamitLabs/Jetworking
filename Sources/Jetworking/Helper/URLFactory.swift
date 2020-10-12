import Foundation

public enum URLFactory {
    static func makeURL<ResponseType>(from endpoint: Endpoint<ResponseType>, withBaseURL baseURL: URL) throws -> URL {
        guard
            var urlComponents = URLComponents(
                url: baseURL.appendingPathComponent(endpoint.pathComponent),
                resolvingAgainstBaseURL: false
            )
        else {
            throw APIError.invalidURLComponents
        }

        urlComponents.queryItems = endpoint.queryParameters.map { param in
            URLQueryItem(name: param.key, value: param.value)
        }

        guard let url = urlComponents.url else { throw APIError.invalidURLComponents }

        return url
    }
}
