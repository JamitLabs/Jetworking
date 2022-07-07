import Foundation
import XCTest
import Jetworking
@testable import DataTransfer

final class UploadTests: XCTestCase {
    var defaultSession: URLSession = {
        var session = URLSession(configuration: .default)
        session.configuration.timeoutIntervalForRequest = 30
        return session
    }()

    func testUploadFile() {
        let client = Client(configuration: Configurations.default())
        let expectation = self.expectation(description: "Wait for upload")

        let url = URL(string: "https://catbox.moe/user/api.php")!
        let path = Bundle.module.path(forResource: "avatar", ofType: "png")!
        client.upload(
            url: url,
            fileURL: URL(string: path)!,
            progressHandler: { (bytesSent, bytesExpectedToSend) in
                dispatchPrecondition(condition: .onQueue(DispatchQueue.main))
                XCTAssertTrue(bytesSent <= bytesExpectedToSend)

                let progress = Float(bytesSent) / Float(bytesExpectedToSend)
                print("Progress \(progress)")
                XCTAssertTrue(progress > 0.0)
                XCTAssertTrue(progress <= 1.0)
            }
        ) { _, error in
            dispatchPrecondition(condition: .onQueue(DispatchQueue.main))
            guard error == nil else { return XCTFail("Error while uploading file") }

            expectation.fulfill()
        }

        waitForExpectations(timeout: 5.0, handler: nil)
    }

    func testUploadMultipartData() {
        let client = Client(configuration: Configurations.default())
        let expectation = self.expectation(description: "Wait for upload")

        let url = URL(string: "https://catbox.moe/user/api.php")!

        let filePath = Bundle.module.path(forResource: "avatar", ofType: ".png")!
        var components: URLComponents = .init()
        components.scheme = "file"
        components.path = filePath

        client.upload(
            url: url,
            fileURL: components.url!,
            multipartType: .formData,
            multipartFileContentType: .imagePNG,
            formData: [
                "reqtype": "fileupload",
                "userhash": "caa3dce4fcb36cfdf9258ad9c"
            ],
            progressHandler: { (bytesSent, bytesExpectedToSend) in
                dispatchPrecondition(condition: .onQueue(DispatchQueue.main))
                let progress = Float(bytesSent) / Float(bytesExpectedToSend)
                print("Progress \(progress)")
            }
        ) { _, error in
            dispatchPrecondition(condition: .onQueue(DispatchQueue.main))
            guard error == nil else { return XCTFail("Error while uploading multipart data") }

            expectation.fulfill()
        }

        waitForExpectations(timeout: 5.0, handler: nil)
    }
}
