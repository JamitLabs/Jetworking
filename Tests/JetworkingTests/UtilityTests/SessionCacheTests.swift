import XCTest
@testable import Jetworking

final class SessionCacheTests: XCTestCase {
    func testSessionCacheQueryForNoCachedData() {
        let sessionCache: SessionCache = makeDefaultSessionCache()

        // Retrieves cache
        let cachedData = sessionCache.query(MockBody.self, for: makeSampleReuest())

        XCTAssertNil(cachedData)
    }

    func testSessionCacheQueryForCachedData() {
        let sessionCache: SessionCache = makeDefaultSessionCache()

        // Caches something
        let dataToCache = makeMockBody()
        sessionCache.store(dataToCache, from: makeSampleResponse(), for: makeSampleReuest())

        // Retrieves cache
        let cachedData = sessionCache.query(MockBody.self, for: makeSampleReuest())

        XCTAssertNotNil(cachedData)
        XCTAssertEqual(dataToCache.foo1, cachedData?.foo1)
        XCTAssertEqual(dataToCache.foo2, cachedData?.foo2)
    }

    func testSessionCacheQueryForCachedDataWithOtherDataType() {
        let sessionCache: SessionCache = makeDefaultSessionCache()

        // Caches something
        sessionCache.store(makeMockBody(), from: makeSampleResponse(), for: makeSampleReuest())

        // Retrieves cached object with expected data type
        let cachedData = sessionCache.query(MockBody.self, for: makeSampleReuest())
        XCTAssertNotNil(cachedData)

        // Retrieves cached object with wrong data type
        let nilCachedData = sessionCache.query(String.self, for: makeSampleReuest())
        XCTAssertNil(nilCachedData)
    }

    func testSessionCacheRemoveCachedObject() {
        let sessionCache: SessionCache = makeDefaultSessionCache()

        // Caches something
        sessionCache.store(makeMockBody(), from: makeSampleResponse(), for: makeSampleReuest())

        // Ensures cached object's existance
        var cachedData = sessionCache.query(MockBody.self, for: makeSampleReuest())
        XCTAssertNotNil(cachedData)

        // Removes cached object
        sessionCache.removeObject(for: makeSampleReuest())

        // Ensures object removal
        cachedData = sessionCache.query(MockBody.self, for: makeSampleReuest())
        XCTAssertNil(cachedData)
    }

    func testSessionCacheRemoveNonCachedObject() {
        let sessionCache: SessionCache = makeDefaultSessionCache()
        let memoryUsage = sessionCache.currentMemoryUsage

        // Removes cached object
        sessionCache.removeObject(for: makeSampleReuest())

        XCTAssertEqual(memoryUsage, sessionCache.currentMemoryUsage)
    }

    func testSessionCacheReset() {
        let sessionCache: SessionCache = makeDefaultSessionCache()
        XCTAssertTrue(sessionCache.currentMemoryUsage < 1)

        // Caches something
        sessionCache.store(makeMockBody(), from: makeSampleResponse(), for: makeSampleReuest())
        XCTAssertTrue(sessionCache.currentMemoryUsage > 1)

        // Removes cached data
        sessionCache.reset()
        XCTAssertTrue(sessionCache.currentMemoryUsage < 1)

        let cachedData = sessionCache.query(MockBody.self, for: makeSampleReuest())
        XCTAssertNil(cachedData)
    }

}

// MARK: - Factory methods
extension SessionCacheTests {
    private func makeMockBody() -> MockBody {
        .init(foo1: "1", foo2: "2")
    }

    private func makeSampleReuest() -> URLRequest {
        .init(url: URL(string: "https://postman-echo.com")!, httpMethod: .GET)
    }

    private func makeSampleResponse() -> URLResponse {
        .init(
            url: URL(string: "https://postman-echo.com")!,
            mimeType: nil,
            expectedContentLength: 0,
            textEncodingName: nil
        )
    }

    private func makeDefaultSessionCache() -> SessionCache {
        return .init(
            cache: .init(
                memoryCapacity: 1_024 * 1_024, // 1 MB
                diskCapacity: .zero,
                diskPath: nil
            ),
            encoder: .init(),
            decoder: .init(),
            interceptors: [
                DefaultSessionCacheIntercepter(storagePolicy: .allowedInMemoryOnly)
            ]
        )
    }
}
