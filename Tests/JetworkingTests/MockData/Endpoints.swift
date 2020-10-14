import Foundation
@testable import Jetworking

enum Endpoints {
    static var get: Endpoint<MockBody> = .init(pathComponent: "get")
    static let post: Endpoint<VoidResult> = .init(pathComponent: "post")
    static let patch: Endpoint<VoidResult> = .init(pathComponent: "patch")
    static let put: Endpoint<VoidResult> = .init(pathComponent: "put")
    static let delete: Endpoint<VoidResult> = .init(pathComponent: "delete")
}
