import Foundation

public struct Endpoint<ResponseType: Decodable> {
    var pathComponents: [String]
    var queryParameters: [String: String?] = [:]

    public init(pathComponent: String) {
        self.pathComponents = pathComponent.split(separator: "/").map(String.init)
    }

    public init(pathComponents: [String]) {
        self.pathComponents = pathComponents
    }

    /**
     * # Summary
     * Adding a dictionary of query parameters to the endpoint.
     *
     * - Parameter parameters:
     *  A dictionary containting the query parameters in form [Key: Value]. If the key already
     *  exists it will be overriden
     *
     * - Returns:
     * A new endpoint instance with the merged parameters.
     */
    public func addQueryParameters(_ parameters: [String: String?]) -> Endpoint<ResponseType> {
        var endpoint = self

        endpoint.queryParameters = endpoint.queryParameters.merging(
            parameters,
            uniquingKeysWith: { _, rhsKey in rhsKey }
        )

        return endpoint
    }

    /**
     * # Summary
     * Adding a query parameter to the endpoint.
     *
     * - parameter key: The key of the query parameter to add. If the key is already present, its value will be overriden by the new one.
     * - parameter value: The value of the query parameter.
     *
     * - Returns:
     * A new endpoint instance with the added parameter.
     */
    public func addQueryParameter(key: String, value: String?) -> Endpoint<ResponseType> {
        return addQueryParameters([key: value])
    }

    /**
     * # Summary
     * Adding a dictionary of path components to the endpoint.
     *
     * - Parameter pathComponents:
     *  A dictionary containting the path components in form [Value].
     *
     * - Returns:
     * A new endpoint instance with the appended path components.
     */
    public func addPathComponents(_ pathComponents: [String]) -> Endpoint<ResponseType> {
        var endpoint = self
        endpoint.pathComponents.append(contentsOf: pathComponents)
        return endpoint
    }

    /**
     * # Summary
     * Adding a path component to the endpoint.
     *
     * - parameter pathComponent: The path component to add.
     *
     * - Returns:
     * A new endpoint instance with the added path component.
     */
    public func addPathComponent(_ pathComponent: String) -> Endpoint<ResponseType> {
        return addPathComponents([pathComponent])
    }
}
