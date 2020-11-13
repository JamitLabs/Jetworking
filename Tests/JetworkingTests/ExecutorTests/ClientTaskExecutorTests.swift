import XCTest
@testable import Jetworking

final class ClientTaskExecutorTests: XCTestCase {
    // MARK: - Network state tests
    func testClientTaskExecutorWithoutNetworkReachabilityCheck() {
        let taskExecutor = ClientTaskExecutor(reachabilityMonitor: nil)
        let requestExecutor = AsyncRequestExecutor(session: URLSession(configuration: .default))
        XCTAssertNoThrow(try taskExecutor.perform(makeSampleClientDataTask(), on: requestExecutor))
    }

    func testClientTaskExecutorInUnreachableNetwork() {
        let taskExecutor = makeSampleClientTaskExecutor(state: .unreachable)
        let requestExecutor = AsyncRequestExecutor(session: URLSession(configuration: .default))
        XCTAssertThrowsError(try taskExecutor.perform(makeSampleClientDataTask(), on: requestExecutor))
    }

    func testClientTaskExecutorInNotDeterminedNetwork() {
        let taskExecutor = makeSampleClientTaskExecutor(state: .notDetermined)
        let requestExecutor = AsyncRequestExecutor(session: URLSession(configuration: .default))
        XCTAssertThrowsError(try taskExecutor.perform(makeSampleClientDataTask(), on: requestExecutor))
    }

    func testClientTaskExecutorInReachableNetwork() {
        let taskExecutor = makeSampleClientTaskExecutor(state: .reachable(.localWiFi))
        let requestExecutor = AsyncRequestExecutor(session: URLSession(configuration: .default))
        XCTAssertNoThrow(try taskExecutor.perform(makeSampleClientDataTask(), on: requestExecutor))
    }

    func testClientTaskExecutorInUnreachableNetworkThenReachableNetwork() {
        let reachabilityMonitor = makeSampleReachabilityMonitor(state: .unreachable)
        let taskExecutor = ClientTaskExecutor(reachabilityMonitor: reachabilityMonitor)

        let requestExecutor = AsyncRequestExecutor(session: URLSession(configuration: .default))
        XCTAssertThrowsError(try taskExecutor.perform(makeSampleClientDataTask(), on: requestExecutor))

        (reachabilityMonitor as? MockNetworkReachabilityMonitor)?.reachabilityState = .reachable(.localWiFi)

        XCTAssertNoThrow(try taskExecutor.perform(makeSampleClientDataTask(), on: requestExecutor))
    }

    func testClientTaskExecutorInReachableNetworkThenUnreachableNetwork() {
        let reachabilityMonitor = makeSampleReachabilityMonitor(state: .reachable(.localWiFi))
        let taskExecutor = ClientTaskExecutor(reachabilityMonitor: reachabilityMonitor)

        let requestExecutor = AsyncRequestExecutor(session: URLSession(configuration: .default))
        XCTAssertNoThrow(try taskExecutor.perform(makeSampleClientDataTask(), on: requestExecutor))

        (reachabilityMonitor as? MockNetworkReachabilityMonitor)?.reachabilityState = .unreachable

        XCTAssertThrowsError(try taskExecutor.perform(makeSampleClientDataTask(), on: requestExecutor))
    }

    // MARK: - Task operation tests
    func testClientTaskExecutorWithDataTask() {
        let taskExecutor: ClientTaskExecutor = makeSampleClientTaskExecutor()
        let task: Client.Task = makeSampleClientDataTask()

        let requestExecutor = AsyncRequestExecutor(session: URLSession(configuration: .default))
        XCTAssertNoThrow(try taskExecutor.perform(task, on: requestExecutor))

        let downloadExecutor = DefaultDownloadExecutor(
            sessionConfiguration: URLSession.shared.configuration,
            downloadExecutorDelegate: MockDownloadExecutorDelegation()
        )
        XCTAssertThrowsError(try taskExecutor.perform(task, on: downloadExecutor))

        let uploadExecutor = DefaultUploadExecutor.init(
            sessionConfiguration: URLSession.shared.configuration,
            uploadExecutorDelegate: MockUploadExecutorDelegation()
        )
        XCTAssertThrowsError(try taskExecutor.perform(task, on: uploadExecutor))
    }

    func testClientTaskExecutorWithDownloadTask() {
        let taskExecutor: ClientTaskExecutor = makeSampleClientTaskExecutor()
        let task: Client.Task = .downloadTask(request: makeSampleRequest())

        let requestExecutor = AsyncRequestExecutor(session: URLSession(configuration: .default))
        XCTAssertThrowsError(try taskExecutor.perform(task, on: requestExecutor))

        let downloadExecutor = DefaultDownloadExecutor(
            sessionConfiguration: URLSession.shared.configuration,
            downloadExecutorDelegate: MockDownloadExecutorDelegation()
        )
        XCTAssertNoThrow(try taskExecutor.perform(task, on: downloadExecutor))

        let uploadExecutor = DefaultUploadExecutor.init(
            sessionConfiguration: URLSession.shared.configuration,
            uploadExecutorDelegate: MockUploadExecutorDelegation()
        )
        XCTAssertThrowsError(try taskExecutor.perform(task, on: uploadExecutor))
    }

    func testClientTaskExecutorWithUploadDataTask() {
        let task: Client.Task = .uploadDataTask(request: makeSampleRequest(), data: Data())
        let taskExecutor: ClientTaskExecutor = makeSampleClientTaskExecutor()

        let requestExecutor = AsyncRequestExecutor(session: URLSession(configuration: .default))
        XCTAssertThrowsError(try taskExecutor.perform(task, on: requestExecutor))

        let downloadExecutor = DefaultDownloadExecutor(
            sessionConfiguration: URLSession.shared.configuration,
            downloadExecutorDelegate: MockDownloadExecutorDelegation()
        )
        XCTAssertThrowsError(try taskExecutor.perform(task, on: downloadExecutor))

        let uploadExecutor = DefaultUploadExecutor.init(
            sessionConfiguration: URLSession.shared.configuration,
            uploadExecutorDelegate: MockUploadExecutorDelegation()
        )
        XCTAssertNoThrow(try taskExecutor.perform(task, on: uploadExecutor))
    }

    func testClientTaskExecutorWithUploadFileTask() {
        let filePath = Bundle.module.path(forResource: "avatar", ofType: ".png")!
        var components: URLComponents = .init()
        components.scheme = "file"
        components.path = filePath

        let task: Client.Task = .uploadFileTask(request: makeSampleRequest(), fileURL: components.url!)
        let taskExecutor: ClientTaskExecutor = makeSampleClientTaskExecutor()

        let requestExecutor = AsyncRequestExecutor(session: URLSession(configuration: .default))
        XCTAssertThrowsError(try taskExecutor.perform(task, on: requestExecutor))

        let downloadExecutor = DefaultDownloadExecutor(
            sessionConfiguration: URLSession.shared.configuration,
            downloadExecutorDelegate: MockDownloadExecutorDelegation()
        )
        XCTAssertThrowsError(try taskExecutor.perform(task, on: downloadExecutor))

        let uploadExecutor = DefaultUploadExecutor.init(
            sessionConfiguration: URLSession.shared.configuration,
            uploadExecutorDelegate: MockUploadExecutorDelegation()
        )
        XCTAssertNoThrow(try taskExecutor.perform(task, on: uploadExecutor))
    }
}

extension ClientTaskExecutorTests {
    func makeSampleRequest() -> URLRequest {
        .init(url: URL(string: "http://localhost")!)
    }

    func makeSampleReachabilityMonitor(state: NetworkReachabilityState) -> NetworkReachabilityMonitor {
        MockNetworkReachabilityMonitor(state: state)
    }

    func makeSampleClientTaskExecutor(state: NetworkReachabilityState = .reachable(.localWiFi)) -> ClientTaskExecutor {
        let reachabilityMonitor = makeSampleReachabilityMonitor(state: state)
        return ClientTaskExecutor(reachabilityMonitor: reachabilityMonitor)
    }

    func makeSampleClientDataTask() -> Client.Task {
        .dataTask(request: makeSampleRequest(), completion: { _,_,_ in })
    }
}
