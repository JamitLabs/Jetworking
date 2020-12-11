import Foundation
import Jetworking

class TestableEncoder: Encoder {
    /**
     * This callback is invoked when the encode method is called.
     */
    var encodeCalled: (() -> Void)?

    func encode<T>(_ value: T) throws -> Data where T : Encodable {
        encodeCalled?()
        return try JSONEncoder().encode(value)
    }
}
