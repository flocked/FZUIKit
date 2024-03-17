//
//  UIAlertController+.swift
//
//
//  Created by Florian Zand on 17.03.24.
//

#if os(iOS)
import UIKit
import FZSwiftUtils

extension UIAlertAction {
    /// A block to execute when the user selects the action. This block has no return value and takes the selected action object as its only parameter.
    public var handler: ((UIAlertAction) -> Void)? {
        get {
            guard let block = value(forKey: "handler") else { return nil }
            let blockPtr = UnsafeRawPointer(Unmanaged<AnyObject>.passUnretained(block as AnyObject).toOpaque())
            return unsafeBitCast(blockPtr, to: AlertHandler.self)
        }
        set {
            if let newValue = newValue {
                let swiftClosure: AlertHandler = { action in
                    newValue(action)
                }
                setValue(unsafeBitCast(swiftClosure, to: AnyObject.self), forKey: "handler")
            } else {
                setValue(nil, forKey: "handler")
            }
        }
    }
    
    typealias AlertHandler = @convention(block) (UIAlertAction) -> Void
    
    var isSuppressable: Bool {
        get { !isMethodReplaced(NSSelectorFromString("setHandler:")) }
        set {
            guard newValue != isSuppressable else { return }
            if newValue {
                do {
                    try replaceMethod(
                     NSSelectorFromString("setHandler:"),
                    methodSignature: (@convention(c)  (AnyObject, Selector, Any?) -> ()).self,
                    hookSignature: (@convention(block)  (AnyObject, Any?) -> ()).self) { store in {
                        object, action in
                        Swift.print("set", action ?? "nil")
                        store.original(object, NSSelectorFromString("setHandler:"), action)
                        }
                    }
                } catch {
                    Swift.debugPrint(error)
                }
            }
        }
    }
    
    func swizzle() {
        do {
            try Swizzle(UIAlertAction.self) {
                NSSelectorFromString("setHandler:") <-> #selector(setter: swizzled_handler)
                NSSelectorFromString("handler") <-> #selector(getter: swizzled_handler)
            }
        } catch {
            Swift.debugPrint(error)
        }
    }
        
    /*
     try replaceMethod(
      NSSelectorFromString("setHandler:"),
     methodSignature: (@convention(c)  (AnyObject, Selector, UIAlertAction) -> ()).self,
     hookSignature: (@convention(block)  (AnyObject, UIAlertAction) -> ()).self) { store in {
         object, action in
         if let object = object as? UIAlertAction {
             
         }
         store.original(object, NSSelectorFromString("setHandler:"), action)
         }
     }
     */
    
    static func swizzle() {
        do {
            try Swizzle(UIAlertAction.self) {
                NSSelectorFromString("setHandler:") <-> #selector(setter: swizzled_handler)
                NSSelectorFromString("handler") <-> #selector(getter: swizzled_handler)

            }
        } catch {
            print(error)
        }
    }
    
    @objc var swizzled_handler: ((UIAlertAction) -> Void)? {
        get {
            let handler = self.swizzled_handler
            Swift.print("swizzled_handler get", handler ?? "nil")
            return handler
        }
        set {
            Swift.print("swizzled_handler set", newValue ?? "nil")
            self.swizzled_handler = newValue
        }
    }
}

extension UIAlertController {
    /**
     The key for supression of the alert.
     
     Provide this key to allow the user to opt out of showing the alert again. The alert shows a suppression checkbox.
     
     If the user opts out, the alert won't be shown again and will instead return as response `suppress`.
     
     ```swift
     let response = myAlert.runModal()
     
     // Handle supression if needed
     if response == .suppress {
     
     }
     ```
     
     ### Reset the supression key
     
     To reset the supression for alerts with a specified key to let them show again, remove the key from ``supressionKeys``.
     
     ```swift
     NSAlert.supressionKeys.remove("mySuppressionKey")
     ```
     
     To reset all supressions, remove all keys from the set.
     */
    var suppressionKey: String? {
        get { getAssociatedValue("suppressionKey", initialValue: nil) }
        set {
            setAssociatedValue(newValue, key: "suppressionKey")
            swizzleRunModal()
        }
    }
    
    /**
     All supression keys the user did opt out of showing the alert again.
     
     To reset the supression for alerts with a specified key to let them show again, remove the key from the set.
     
     ```swift
     NSAlert.supressionKeys.remove("mySuppressionKey")
     ```
     
     If you want to reset all supressions, remove all keys from the set.
     */
    static var supressionKeys: Set<String> {
        get { Defaults.shared.get("AlertSupressions", initalValue: []) }
        set { Defaults.shared.set(newValue, for: "AlertSupressions") }
    }
    
    func swizzleRunModal() {
    }
}
#endif
