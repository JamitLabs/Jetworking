import Foundation

/// Inspired by https://medium.com/@dhawaldawar/how-to-mock-urlsession-using-urlprotocol-8b74f389a67a
final class MockURLProtocol: URLProtocol {
    enum MockError: Error {
        case invalidConfiguration
    }

    static var requestHandler: ((URLRequest) throws -> (HTTPURLResponse, Data?, TimeInterval))?

    override class func canInit(with request: URLRequest) -> Bool {
       // To check if this protocol can handle the given request.
       return true
     }

     override class func canonicalRequest(for request: URLRequest) -> URLRequest {
       // Here you return the canonical version of the request but most of the time you pass the orignal one.
       return request
     }

     override func startLoading() {
        guard let handler = MockURLProtocol.requestHandler else { return }

        do {
            // 2. Call handler with received request and capture the tuple of response and data.
            let (response, data, delay) = try handler(request)

            // 3. Send received response to the client.
            DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
                self.client?.urlProtocol(self, didReceive: response, cacheStoragePolicy: .notAllowed)

                if let data = data {
                    // 4. Send received data to the client.
                    self.client?.urlProtocol(self, didLoad: data)
                }

                // 5. Notify request has been finished.
                self.client?.urlProtocolDidFinishLoading(self)
            }
        } catch {
          // 6. Notify received error.
          client?.urlProtocol(self, didFailWithError: error)
        }
     }

     override func stopLoading() {
       // This is called if the request gets canceled or completed.
     }
}
