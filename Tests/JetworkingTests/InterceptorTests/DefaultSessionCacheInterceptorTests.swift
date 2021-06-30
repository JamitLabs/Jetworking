import XCTest
@testable import Jetworking

final class DefaultSessionCacheInterceptorTests: XCTestCase {
    func testInterceptorWithDefaultSchemes() {
        let expectedStoragePolicy: URLCache.StoragePolicy = .allowedInMemoryOnly
        let interceptor = DefaultSessionCacheIntercepter(storagePolicy: expectedStoragePolicy)

        let cachedReponse = makeDefaultCachedURLResponse(urlString: "https://www.domain.com")
        let interceptedCachedResponse = interceptor.intercept(cachedResponse: cachedReponse)
        XCTAssertEqual(expectedStoragePolicy, interceptedCachedResponse.storagePolicy)
    }

    func testInterceptorWithUndefinedScheme() {
        let expectedStoragePolicy: URLCache.StoragePolicy = .notAllowed
        let interceptor = DefaultSessionCacheIntercepter(storagePolicy: expectedStoragePolicy)

        let cachedReponse = makeDefaultCachedURLResponse(urlString: "ftp://www.domain.com")
        let interceptedCachedResponse = interceptor.intercept(cachedResponse: cachedReponse)
        XCTAssertEqual(expectedStoragePolicy, interceptedCachedResponse.storagePolicy)
    }

    func testInterceptorWithEmptyScheme() {
        let expectedStoragePolicy: URLCache.StoragePolicy = .notAllowed
        let interceptor = DefaultSessionCacheIntercepter(storagePolicy: expectedStoragePolicy, for: [])

        let cachedReponse = makeDefaultCachedURLResponse(urlString: "https://www.domain.com")
        let interceptedCachedResponse = interceptor.intercept(cachedResponse: cachedReponse)
        XCTAssertEqual(expectedStoragePolicy, interceptedCachedResponse.storagePolicy)
    }

    func testInterceptorWithCustomScheme() {
        let expectedStoragePolicy: URLCache.StoragePolicy = .allowedInMemoryOnly
        let interceptor = DefaultSessionCacheIntercepter(storagePolicy: expectedStoragePolicy, for: ["ftp"])

        let cachedReponse = makeDefaultCachedURLResponse(urlString: "ftp://www.domain.com")
        let interceptedCachedResponse = interceptor.intercept(cachedResponse: cachedReponse)
        XCTAssertEqual(expectedStoragePolicy, interceptedCachedResponse.storagePolicy)
    }
}

extension DefaultSessionCacheInterceptorTests {
    private func makeDefaultCachedURLResponse(urlString: String) -> CachedURLResponse {
        .init(
            response: .init(
                url: URL(string: urlString)!,
                mimeType: nil,
                expectedContentLength: 0,
                textEncodingName: nil
            ),
            data: .init(),
            userInfo: nil,
            storagePolicy: .notAllowed
        )
    }
}
