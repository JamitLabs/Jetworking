import Foundation

/// The download executer currently supported.
/// - `default` for an execution using the default session configuration
/// - `background` for an execution using the background session configuration. ATTENTION: This is still a work in progress approach which is not yet tested with an app and should be used with care.
/// - `custom` for a custom execution of download requests provided by the caller.
public enum DownloadExecuterType {
    case `default`
    case background
    case custom(DownloadExecuter.Type)
}
