import Foundation
import Jetworking

class TestableDecoder: Decoder {
    /**
     * This callback is invoked when the decode method is called.
     */
    var decodeCalled: (() -> Void)?

    func decode<T>(_ type: T.Type, from data: Data) throws -> T where T : Decodable {
        decodeCalled?()
        return try JSONDecoder().decode(type, from: data)
    }
}
