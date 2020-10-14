enum HTTPStatusCodeType {
    case informational
    case successful
    case redirection
    case clientError
    case serverError
    case unknown

    init(statusCode: Int) {
        switch statusCode {
        case 100 ..< 200:
            self = .informational

        case 200 ..< 300:
            self = .successful

        case 300 ..< 400:
            self = .redirection

        case 400 ..< 500:
            self = .clientError

        case 500 ..< 600:
            self = .serverError

        default:
            self = .unknown
        }
    }
}
