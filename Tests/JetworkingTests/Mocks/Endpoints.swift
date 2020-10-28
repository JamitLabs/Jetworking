import Foundation
@testable import Jetworking

enum Endpoints {
    static var get: Endpoint<MockBody> = .init(pathComponent: "somePath")
    static let post: Endpoint<Empty> = .init(pathComponent: "somePath")
    static let patch: Endpoint<Empty> = .init(pathComponent: "somePath")
    static let put: Endpoint<Empty> = .init(pathComponent: "somePath")
    static let delete: Endpoint<Empty> = .init(pathComponent: "somePath")
}
