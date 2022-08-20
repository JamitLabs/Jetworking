// Copyright © 2022 Jamit Labs GmbH. All rights reserved.

import Foundation
import Jetworking

enum Endpoints {
    static let todos: Endpoint<[Todo]> = .init(pathComponent: "todos")

    static func todo(id: Int) -> Endpoint<Todo> {
        .init(pathComponent: "todos/\(id)")
    }

    // Dedicated endpoint for delete, because the expected model (Empty) is different to the get request (Todo).
    static func todoDelete(id: Int) -> Endpoint<Empty> {
        .init(pathComponent: "todos/\(id)")
    }
}
