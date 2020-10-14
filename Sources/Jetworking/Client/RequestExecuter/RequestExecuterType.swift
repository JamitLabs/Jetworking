import Foundation

public enum RequestExecuterType {
    case async
    case sync
    case custom(RequestExecuter.Type)
}
