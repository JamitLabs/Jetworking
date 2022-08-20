// Copyright © 2022 Jamit Labs GmbH. All rights reserved.

import Foundation

struct Todo: Codable {
    var userId: Int
    var id: Int
    var title: String
    var completed: Bool
}
