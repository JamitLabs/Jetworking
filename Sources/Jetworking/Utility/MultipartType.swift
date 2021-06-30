import Foundation

public enum MultipartType: String {
    case formData = "multipart/form-data"
    case mixed = "multipart/mixed"
    case byteRanges = "multipart/byteranges"
    case encrypted = "multipart/encrypted"
    case headerSet = "multipart/header-set"
    case multilingual = "multipart/multilingual"
    case related = "multipart/related"
    case report = "multipart/report"
    case signed = "multipart/signed"
}
