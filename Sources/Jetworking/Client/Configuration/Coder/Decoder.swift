import Foundation

/// A protocol providing a `decode<T: Decodable>(: T.Type, from: Data) -> T` interface.
public protocol Decoder {
    /**
     * Decodes data to an instance of the indicated type.
     *
     * - Parameter type:
     *  The type data is decoded to.
     * - Parameter data:
     *  The data to decode.
     */
    func decode<T: Decodable>(_ type: T.Type, from data: Data) throws -> T
}
