import Foundation

/// A protocol providing a `encode<T: Encodable>(: T) -> Data` interface.
public protocol Encoder {
    /**
     * Encodes an instance of the indicated type.
     *
     * - Parameter value:
     *  The enstance to encode.
     */
    func encode<T: Encodable>(_ value: T) throws -> Data
}
