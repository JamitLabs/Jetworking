import ObjectiveC

class AssociatedObject<T> {
    private let policy: objc_AssociationPolicy

    init(policy: objc_AssociationPolicy = .OBJC_ASSOCIATION_RETAIN_NONATOMIC) {
        self.policy = policy
    }

    subscript(index: AnyObject) -> T? {
        get { objc_getAssociatedObject(index, Unmanaged.passUnretained(self).toOpaque()) as? T }
        set { objc_setAssociatedObject(index, Unmanaged.passUnretained(self).toOpaque(), newValue, policy) }
    }

    subscript(index: AnyObject, initialValue: @autoclosure () -> T) -> T {
        get {
            if let value = self[index] { return value }
            self[index] = initialValue()
            return self[index]!
        }
    }
}
