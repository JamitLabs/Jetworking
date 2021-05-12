import XCTest
import Foundation
@testable import Jetworking

final class ClientTests: XCTestCase {
    var defaultSession: URLSession = {
        var session = URLSession(configuration: .default)
        session.configuration.timeoutIntervalForRequest = 30
        return session
    }()

    override func setUp() {
        super.setUp()

        MockExecuter.responseCodeForRequest = { request in
            switch request.url?.absoluteString {
            case .some("https://www.jamitlabs.com/somePathClientError"):
                return 403

            case .some("https://www.jamitlabs.com/somePathServerError"):
                return 500

            default:
                return 200
            }
        }
    }

    func testGetRequest() {
        let client = Client(configuration: Configurations.default(), session: defaultSession)
        let expectation = self.expectation(description: "Wait for get")

        client.get(endpoint: Endpoints.get.addQueryParameter(key: "SomeKey", value: "SomeValue")) { response, result in

            dispatchPrecondition(condition: .onQueue(DispatchQueue.main))
            switch result {
            case .failure:
                XCTFail("Request should not result in failure!")

            case let .success(resultData):
                XCTAssertEqual(MockBody(foo1: "SomeFoo", foo2: "AnotherFoo"), resultData)
            }

            XCTAssertNotNil(response)
            XCTAssertEqual(response?.statusCode, 200)
            expectation.fulfill()
        }

        waitForExpectations(timeout: 5.0, handler: nil)
    }

    func testPostRequest() {
        let client = Client(configuration: Configurations.default())
        let expectation = self.expectation(description: "Wait for post")

        let body: MockBody = .init(foo1: "bar1", foo2: "bar2")
        client.post(endpoint: Endpoints.post, body: body) { response, result in
            dispatchPrecondition(condition: .onQueue(DispatchQueue.main))
            switch result {
            case .failure:
                XCTFail("Request should not result in failure!")

            case let .success(resultData):
                XCTAssertNotNil(resultData)
            }

            XCTAssertNotNil(response)
            XCTAssertEqual(response?.statusCode, 200)
            expectation.fulfill()
        }

        waitForExpectations(timeout: 5.0, handler: nil)
    }

    func testPostRequestWithEmptyContent() {
        let client = Client(configuration: Configurations.default())
        let expectation = self.expectation(description: "Wait for post with empty content")

        client.post(endpoint: Endpoints.voidPost) { response, result in
            dispatchPrecondition(condition: .onQueue(DispatchQueue.main))
            switch result {
            case .failure:
                XCTFail("Request should not result in failure!")

            case let .success(resultData):
                XCTAssertNotNil(resultData)
            }

            XCTAssertNotNil(response)
            XCTAssertEqual(response?.statusCode, 200)
            expectation.fulfill()
        }

        waitForExpectations(timeout: 5.0, handler: nil)
    }

    func testPutRequest() {
        let client = Client(configuration: Configurations.default())
        let expectation = self.expectation(description: "Wait for post")

        let body: MockBody = .init(foo1: "bar1", foo2: "bar2")
        client.put(endpoint: Endpoints.put, body: body) { response, result in
            dispatchPrecondition(condition: .onQueue(DispatchQueue.main))
            switch result {
            case .failure:
                XCTFail("Request should not result in failure!")

            case let .success(resultData):
                XCTAssertNotNil(resultData)
            }

            XCTAssertNotNil(response)
            XCTAssertEqual(response?.statusCode, 200)
            expectation.fulfill()
        }

        waitForExpectations(timeout: 5.0, handler: nil)
    }

    func testPatchRequest() {
        let client = Client(configuration: Configurations.default())
        let expectation = self.expectation(description: "Wait for post")

        let body: MockBody = .init(foo1: "bar1", foo2: "bar2")
        client.patch(endpoint: Endpoints.patch, body: body) { response, result in
            dispatchPrecondition(condition: .onQueue(DispatchQueue.main))
            switch result {
            case .failure:
                XCTFail("Request should not result in failure!")

            case let .success(resultData):
                XCTAssertNotNil(resultData)
            }

            XCTAssertNotNil(response)
            XCTAssertEqual(response?.statusCode, 200)
            expectation.fulfill()
        }

        waitForExpectations(timeout: 5.0, handler: nil)
    }

    func testDeleteRequest() {
        let client = Client(configuration: Configurations.default())

        let expectation = self.expectation(description: "Wait for post")

        client.delete(endpoint: Endpoints.delete) { response, result in
            dispatchPrecondition(condition: .onQueue(DispatchQueue.main))
            switch result {
            case .failure:
                XCTFail("Request should not result in failure!")

            case let .success(resultData):
                XCTAssertNotNil(resultData)
            }

            XCTAssertNotNil(response)
            XCTAssertEqual(response?.statusCode, 200)
            expectation.fulfill()
        }

        waitForExpectations(timeout: 5.0, handler: nil)
    }

    func testExternalRequest() {
        let defaultConfiguration = Configurations.default()
        let client = Client(configuration: defaultConfiguration)

        let expectation = self.expectation(description: "Wait for an external request")

        let url = try? URLFactory.makeURL(from: Endpoints.delete, withBaseURL: defaultConfiguration.baseURL)
        guard let targetURL = url else {
            XCTFail("URL not available")
            return
        }

        var request = URLRequest(url: targetURL, httpMethod: .DELETE)
        request = defaultConfiguration.requestInterceptors.reduce(request) { $1.intercept($0) }

        client.send(request: request) { (data: Data?, response: URLResponse?, error: Error?) -> Void in
            XCTAssertNotNil(response)
            if let httpUrlResponse = response as? HTTPURLResponse {
                XCTAssertEqual(httpUrlResponse.statusCode, 200)
            }

            expectation.fulfill()
        }

        waitForExpectations(timeout: 5.0, handler: nil)
    }

    func testPostRequestWithRequestWithServerError() {
        let client = Client(configuration: Configurations.default())

        let expectation = self.expectation(description: "Wait for post with empty content")
        client.post(endpoint: Endpoints.voidPostServerError) { response, result in
            dispatchPrecondition(condition: .onQueue(DispatchQueue.main))

            switch result {
            case .failure(APIError.serverError(statusCode: 500, error: _)):
                XCTAssertNotNil(response)
                XCTAssertEqual(response?.statusCode, 500)
                expectation.fulfill()

            case .failure:
                XCTFail("Request should not result in failure without status code 500!")

            case .success:
                XCTFail("Request should not result in success!")
            }
        }

        waitForExpectations(timeout: 5.0, handler: nil)
    }

    func testPostRequestWithRequestWithClientError() {
        let client = Client(configuration: Configurations.default())
        let expectation = self.expectation(description: "Wait for post with empty content")
        client.post(endpoint: Endpoints.voidPostClientError) { response, result in
            dispatchPrecondition(condition: .onQueue(DispatchQueue.main))

            switch result {
            case .failure(APIError.clientError(statusCode: 403, error: _)):
                XCTAssertNotNil(response)
                XCTAssertEqual(response?.statusCode, 403)
                expectation.fulfill()

            case .failure:
                XCTFail("Request should not result in failure without 403 status code!")

            case .success:
                XCTFail("Request should not result in succes!")
            }
        }

        waitForExpectations(timeout: 5.0, handler: nil)
    }

    func testRequestCancellation() throws {
        let client = Client(configuration: Configurations.default())
        let expectation = self.expectation(description: "Wait for get")

        let cancellableRequest = client.get(
            endpoint: Endpoints.get.addQueryParameter(key: "SomeKey", value: "SomeValue")
        ) { response, result in
            dispatchPrecondition(condition: .onQueue(DispatchQueue.main))
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

    func testDownloadWithInvalidURL() {
        let client = Client(configuration: Configurations.default())

        let url = URL(string: "smtp://www.mail.com")!
        let task = client.download(
            url: url,
            progressHandler: { (_, _) in }
        ) { _, _, _ in }

        XCTAssertNil(task, "The task was not nil")
    }

    func testFileDownload() {
        let client = Client(configuration: Configurations.default())
        let expectation = self.expectation(description: "Wait for download")

        let url = URL(string: "https://speed.hetzner.de/100MB.bin")!
        client.download(
            url: url,
            progressHandler: { (totalBytesWritten, totalBytesExpectedToWrite) in
                XCTAssertTrue(totalBytesWritten <= totalBytesExpectedToWrite)

                let progress = Float(totalBytesWritten) / Float(totalBytesExpectedToWrite)
                print("Progress \(progress)")
                XCTAssertTrue(progress > 0.0)
                XCTAssertTrue(progress <= 1.0)
            }
        ) { localURL, response, error in
            dispatchPrecondition(condition: .onQueue(DispatchQueue.main))
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

    func testFileDownloadFromSessionCache() {
        let cache = URLCache(memoryCapacity: 10 * 1_024 * 1_024, diskCapacity: .zero, diskPath: nil)
        let configuration = Configurations.extendClientConfiguration(Configurations.default(.async), with: cache)
        let client = Client(configuration: configuration)

        let firstExpectation = XCTestExpectation(description: "Wait for remote download")
        let secondExpectation = XCTestExpectation(description: "Wait for cache download")

        let url = URL(string: "https://speed.hetzner.de/100MB.bin")!

        // Downloads file from remote source
        client.download(url: url, isForced: true, progressHandler: nil) { fileURL, response, _ in
            dispatchPrecondition(condition: .onQueue(DispatchQueue.main))
            guard let fileURL = fileURL else { return }

            let responseDate = (response as? HTTPURLResponse)?.allHeaderFields["Date"] as? String
            XCTAssertNotNil(responseDate)

            // Downloads file from cache
            client.download(url: url, isForced: false, progressHandler: nil) { anotherFileURL, anotherResponse, _ in
                dispatchPrecondition(condition: .onQueue(DispatchQueue.main))

                let anotherResponseDate = (anotherResponse as? HTTPURLResponse)?.allHeaderFields["Date"] as? String
                XCTAssertNotNil(anotherResponseDate)

                // Compares timestamp of each response
                XCTAssertEqual(responseDate, anotherResponseDate)

                // Compares file URL of each download result
                XCTAssertEqual(fileURL, anotherFileURL)

                secondExpectation.fulfill()
            }

            firstExpectation.fulfill()
        }

        wait(for: [firstExpectation, secondExpectation], timeout: 60.0)
    }

    func testForcedFileDownload() {
        let cache = URLCache(memoryCapacity: 10 * 1_024 * 1_024, diskCapacity: .zero, diskPath: nil)
        let configuration = Configurations.extendClientConfiguration(Configurations.default(.sync), with: cache)
        let client = Client(configuration: configuration)

        let firstExpectation = XCTestExpectation(description: "Wait for remote download")
        let secondExpectation = XCTestExpectation(description: "Wait for forced (re-)download")

        let url = URL(string: "https://speed.hetzner.de/100MB.bin")!

        // Downloads file from remote source
        client.download(url: url, progressHandler: nil) { fileURL, response, _ in
            dispatchPrecondition(condition: .onQueue(DispatchQueue.main))
            let responseDate = (response as? HTTPURLResponse)?.allHeaderFields["Date"] as? String
            XCTAssertNotNil(responseDate)

            // Downloads file from cache
            client.download(url: url, isForced: true, progressHandler: nil) { anotherFileURL, anotherResponse, _ in
                dispatchPrecondition(condition: .onQueue(DispatchQueue.main))

                let anotherResponseDate = (anotherResponse as? HTTPURLResponse)?.allHeaderFields["Date"] as? String
                XCTAssertNotNil(anotherResponseDate)

                // Compares timestamp of each response
                XCTAssertNotEqual(responseDate, anotherResponseDate)

                secondExpectation.fulfill()
            }

            firstExpectation.fulfill()
        }

        wait(for: [firstExpectation, secondExpectation], timeout: 120.0)
    }

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

    func testCustomEncoder() {
        let testableEncoder = TestableEncoder()
        let client = Client(configuration: Configurations.default())

        let postEncodingCalledExpectation = expectation(description: "Encoder method called for post")
        let putEncodingCalledExpectation = expectation(description: "Encoder method called for put")
        let patchEncodingCalledExpectation = expectation(description: "Encoder method called for patch")

        let waitForPostExpectation = expectation(description: "Wait for post")
        let waitForPutExpectation = expectation(description: "Wait for put")
        let waitForPatchExpectation = expectation(description: "Wait for patch")

        testableEncoder.encodeCalled = {
            postEncodingCalledExpectation.fulfill()
        }

        let body: MockBody = .init(foo1: "bar1", foo2: "bar2")
        client.post(endpoint: Endpoints.post.withCustomEncoder(testableEncoder), body: body) { response, result in
            dispatchPrecondition(condition: .onQueue(DispatchQueue.main))
            switch result {
            case .failure:
                break

            case let .success(resultData):
                print(resultData)
            }

            XCTAssertNotNil(response)
            XCTAssertEqual(response?.statusCode, 200)
            waitForPostExpectation.fulfill()
        }

        testableEncoder.encodeCalled = {
            putEncodingCalledExpectation.fulfill()
        }

        client.put(endpoint: Endpoints.put.withCustomEncoder(testableEncoder), body: body) { response, result in
            dispatchPrecondition(condition: .onQueue(DispatchQueue.main))
            switch result {
            case .failure:
                break

            case let .success(resultData):
                print(resultData)
            }

            XCTAssertNotNil(response)
            XCTAssertEqual(response?.statusCode, 200)
            waitForPutExpectation.fulfill()
        }

        testableEncoder.encodeCalled = {
            patchEncodingCalledExpectation.fulfill()
        }

        client.patch(endpoint: Endpoints.patch.withCustomEncoder(testableEncoder), body: body) { response, result in
            dispatchPrecondition(condition: .onQueue(DispatchQueue.main))
            switch result {
            case .failure:
                break

            case let .success(resultData):
                print(resultData)
            }

            XCTAssertNotNil(response)
            XCTAssertEqual(response?.statusCode, 200)
            waitForPatchExpectation.fulfill()
        }

        waitForExpectations(timeout: 5.0, handler: nil)
    }
}
