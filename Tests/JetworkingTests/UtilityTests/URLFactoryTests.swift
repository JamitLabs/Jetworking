import XCTest
@testable import Jetworking

final class URLFactoryTests: XCTestCase {
    struct SampleResponse: Codable {}

    let baseURl: URL = URL(string: "https://www.jamitlabs.com")!
    let sampleEndpoint: Endpoint<SampleResponse> = .init(pathComponent: "sample")

    func testURLParameterEncoding() throws {
        let url = try URLFactory.makeURL(
            from: sampleEndpoint.addQueryParameter(
                key: "someKey",
                value: "someValue"
            ),
            withBaseURL: baseURl
        )

        XCTAssertEqual(url.absoluteString, "https://www.jamitlabs.com/sample?someKey=someValue")
    }

    func testURLMultipleParametersEncoding() throws {
        let url = try URLFactory.makeURL(
            from: sampleEndpoint.addQueryParameters(
                [
                    "firstKey" : "firstValue",
                    "secondKey" : "secondValue",
                    "thirdKey" : "thirdValue"
                ]
            ),
            withBaseURL: baseURl
        )

        guard
            let components = url.absoluteString.split(separator: "?")
            .dropFirst()
            .first?
            .split(separator: "&")
        else {
            return XCTFail("Invalid Components!")
        }

        XCTAssertEqual(components.count, 3)
        XCTAssertTrue(components.contains("firstKey=firstValue"))
        XCTAssertTrue(components.contains("secondKey=secondValue"))
        XCTAssertTrue(components.contains("thirdKey=thirdValue"))
    }

    func testSpecialCharacterEncoding() throws {
        let url = try URLFactory.makeURL(
            from: sampleEndpoint.addQueryParameter(
                key: "someSpecialChars",
                value: "␣\"#%&<=>[\\]{|}"
            ),
            withBaseURL: baseURl
        )

        XCTAssertEqual(url.absoluteString, "https://www.jamitlabs.com/sample?someSpecialChars=%E2%90%A3%22%23%25%26%3C%3D%3E%5B%5C%5D%7B%7C%7D")

    }

    func testInvalidURLComponent() throws {
        let endpoint: Endpoint<SampleResponse> = .init(pathComponent: "сплин://ws.audioscrobbler.com/2.0/?method=artist.search&artist=сплин&api_key=bad5acca27008a09709ccb2c0258003b&format=json"
        )

        do {
            let _ = try URLFactory.makeURL(
                from: endpoint,
                withBaseURL: baseURl
            )
        } catch APIError.invalidURLComponents {
            // Expected!
        } catch {
            XCTFail("Unexpected error occured!")
        }
    }

    func testSingleAdditionalPathComponent() {
        let expectation: String = "https://www.jamitlabs.com/endpoint/additionalPathComponent"
        let endpoint: Endpoint<SampleResponse> = .init(pathComponent: "endpoint")
        do {
            let url = try URLFactory.makeURL(from: endpoint.addPathComponent("additionalPathComponent"), withBaseURL: baseURl)
            XCTAssertEqual(expectation, url.absoluteString)
        } catch {
            XCTFail()
        }
    }

    func testMultipleAdditionalPathComponents() {
        let expectation: String = "https://www.jamitlabs.com/endpoint/additionalPathComponent/anotherPathComponent"
        let endpoint: Endpoint<SampleResponse> = .init(pathComponent: "endpoint")
        do {
            let url = try URLFactory.makeURL(from: endpoint.addPathComponents(["additionalPathComponent", "anotherPathComponent"]), withBaseURL: baseURl)
            XCTAssertEqual(expectation, url.absoluteString)
        } catch {
            XCTFail()
        }
    }

    func testSingleAdditionalSlashInPathComponent() {
        let expectation: String = "https://www.jamitlabs.com/endpoint/additionalPathComponent"
        let endpoint: Endpoint<SampleResponse> = .init(pathComponent: "endpoint")
        do {
            let url = try URLFactory.makeURL(from: endpoint.addPathComponent("/additionalPathComponent"), withBaseURL: baseURl)
            XCTAssertEqual(expectation, url.absoluteString)
        } catch {
            XCTFail()
        }
    }

    func testMultipleAdditionalSlashInPathComponent() {
        let expectation: String = "https://www.jamitlabs.com/endpoint/additionalPathComponent/anotherPathComponent"
        let endpoint: Endpoint<SampleResponse> = .init(pathComponent: "endpoint")
        do {
            let url = try URLFactory.makeURL(from: endpoint.addPathComponents(["/additionalPathComponent", "/anotherPathComponent"]), withBaseURL: baseURl)
            XCTAssertEqual(expectation, url.absoluteString)
        } catch {
            XCTFail()
        }
    }

    func testEndpointPathComponentInitialiser() {
        let expectation: String = "https://www.jamitlabs.com/endpoint/additionalPathComponent"
        let endpoint: Endpoint<SampleResponse> = .init(pathComponent: "endpoint/additionalPathComponent")
        do {
            let url = try URLFactory.makeURL(from: endpoint, withBaseURL: baseURl)
            XCTAssertEqual(expectation, url.absoluteString)
        } catch {
            XCTFail()
        }
    }

    func testEndpointPathComponentsInitialiser() {
        let expectation: String = "https://www.jamitlabs.com/endpoint/additionalPathComponent"
        let endpoint: Endpoint<SampleResponse> = .init(pathComponents: ["endpoint", "additionalPathComponent"])
        do {
            let url = try URLFactory.makeURL(from: endpoint, withBaseURL: baseURl)
            XCTAssertEqual(expectation, url.absoluteString)
        } catch {
            XCTFail()
        }
    }
}
