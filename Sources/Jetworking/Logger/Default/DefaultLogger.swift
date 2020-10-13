import Foundation
import os.log

final class DefaultLogger: Logger {
    func log(_ message: String) {
        if #available(iOS 10.0, OSX 10.12, *) {
            os_log("%@", message)
        } else {
            print(message)
        }
    }
}
