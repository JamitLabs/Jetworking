struct MockResponseForArguments<ArgumentTypes: Codable>: Codable {
    let args: ArgumentTypes
    let url: String
}
