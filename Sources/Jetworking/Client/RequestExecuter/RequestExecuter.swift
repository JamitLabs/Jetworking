import Foundation

protocol RequestExecuter {
    var session: URLSession { get }
    init(session: URLSession)

    func send(request: URLRequest, _ completion: @escaping ((Data?, URLResponse?, Error?) -> Void)) -> CancellableRequest?
}
