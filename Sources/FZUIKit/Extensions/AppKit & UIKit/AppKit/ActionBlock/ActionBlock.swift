#if os(macOS)

    import Cocoa
    import Foundation

    public protocol TargetActionProtocol: AnyObject {
        typealias ActionBlock = (Self) -> Void
        var target: AnyObject? { get set }
        var action: Selector? { get set }
    }

    extension NSControl: TargetActionProtocol {}
    extension NSCell: TargetActionProtocol {}
    extension NSToolbarItem: TargetActionProtocol {}

    extension NSPanGestureRecognizer: TargetActionProtocol {}
    extension NSMagnificationGestureRecognizer: TargetActionProtocol {}
    extension NSClickGestureRecognizer: TargetActionProtocol {}
    extension NSPressGestureRecognizer: TargetActionProtocol {}
    extension NSRotationGestureRecognizer: TargetActionProtocol {}

    extension NSMenuItem: TargetActionProtocol {}

    internal class ActionTrampoline<T: TargetActionProtocol>: NSObject {
        var action: (T) -> Void

        init(action: @escaping (T) -> Void) {
            self.action = action
        }

        @objc func performAction(sender: NSObject) {
            if let sender = sender as? T {
                action(sender)
            }
        }
    }

    fileprivate let ActionBlockAssociatedObjectKey = "ActionBlock".address

    fileprivate extension String {
        var address: UnsafeRawPointer {
            return UnsafeRawPointer(bitPattern: abs(hashValue))!
        }
    }

    public extension TargetActionProtocol {
        var actionBlock: ActionBlock? {
            set {
                guard let action = newValue else {
                    objc_setAssociatedObject(self, ActionBlockAssociatedObjectKey, nil,
                                             .OBJC_ASSOCIATION_RETAIN)
                    return
                }
                let trampoline = ActionTrampoline(action: action)
                target = trampoline
                self.action = #selector(trampoline.performAction(sender:))
                objc_setAssociatedObject(self, ActionBlockAssociatedObjectKey, trampoline, .OBJC_ASSOCIATION_RETAIN)
            }
            get {
                guard let trampoline: ActionTrampoline =
                    objc_getAssociatedObject(self, ActionBlockAssociatedObjectKey) as? ActionTrampoline<Self> else { return nil }
                return trampoline.action
            }
        }

        private func setup(setup: (Self) -> Void) -> Self {
            setup(self)
            return self
        }
    }

#endif
