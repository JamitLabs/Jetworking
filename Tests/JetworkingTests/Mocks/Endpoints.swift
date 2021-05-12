import Foundation
@testable import Jetworking

enum Endpoints {
    static let get: Endpoint<MockBody> = .init(pathComponent: "somePath")
    static let post: Endpoint<Empty> = .init(pathComponent: "somePath")
    static let patch: Endpoint<Empty> = .init(pathComponent: "somePath")
    static let put: Endpoint<Empty> = .init(pathComponent: "somePath")
    static let delete: Endpoint<Empty> = .init(pathComponent: "somePath")
    static let getAnother: Endpoint<MockBody> = .init(pathComponent: "someOtherPath")
    static let voidPost: Endpoint<Void> = .init(pathComponent: "somePath")
    static let voidPostClientError: Endpoint<Void> = .init(pathComponent: "somePathClientError")
    static let voidPostServerError: Endpoint<Void> = .init(pathComponent: "somePathServerError")
}
