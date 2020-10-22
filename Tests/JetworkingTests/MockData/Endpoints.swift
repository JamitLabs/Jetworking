import Foundation
@testable import Jetworking

enum Endpoints {
    static var get: Endpoint<MockBody> = .init(pathComponent: "get")
    static let post: Endpoint<Empty> = .init(pathComponent: "post")
    static let patch: Endpoint<Empty> = .init(pathComponent: "patch")
    static let put: Endpoint<Empty> = .init(pathComponent: "put")
    static let delete: Endpoint<Empty> = .init(pathComponent: "delete")
}
