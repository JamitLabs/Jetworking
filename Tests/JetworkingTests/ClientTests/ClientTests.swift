import XCTest
@testable import Jetworking

final class ClientTests: XCTestCase {
    func additionalHeaderFields() -> [String: String] {
        return [
            "Accept": "application/json",
            "Content-Type": "application/json"
        ]
    }

    func testGetRequest() {
        let client = Client(configuration: makeDefaultClientConfiguration()) { session in
            session.configuration.timeoutIntervalForRequest = 30
        }

        let expectation = self.expectation(description: "Wait for get")

        client.get(endpoint: Endpoints.get.addQueryParameter(key: "SomeKey", value: "SomeValue")) { response, result in
            switch result {
            case .failure:
                break

            case let .success(resultData):
                print(resultData)
            }

            XCTAssertNotNil(response)
            XCTAssertEqual(response?.statusCode, 200)
            expectation.fulfill()
        }

        waitForExpectations(timeout: 5.0, handler: nil) 
    }

    func testPostRequest() {
        let client = Client(configuration: makeDefaultClientConfiguration())
        let expectation = self.expectation(description: "Wait for post")

        let body: MockBody = .init(foo1: "bar1", foo2: "bar2")
        client.post(endpoint: Endpoints.post, body: body) { response, result in
            switch result {
            case .failure:
                break

            case let .success(resultData):
                print(resultData)
            }

            XCTAssertNotNil(response)
            XCTAssertEqual(response?.statusCode, 200)
            expectation.fulfill()
        }

        waitForExpectations(timeout: 5.0, handler: nil)
    }

    func testPutRequest() {
        let client = Client(configuration: makeDefaultClientConfiguration())
        let expectation = self.expectation(description: "Wait for post")

        let body: MockBody = .init(foo1: "bar1", foo2: "bar2")
        client.put(endpoint: Endpoints.put, body: body) { response, result in
            switch result {
            case .failure:
                break

            case let .success(resultData):
                print(resultData)
            }

            XCTAssertNotNil(response)
            XCTAssertEqual(response?.statusCode, 200)
            expectation.fulfill()
        }

        waitForExpectations(timeout: 5.0, handler: nil)
    }

    func testPatchRequest() {
        let client = Client(configuration: makeDefaultClientConfiguration())
        let expectation = self.expectation(description: "Wait for post")

        let body: MockBody = .init(foo1: "bar1", foo2: "bar2")
        client.patch(endpoint: Endpoints.patch, body: body) { response, result in
            switch result {
            case .failure:
                break

            case let .success(resultData):
                print(resultData)
            }

            XCTAssertNotNil(response)
            XCTAssertEqual(response?.statusCode, 200)
            expectation.fulfill()
        }

        waitForExpectations(timeout: 5.0, handler: nil)
    }
    
    func testDeleteRequest() {
        let client = Client(configuration: makeDefaultClientConfiguration())

        let expectation = self.expectation(description: "Wait for post")

        client.delete(endpoint: Endpoints.delete) { response, result in
            switch result {
            case .failure:
                break

            case let .success(resultData):
                print(resultData)
            }

            XCTAssertNotNil(response)
            XCTAssertEqual(response?.statusCode, 200)
            expectation.fulfill()
        }

        waitForExpectations(timeout: 5.0, handler: nil)
    }

    func testRequestCancellation() throws {
        let client = Client(configuration: makeDefaultClientConfiguration())
        let expectation = self.expectation(description: "Wait for get")

        let cancellableRequest = client.get(
            endpoint: Endpoints.get.addQueryParameter(key: "SomeKey", value: "SomeValue")
        ) { response, result in
            XCTAssertNil(response)

            switch result {
            case let .failure(error as URLError):
                XCTAssertEqual(error.code, URLError.cancelled)

            case .failure:
                XCTFail("Should not executed since error should be URLError")

            case .success:
                XCTFail("Should not succeed due to cancellation")
            }

            expectation.fulfill()
        }

        cancellableRequest?.cancel()

        waitForExpectations(timeout: 5.0, handler: nil)
    }

    func testSequentialRequestsCorrectOrder() {
        let client = Client(configuration: .init(
            baseURL: URL(string: "https://postman-echo.com")!,
            requestInterceptors: [
                AuthenticationRequestInterceptor(
                    authenticationMethod: .basicAuthentication(username: "username", password: "password")
                ),
                HeaderFieldsRequestInterceptor(headerFields: self.additionalHeaderFields()),
                LoggingRequestInterceptor()
            ],
            responseInterceptors: [
                LoggingResponseInterceptor()
            ],
            encoder: JSONEncoder(),
            decoder: JSONDecoder(),
            requestExecutorType: .sync
        ))

        let firstExpectation = expectation(description: "Wait for first get")
        let secondExpectation = expectation(description: "Wait for second get")
        let thirdExpectation = expectation(description: "Wait for third get")
        let fourthExpectation = expectation(description: "Wait for fourth get")

        client.get(endpoint: Endpoints.get) { _, _ in firstExpectation.fulfill() }
        client.get(endpoint: Endpoints.get) { _, _ in secondExpectation.fulfill() }
        client.get(endpoint: Endpoints.get) { _, _ in thirdExpectation.fulfill() }
        client.get(endpoint: Endpoints.get) { _, _ in fourthExpectation.fulfill() }

        let result = XCTWaiter().wait(
            for: [firstExpectation, secondExpectation, thirdExpectation, fourthExpectation],
            timeout: 20,
            enforceOrder: true
        )

        XCTAssertTrue(result == .completed)
    }
    
    func testIncorrectOrderDueToAsyncRequestExecutor() {
        let client = Client(configuration: makeDefaultClientConfiguration())

        let firstExpectation = expectation(description: "Wait for first get")
        let secondExpectation = expectation(description: "Wait for second get")
        let thirdExpectation = expectation(description: "Wait for third get")
        let fourthExpectation = expectation(description: "Wait for fourth get")

        client.get(endpoint: Endpoints.get) { _, _ in firstExpectation.fulfill() }
        client.get(endpoint: Endpoints.get) { _, _ in secondExpectation.fulfill() }
        client.get(endpoint: Endpoints.get) { _, _ in thirdExpectation.fulfill() }
        client.get(endpoint: Endpoints.get) { _, _ in fourthExpectation.fulfill() }

        let result = XCTWaiter().wait(
            for: [firstExpectation, secondExpectation, thirdExpectation, fourthExpectation],
            timeout: 20,
            enforceOrder: true
        )

        XCTAssertTrue(result == .incorrectOrder)
	}
    
    func testDownloadWithInvalidURL() {
        let client = Client(configuration: makeDefaultClientConfiguration())
        
        let url = URL(string: "smtp://www.mail.com")!
        let task = client.download(
            url: url,
            progressHandler: { (_, _) in }
        ) { _, _, _ in }

        XCTAssertNil(task, "The task was not nil")
    }

    func testFileDownload() {
        let client = Client(configuration: makeDefaultClientConfiguration())
        let expectation = self.expectation(description: "Wait for download")

        let url = URL(string: "https://speed.hetzner.de/100MB.bin")!
        client.download(
            url: url,
            progressHandler: { (totalBytesWritten, totalBytesExpectedToWrite) in
                let progress = Float(totalBytesWritten) / Float(totalBytesExpectedToWrite)
                print("Progress \(progress)")
            }
        ) { localURL, response, error in
            guard let localURL = localURL else { return }

            do {
                let documentsURL = try FileManager.default.url(
                    for: .documentDirectory,
                    in: .userDomainMask,
                    appropriateFor: nil,
                    create: false
                )
                let savedURL = documentsURL.appendingPathComponent(localURL.lastPathComponent)
                print("SAVED_URL: \(savedURL)")
                try FileManager.default.moveItem(at: localURL, to: savedURL)
                try FileManager.default.removeItem(at: localURL)
            } catch {
                // handle filesystem error
            }

            expectation.fulfill()
        }
        
        waitForExpectations(timeout: 140.0, handler: nil)
    }
    func testUploadFile() {
        let client = Client(configuration: makeDefaultClientConfiguration())
        let expectation = self.expectation(description: "Wait for upload")
        
        let url = URL(string: "https://catbox.moe/user/api.php")!
        let documentsUrl: URL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        let filename = "avatar.png"
        let fileURL = documentsUrl.appendingPathComponent(filename)
        client.upload(
            url: url,
            fileURL: fileURL,
            progressHandler: { (bytesSent, bytesExpectedToSend) in
                let progress = Float(bytesSent) / Float(bytesExpectedToSend)
                print("Progress \(progress)")
            }
        ) { _, error in
            guard error == nil else { return XCTFail("Error while uploading file") }

            expectation.fulfill()
        }

        waitForExpectations(timeout: 5.0, handler: nil)
    }
    
    func testUploadMultipartData() {
        let client = Client(configuration: makeDefaultClientConfiguration())
        let expectation = self.expectation(description: "Wait for upload")
        
        let url = URL(string: "https://catbox.moe/user/api.php")!
        let documentsUrl: URL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        let filename = "avatar.png"
        let fileURL = documentsUrl.appendingPathComponent(filename)
        client.upload(
            url: url,
            fileURL: fileURL,
            multipartType: .formData,
            multipartFileContentType: .textPlain,
            formData: [
                "reqtype": "fileupload",
                "userhash": "caa3dce4fcb36cfdf9258ad9c"
            ],
            progressHandler: { (bytesSent, bytesExpectedToSend) in
                let progress = Float(bytesSent) / Float(bytesExpectedToSend)
                print("Progress \(progress)")
            }
        ) { _, error in
            guard error == nil else { return XCTFail("Error while uploading multipart data") }

            expectation.fulfill()
        }

        waitForExpectations(timeout: 5.0, handler: nil)
    }
}

extension ClientTests {
    func makeDefaultClientConfiguration() -> Configuration {
        return .init(
            baseURL: URL(string: "https://postman-echo.com")!,
            requestInterceptors: [
                AuthenticationRequestInterceptor(
                    authenticationMethod: .basicAuthentication(username: "username", password: "password")
                ),
                HeaderFieldsRequestInterceptor(headerFields: self.additionalHeaderFields()),
                LoggingRequestInterceptor()
            ],
            responseInterceptors: [
                LoggingResponseInterceptor()
            ],
            encoder: JSONEncoder(),
            decoder: JSONDecoder(),
            requestExecutorType: .async
        )
    }
}