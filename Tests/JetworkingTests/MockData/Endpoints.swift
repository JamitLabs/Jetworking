import Foundation
@testable import Jetworking

enum Endpoints {
    static var get: Endpoint<MockBody> = .init(pathComponent: "get")
    static let post: Endpoint<Empty> = .init(pathComponent: "post")
    static let patch: Endpoint<Empty> = .init(pathComponent: "patch")
    static let put: Endpoint<Empty> = .init(pathComponent: "put")
    static let delete: Endpoint<Empty> = .init(pathComponent: "delete")

    static func postWithBody<ResponseBody: Codable>() -> Endpoint<ResponseBody> {
        return .init(pathComponent: "post")
    }

    static func getWithBody<ResponseBody: Codable>() -> Endpoint<ResponseBody> {
        return .init(pathComponent: "get")
    }

    static func putWithBody<ResponseBody: Codable>() -> Endpoint<ResponseBody> {
        return .init(pathComponent: "put")
    }

    static func patchWithBody<ResponseBody: Codable>() -> Endpoint<ResponseBody> {
        return .init(pathComponent: "patch")
    }
}
