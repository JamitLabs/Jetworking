import Foundation

/// The handler used to combine progress and completion.
public struct DownloadHandler {
    /// Typealias for the progress handler which returns the total bytes written and the total bytes expected to write.
    public typealias ProgressHandler = ((Int64, Int64) -> Void)?
    /// Typealias for the completion handler which returns either an URL and response or and error.
    public typealias CompletionHandler = ((URL?, URLResponse?, Error?) -> Void)

    /// The progress handler to use to get updates about the progress of the download.
    var progressHandler: ProgressHandler
    /// The completion handler to use to get either the location of the download and the response or an error.
    var completionHandler: CompletionHandler
}
