import XCTest
import Foundation
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

            dispatchPrecondition(condition: .onQueue(DispatchQueue.main))

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
            dispatchPrecondition(condition: .onQueue(DispatchQueue.main))
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

    func testPostRequestWithEmptyContent() {
        let client = Client(configuration: makeDefaultClientConfiguration())
        let expectation = self.expectation(description: "Wait for post with empty content")

        client.post(endpoint: Endpoints.post, body: nil) { response, result in
            dispatchPrecondition(condition: .onQueue(DispatchQueue.main))
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
            dispatchPrecondition(condition: .onQueue(DispatchQueue.main))
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
            dispatchPrecondition(condition: .onQueue(DispatchQueue.main))
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
            dispatchPrecondition(condition: .onQueue(DispatchQueue.main))
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

    func testExternalRequest() {
        let defaultConfiguration = makeDefaultClientConfiguration()
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

    func testRequestCancellation() throws {
        let client = Client(configuration: makeDefaultClientConfiguration())
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

    func testSequentialRequestsCorrectOrder() {
        let client = Client(configuration: .init(
            baseURL: URL(string: "https://postman-echo.com")!,
            interceptors: [
                AuthenticationRequestInterceptor(
                    authenticationMethod: .basicAuthentication(username: "username", password: "password")
                ),
                HeaderFieldsRequestInterceptor(headerFields: self.additionalHeaderFields()),
                LoggingInterceptor()
            ],
            requestExecutorType: .sync
        ))

        let firstExpectation = expectation(description: "Wait for first get")
        let secondExpectation = expectation(description: "Wait for second get")
        let thirdExpectation = expectation(description: "Wait for third get")
        let fourthExpectation = expectation(description: "Wait for fourth get")

        client.get(endpoint: Endpoints.get) { _, _ in
            dispatchPrecondition(condition: .onQueue(DispatchQueue.main))
            firstExpectation.fulfill()
        }
        client.get(endpoint: Endpoints.get) { _, _ in
            dispatchPrecondition(condition: .onQueue(DispatchQueue.main))
            secondExpectation.fulfill()
        }
        client.get(endpoint: Endpoints.get) { _, _ in
            dispatchPrecondition(condition: .onQueue(DispatchQueue.main))
            thirdExpectation.fulfill()
        }
        client.get(endpoint: Endpoints.get) { _, _ in
            dispatchPrecondition(condition: .onQueue(DispatchQueue.main))
            fourthExpectation.fulfill()
        }

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
        let configuration = extendClientConfiguration(makeDefaultClientConfiguration(), with: cache)
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

        wait(for: [firstExpectation, secondExpectation], timeout: 20.0)
    }

    func testForcedFileDownload() {
        let cache = URLCache(memoryCapacity: 10 * 1_024 * 1_024, diskCapacity: .zero, diskPath: nil)
        let configuration = extendClientConfiguration(makeDefaultClientConfiguration(), with: cache)
        let client = Client(configuration: configuration)

        let firstExpectation = XCTestExpectation(description: "Wait for remote download")
        let secondExpectation = XCTestExpectation(description: "Wait for forced (re-)download")

        let url = URL(string: "https://speed.hetzner.de/100MB.bin")!

        // Downloads file from remote source
        client.download(url: url, progressHandler: nil) { fileURL, response, _ in
            dispatchPrecondition(condition: .onQueue(DispatchQueue.main))
            guard let fileURL = fileURL else { return }

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

        wait(for: [firstExpectation, secondExpectation], timeout: 20.0)
    }

    func testUploadFile() {
        let client = Client(configuration: makeDefaultClientConfiguration())
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
        let client = Client(configuration: makeDefaultClientConfiguration())
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
        let client = Client(configuration: makeDefaultClientConfiguration())

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
        client.post(endpoint: Endpoints.post.overrideStandardEncoderWith(testableEncoder), body: body) { response, result in
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

        client.put(endpoint: Endpoints.put.overrideStandardEncoderWith(testableEncoder), body: body) { response, result in
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

        client.patch(endpoint: Endpoints.patch.overrideStandardEncoderWith(testableEncoder), body: body) { response, result in
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

    func testCustomDecoderForGet() {
        let testableDecoder = TestableDecoder()
        let client = Client(configuration: makeDefaultClientConfiguration(.sync)) { session in
            session.configuration.timeoutIntervalForRequest = 30
        }

        let getDecoderCalledExpectation = expectation(description: "Decoder method called for get")
        let waitForGetExpectation = expectation(description: "Wait for get")

        testableDecoder.decodeCalled = {
            getDecoderCalledExpectation.fulfill()
        }

        client.get(endpoint: Endpoints.get.addQueryParameter(key: "SomeKey", value: "SomeValue").withCustomDecoder(testableDecoder)) { response, result in
            dispatchPrecondition(condition: .onQueue(DispatchQueue.main))

            switch result {
            case .failure:
                break

            case let .success(resultData):
                print(resultData)
            }

            XCTAssertNotNil(response)
            XCTAssertEqual(response?.statusCode, 200)
            waitForGetExpectation.fulfill()
        }

        waitForExpectations(timeout: 5.0, handler: nil)
    }

    func testCustomDecoderForPost() {
        let testableDecoder = TestableDecoder()
        let client = Client(configuration: makeDefaultClientConfiguration(.sync)) { session in
            session.configuration.timeoutIntervalForRequest = 30
        }

        let postDecodingCalledExpectation = expectation(description: "Decoder method called for post")
        let waitForPostExpectation = expectation(description: "Wait for post")

        let body: MockBody = .init(foo1: "bar1", foo2: "bar2")

        testableDecoder.decodeCalled = {
            postDecodingCalledExpectation.fulfill()
        }

        client.post(endpoint: Endpoints.post.withCustomDecoder(testableDecoder), body: body) { response, result in
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

        waitForExpectations(timeout: 5.0, handler: nil)
    }

    func testCustomDecoderForPut() {
        let testableDecoder = TestableDecoder()
        let client = Client(configuration: makeDefaultClientConfiguration(.sync)) { session in
            session.configuration.timeoutIntervalForRequest = 30
        }

        let putDecodingCalledExpectation = expectation(description: "Decoder method called for put")
        let waitForPutExpectation = expectation(description: "Wait for put")

        let body: MockBody = .init(foo1: "bar1", foo2: "bar2")
        testableDecoder.decodeCalled = {
            putDecodingCalledExpectation.fulfill()
        }

        client.put(endpoint: Endpoints.put.withCustomDecoder(testableDecoder), body: body) { response, result in
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

        waitForExpectations(timeout: 5.0, handler: nil)
    }

    func testCustomDecoderForPatch() {
        let testableDecoder = TestableDecoder()
        let client = Client(configuration: makeDefaultClientConfiguration(.sync)) { session in
            session.configuration.timeoutIntervalForRequest = 30
        }

        let patchDecodingCalledExpectation = expectation(description: "Decoder method called for patch")
        let waitForPatchExpectation = expectation(description: "Wait for patch")

        let body: MockBody = .init(foo1: "bar1", foo2: "bar2")
        testableDecoder.decodeCalled = {
            patchDecodingCalledExpectation.fulfill()
        }

        client.patch(endpoint: Endpoints.patch.withCustomDecoder(testableDecoder), body: body) { response, result in
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

extension ClientTests {
    func makeDefaultClientConfiguration(_ requestExecutorType: RequestExecutorType = .async) -> Configuration {
        return .init(
            baseURL: URL(string: "https://postman-echo.com")!,
            interceptors: [
                AuthenticationRequestInterceptor(
                    authenticationMethod: .basicAuthentication(username: "username", password: "password")
                ),
                HeaderFieldsRequestInterceptor(headerFields: self.additionalHeaderFields()),
                LoggingInterceptor()
            ],
            requestExecutorType: requestExecutorType
        )
    }

    func extendClientConfiguration(_ configuration: Configuration, with cache: URLCache) -> Configuration {
        return .init(
            baseURL: configuration.baseURL,
            interceptors: configuration.interceptors + [DefaultSessionCacheIntercepter()],
            encoder: configuration.encoder,
            decoder: configuration.decoder,
            requestExecutorType: configuration.requestExecutorType,
            cache: cache
        )
    }
}
