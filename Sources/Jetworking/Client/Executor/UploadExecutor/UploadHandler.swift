import Foundation

/// The handler used to combine progress and completion.
public struct UploadHandler {
    /// Typealias for the progress handler which returns the total bytes sent and the total bytes expected to be sent.
    public typealias ProgressHandler = ((Int64, Int64) -> Void)?
    /// Typealias for the completion handler which returns either a response or an error.
    public typealias CompletionHandler = ((URLResponse?, Error?) -> Void)

    /// The progress handler to use to get updates about the progress of the upload.
    var progressHandler: ProgressHandler
    /// The completion handler to use to get either the response or an error.
    var completionHandler: CompletionHandler
}
