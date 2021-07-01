import Foundation

public struct MultipartType: RawRepresentable {
    public let rawValue: String

    public init(rawValue: String) {
        self.rawValue = rawValue
    }
}

public extension MultipartType {
    static let formData: Self = .init(rawValue: "multipart/form-data")
    static let mixed: Self = .init(rawValue: "multipart/mixed")
    static let byteRanges: Self = .init(rawValue: "multipart/byteranges")
    static let encrypted: Self = .init(rawValue: "multipart/encrypted")
    static let headerSet: Self = .init(rawValue: "multipart/header-set")
    static let multilingual: Self = .init(rawValue: "multipart/multilingual")
    static let related: Self = .init(rawValue: "multipart/related")
    static let report: Self = .init(rawValue: "multipart/report")
    static let signed: Self = .init(rawValue: "multipart/signed")
}
