import Foundation
import XCTest
import Jetworking
@testable import DataTransfer

final class DownloadTests: XCTestCase {
    var defaultSession: URLSession = {
        var session = URLSession(configuration: .default)
        session.configuration.timeoutIntervalForRequest = 30
        return session
    }()

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
}
