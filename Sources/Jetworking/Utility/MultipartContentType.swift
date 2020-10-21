import Foundation

public enum MultipartContentType: String {
    case applicationOctetStream = "application/octet-stream"
    case applicationPDF = "application/pdf"
    case applicationPKCS8 = "application/pkcs8"
    case applicationPKCS10 = "application/pkcs10"
    case applicationPKCS12 = "application/pkcs12"
    case applicationZip = "application/zip"
    case applicationGzip = "application/gzip"
    case applicationJSON = "application/json"
    case applicationJWT = "application/jwt"
    case applicationMP4 = "application/mp4"
    case applicationRTF = "application/rtf"
    case applicationVCardJSON = "application/vcard+json"
    case applicationVCardXML = "application/vcard+xml"
    case applicationXML = "application/xml"

    case audioAAC = "audio/aac"
    case audioMPEG = "audio/mpeg"
    case audioVorbis = "audio/vorbis"
    
    case imageJPEG = "image/jpeg"
    case imagePNG = "image/png"
    case imageSVG = "image/svg+xml"
    case imageHEIC = "image/heic"
    case imageTIFF = "image/tiff"

    case textPlain = "text/plain"
    case textCSV = "text/csv"
    case textHTML = "text/html"
    case textMarkdown = "text/markdown"
    case textRTF = "text/rtf"
    case textXML = "text/xml"

    case videoMP4 = "video/mp4"
}
