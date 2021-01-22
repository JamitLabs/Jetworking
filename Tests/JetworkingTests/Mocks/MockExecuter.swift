import Foundation
@testable import Jetworking

struct MockCancellable: CancellableRequest {
    var identifier: Int = Int.random(in: (Int.min..<Int.max))
    var onCancelCalled: ((Int) -> Void)?

    init(onCancelCalled: ((Int) -> Void)?) {
        self.onCancelCalled = onCancelCalled
    }

    func cancel() {
        onCancelCalled?(identifier)
    }
}

final class MockExecuter: RequestExecutor {
    let session: URLSession
    let encoder: JSONEncoder = JSONEncoder()
    let defaultCompletionDelay: TimeInterval = 0.5
    let responseCode: Int = 200
    let headerFields: [String: String]? = nil
    var isCancelled: Bool = false

    static var completionDelayForRequest: ((URLRequest) -> TimeInterval)?

    init(session: URLSession) {
        self.session = session
    }

    func send(
        request: URLRequest,
        _ completion: @escaping ((Data?, URLResponse?, Error?) -> Void)
    ) -> CancellableRequest? {
        let completionDelay = MockExecuter.completionDelayForRequest?(request) ?? defaultCompletionDelay
        DispatchQueue.main.asyncAfter(deadline: .now() + completionDelay) { [weak self] in
            guard self?.isCancelled == false  else { return completion(nil, nil, URLError(.cancelled)) }

            self?.execute(
                request: request,
                completion: completion
            )
        }

        return MockCancellable { [weak self] _ in
            self?.isCancelled = true
        }
    }

    private func execute(
        request: URLRequest,
        completion: @escaping ((Data?, URLResponse?, Error?) -> Void)
    ) {
        guard
            let url = request.url,
            let method = request.httpMethod
        else {
            return
        }

        switch (url.absoluteString, HTTPMethod(rawValue: method.uppercased())) {
        case ("https://www.jamitlabs.com/somePath", .GET),
             ("https://www.jamitlabs.com/somePath", .DELETE),
             ("https://www.jamitlabs.com/somePath", .PATCH),
             ("https://www.jamitlabs.com/somePath", .PUT),
             ("https://www.jamitlabs.com/somePath", .POST):
            completion(
                try? encoder.encode(MockBody(foo1: "SomeFoo", foo2: "AnotherFoo")),
                request.toHTTPURLResponse(
                    with: responseCode,
                    andHeaderFields: headerFields
                ),
                nil
            )

        case ("https://www.jamitlabs.com/somePath?SomeKey=SomeValue", .GET):
            completion(
                try? encoder.encode(MockBody(foo1: "SomeFoo", foo2: "AnotherFoo")),
                request.toHTTPURLResponse(
                    with: responseCode,
                    andHeaderFields: headerFields
                ),
                nil
            )

        default:
            completion(nil, nil, URLError(.cancelled))
        }
    }
}

private extension URLRequest {
    func toHTTPURLResponse(
        with statusCode: Int = 200,
        andHeaderFields fields: [String: String]? = nil
    ) -> HTTPURLResponse? {
        guard let url = self.url else { return nil }

        return HTTPURLResponse(
            url: url,
            statusCode: statusCode,
            httpVersion: nil,
            headerFields: fields
        )
    }
}
