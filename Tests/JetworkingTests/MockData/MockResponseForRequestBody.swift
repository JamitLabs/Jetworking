struct MockResponseForRequestBody<RequestBodyType: Codable>: Codable {
    let json: RequestBodyType
    let url: String
}
