import XCTest
@testable import DataTransfer

final class DataExtensionTests: XCTestCase {
    func testMultipartDataInitialisation() {
        let boundary = UUID().uuidString
        let filename = "avatar.png"
        let filePath = Bundle.module.path(forResource: "avatar", ofType: ".png")!

        var components: URLComponents = .init()
        components.scheme = "file"
        components.path = filePath

        let fileURL = components.url!
        let multipartFileContentType: MultipartContentType = .imagePNG
        let userhashKey: String = "userhash"
        let userhashValue: String = "caa3dce4fcb36cfdf9258ad9c"
        let fileuploadKey: String = "reqtype"
        let fileuploadValue: String = "fileupload"
        let formData: [String: String] = [
            fileuploadKey: fileuploadValue,
            userhashKey: userhashValue
        ]

        let multipartData = Data(boundary: boundary, formData: formData, fileURL: fileURL, multipartFileContentType: multipartFileContentType)

        XCTAssertNotNil(multipartData)
        
        guard let unwrappedMultipartData = multipartData else { return XCTFail() }

        let contentDispositionUserHash: String = "\r\n--\(boundary)\r\nContent-Disposition: form-data; name=\"\(userhashKey)\"\r\n\r\n\(userhashValue)"
        let contentDispositionReqtype: String = "\r\n--\(boundary)\r\nContent-Disposition: form-data; name=\"\(fileuploadKey)\"\r\n\r\n\(fileuploadValue)"
        let contentDispositionFile: String = "\r\n--\(boundary)\r\nContent-Disposition: form-data; name=\"fileToUpload\"; filename=\"\(filename)\"\r\nContent-Type: \(multipartFileContentType.rawValue)\r\n\r\n"

        
        let multipartString = String(decoding: unwrappedMultipartData, as: UTF8.self)

        XCTAssertTrue(multipartString.contains(contentDispositionUserHash))
        XCTAssertTrue(multipartString.contains(contentDispositionReqtype))
        XCTAssertTrue(multipartString.contains(contentDispositionFile))
        XCTAssertTrue(multipartString.hasSuffix("\r\n--\(boundary)--\r\n"))
    }
}
