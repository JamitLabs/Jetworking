import Foundation
import Jetworking

final class BackgroundUploadExecuter: NSObject, UploadExecuter {
    var delegate: UploadExecuterDelegate?
    var sessionConfiguration: URLSessionConfiguration

    private var backgroundIdentifier: String
    private var isDiscretionary: Bool = false
    private lazy var session: URLSession = {
        let configuration: URLSessionConfiguration = .background(
            withIdentifier: backgroundIdentifier,
            andIsDiscretionaryFlag: isDiscretionary,
            andConfiguration: sessionConfiguration
        )
        let session: URLSession = .init(configuration: configuration, delegate: self, delegateQueue: nil)
        return session
    }()

    init(sessionConfiguration: URLSessionConfiguration, uploadExecuterDelegate: UploadExecuterDelegate) {
        self.sessionConfiguration = sessionConfiguration
        self.delegate = uploadExecuterDelegate
        self.backgroundIdentifier = "com.jamitlabs.jetworking.background"
        self.isDiscretionary = false

        super.init()
    }

    /**
     * # Summary
     *  Initialises a download executer to download.
     *
     * - Parameter sessionConfiguration:
     *  The session configuration to use within the download executer.
     * - Parameter downloadExecuterDelegate:
     *  The delegate to send the download updates to.
     * - Parameter backgroundIdentifier:
     *  When having an app extension which also handles download functionality make sure to set different background Identifiers as otherwise problems might occur
     * - Parameter isDiscretionary:
     *  When transferring large amounts of data, you are encouraged to set the value of this property to true.
     *  Doing so lets the system schedule those transfers at times that are more optimal for the device.
     *  For example, the system might delay transferring large files until the device is plugged in and connected to the network via Wi-Fi.
     *  Default value is `false`
     */
    init(
        sessionConfiguration: URLSessionConfiguration,
        uploadExecuterDelegate: UploadExecuterDelegate,
        backgroundIdentifier: String = "com.jamitlabs.jetworking.background",
        isDiscretionary: Bool = false
    ) {
        self.sessionConfiguration = sessionConfiguration
        self.delegate = uploadExecuterDelegate
        self.backgroundIdentifier = backgroundIdentifier
        self.isDiscretionary = isDiscretionary

        super.init()
    }

    /**
     * # Summary
     *  Uploading the given request with the given session configuration on a separate background session.
     *
     * - Parameter request:
     *  The request to be downloaded.
     * - Parameter fromFile:
     *  The path to the file to be uploaded.
     *
     * - Returns:
     *  The request to be able to cancel if necessary.
     */
    func upload(request: URLRequest, fromFile fileURL: URL) -> CancellableRequest? {
        let uploadTask = session.uploadTask(with: request, fromFile: fileURL)
        uploadTask.resume()
        return uploadTask
    }

    /**
     * # Summary
     *  Uploading the given request with the given session configuration on a separate background session.
     *
     * - Parameter request:
     *  The request to be uploaded.
     * - Parameter from:
     *  The data to be uploaded.
     *
     * - Returns:
     *  The request to be able to cancel if necessary.
     */
    func upload(request: URLRequest, from bodyData: Data) -> CancellableRequest? {
        let fileURL = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString)
        do {
            try bodyData.write(to: fileURL)
        } catch {
            // TODO: Add error handling.
            return nil
        }

        return upload(request: request, fromFile: fileURL)
    }
}

extension BackgroundUploadExecuter: URLSessionTaskDelegate {
    func urlSession(_ session: URLSession, task: URLSessionTask, didSendBodyData bytesSent: Int64, totalBytesSent: Int64, totalBytesExpectedToSend: Int64) {
        guard let uploadTask = task as? URLSessionUploadTask else { return }

        delegate?.uploadExecuter(uploadTask, didSendBodyData: bytesSent, totalBytesSent: totalBytesSent, totalBytesExpectedToSend: totalBytesExpectedToSend)
    }

    func urlSession(_ session: URLSession, task: URLSessionTask, didCompleteWithError error: Error?) {
        guard let uploadTask = task as? URLSessionUploadTask else { return }

        if let error = error {
            delegate?.uploadExecuter(uploadTask, didCompleteWithError: error)
        } else {
            delegate?.uploadExecuter(didFinishWith: uploadTask)
        }
    }
}
