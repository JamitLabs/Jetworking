import Foundation

public enum URLFactory {
    public static func makeURL<ResponseType>(from endpoint: Endpoint<ResponseType>, withBaseURL baseURL: URL) throws -> URL {
        let currentURL = endpoint.pathComponents.reduce(into: baseURL) { (url, pathComponent) in
            url.appendPathComponent(pathComponent)
        }

        guard
            var urlComponents = URLComponents(url: currentURL, resolvingAgainstBaseURL: false)
        else {
            throw APIError.invalidURLComponents
        }

        if !endpoint.queryParameters.isEmpty {
            urlComponents.queryItems = endpoint.queryParameters.map { param in
                URLQueryItem(name: param.key, value: param.value)
            }
        }

        guard let url = urlComponents.url else { throw APIError.invalidURLComponents }

        return url
    }
}
