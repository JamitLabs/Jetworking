import Foundation

public struct MultipartContentType: RawRepresentable {
    public let rawValue: String

    public init(rawValue: String) {
        self.rawValue = rawValue
    }
}

public extension MultipartContentType {
    static let applicationOctetStream: Self = .init(rawValue: "application/octet-stream")
    static let applicationPDF: Self = .init(rawValue: "application/pdf")
    static let applicationPKCS8: Self = .init(rawValue: "application/pkcs8")
    static let applicationPKCS10: Self = .init(rawValue: "application/pkcs10")
    static let applicationPKCS12: Self = .init(rawValue: "application/pkcs12")
    static let applicationZip: Self = .init(rawValue: "application/zip")
    static let applicationGzip: Self = .init(rawValue: "application/gzip")
    static let applicationJSON: Self = .init(rawValue: "application/json")
    static let applicationJWT: Self = .init(rawValue: "application/jwt")
    static let applicationMP4: Self = .init(rawValue: "application/mp4")
    static let applicationRTF: Self = .init(rawValue: "application/rtf")
    static let applicationVCardJSON: Self = .init(rawValue: "application/vcard+json")
    static let applicationVCardXML: Self = .init(rawValue: "application/vcard+xml")
    static let applicationXML: Self = .init(rawValue: "application/xml")
    static let audioAAC: Self = .init(rawValue: "audio/aac")
    static let audioMPEG: Self = .init(rawValue: "audio/mpeg")
    static let audioVorbis: Self = .init(rawValue: "audio/vorbis")
    static let imageJPEG: Self = .init(rawValue: "image/jpeg")
    static let imagePNG: Self = .init(rawValue: "image/png")
    static let imageSVG: Self = .init(rawValue: "image/svg+xml")
    static let imageHEIC: Self = .init(rawValue: "image/heic")
    static let imageTIFF: Self = .init(rawValue: "image/tiff")
    static let textPlain: Self = .init(rawValue: "text/plain")
    static let textCSV: Self = .init(rawValue: "text/csv")
    static let textHTML: Self = .init(rawValue: "text/html")
    static let textMarkdown: Self = .init(rawValue: "text/markdown")
    static let textRTF: Self = .init(rawValue: "text/rtf")
    static let textXML: Self = .init(rawValue: "text/xml")
    static let videoMP4: Self = .init(rawValue: "video/mp4")
}
