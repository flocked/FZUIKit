//
//  NSAlert+.swift
//
//
//  Created by Florian Zand on 03.02.24.
//

#if os(macOS)
import AppKit
import FZSwiftUtils

public extension NSApplication.ModalResponse {
    /**
     The presentation or dismissal of the dialog or has been suppressed, because the user already opted out of showing it again.
     
     See `NSAlert/supressionKey` for more information.
     */
    static let suppress = NSApplication.ModalResponse((1 << 14))
    
    /// The user clicked the button at the specified index on the dialog or sheet.
    static func button(at index: Int) -> NSApplication.ModalResponse {
        return NSApplication.ModalResponse(1000+index)
    }
}

extension NSAlert {
    /**
     Creates a critical alert with the specified title and message.
     
     - Parameters:
        - title: The title of the alert.
        - message: The message of the alert.
     */
    public static func critical(_ title: String, message: String) -> NSAlert {
        let alert = NSAlert()
        alert.alertStyle = .critical
        alert.messageText = title
        alert.informativeText = message
        return alert
    }
    
    /**
     Creates an informational alert with the specified title and message.
     
     - Parameters:
        - title: The title of the alert.
        - message: The message of the alert.
     */
    public static func informational(_ title: String, message: String) -> NSAlert {
        let alert = NSAlert()
        alert.alertStyle = .informational
        alert.messageText = title
        alert.informativeText = message
        return alert
    }
    
    /**
     Creates a warning alert with the specified title and message.
          
     - Parameters:
        - title: The title of the alert.
        - message: The message of the alert.
     */
    public static func warning(_ title: String, message: String) -> NSAlert {
        let alert = NSAlert()
        alert.alertStyle = .warning
        alert.messageText = title
        alert.informativeText = message
        return alert
    }
    
    /**
     The handler that gets called when the user clicks the help button.
     
     To show the help button, set `showsHelp` to `true`.
     
     This is an alternative way to using the alert's delegate.
     */
    public var helpHandler: (()->())? {
        get { getAssociatedValue(key: "helpHandler", object: self, initialValue: nil) }
        set { set(associatedValue: newValue, key: "helpHandler", object: self)
            if newValue == nil {
                helpDelegate = nil
            } else {
                if helpDelegate == nil {
                    helpDelegate = HelpDelegate()
                }
                delegate = helpDelegate
            }
        }
    }
    
    var helpDelegate: HelpDelegate? {
        get { getAssociatedValue(key: "helpDelegate", object: self, initialValue: nil) }
        set { set(associatedValue: newValue, key: "helpDelegate", object: self) }
    }
    
    
    class HelpDelegate: NSObject, NSAlertDelegate {
        func alertShowHelp(_ alert: NSAlert) -> Bool {
            alert.helpHandler?()
            return alert.helpAnchor != nil ? false : true
        }
    }
    
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

     To reset the supression of the alert and to show it again regardless if the user already did opt out showing it, use ``resetSupression(for:)``. 
     
     You  can also use ``resetAllSupressions()`` to reset all supressions.
     
     ```swift
     NSAlert.resetSupression(for: "mySuppressionKey")
     ```
     */
    public var suppressionKey: String? {
        get { getAssociatedValue(key: "suppressionKey", object: self, initialValue: nil) }
        set {
            self.swizzleRunModal()
            set(associatedValue: newValue, key: "suppressionKey", object: self)
        }
    }
    
    /**
     Resets the supression for alerts with the specified key.
     
     It lets you show them again, regardless if the user already did opt out of showing them.
     */
    public static func resetSupression(for suppressionKey: String) {
        if var supressionKeys: [String] = Defaults.shared["AlertSupressions"], supressionKeys.contains(suppressionKey) {
            supressionKeys.remove(suppressionKey)
            Defaults.shared["AlertSupressions"] = supressionKeys.uniqued()
        }
    }
    
    /**
     Resets the supression for all alerts.
     
     It lets you show them again, regardless if the user already did opt out of showing them.
     */
    public static func resetAllSupressions() {
        Defaults.shared["AlertSupressions"] = nil
    }
    
    static func saveSupressionKey(_ key: String) {
        if var supressionKeys: [String] = Defaults.shared["AlertSupressions"], supressionKeys.contains(key) {
            supressionKeys.append(key)
            Defaults.shared["AlertSupressions"] = supressionKeys.uniqued()
        } else {
            Defaults.shared["AlertSupressions"] = [key]
        }
    }
    
    func swizzleRunModal() {
        guard didSwizzleRunModal == false else { return }
        do {
            try replaceMethod(
                #selector(self.runModal),
                methodSignature: (@convention(c) (AnyObject, Selector) -> (NSApplication.ModalResponse)).self,
                hookSignature: (@convention(block) (AnyObject) -> (NSApplication.ModalResponse)).self
            ) { store in { object in
                guard let alert = object as? NSAlert, let suppressionKey = alert.suppressionKey else {
                    return store.original(object, #selector(self.runModal))
                }
                if let supressionKeys: [String] = Defaults.shared["AlertSupressions"], supressionKeys.contains(suppressionKey) {
                    return .suppress
                }
                alert.showsSuppressionButton = true
                let runModal = store.original(object, #selector(self.runModal))
                if alert.suppressionButton?.state == .on {
                    Self.saveSupressionKey(suppressionKey)
                }
                return runModal
            }
            }
            
            try replaceMethod(
                #selector(self.beginSheetModal(for:completionHandler:)),
                methodSignature: (@convention(c) (AnyObject, Selector, NSWindow, ((NSApplication.ModalResponse) -> Void)?) -> ()).self,
                hookSignature: (@convention(block) (AnyObject, NSWindow, ((NSApplication.ModalResponse) -> Void)?) -> ()).self
            ) { store in { object, window, handler in
                guard let alert = object as? NSAlert, let suppressionKey = alert.suppressionKey else {
                    store.original(object, #selector(self.beginSheetModal(for:completionHandler:)), window, handler)
                    return
                }
                if let supressionKeys: [String] = Defaults.shared["AlertSupressions"], supressionKeys.contains(suppressionKey) {
                    handler?(.suppress)
                } else {
                    alert.showsSuppressionButton = true
                    let wrappedHandler: ((NSApplication.ModalResponse) -> Void) = { response in
                        if alert.suppressionButton?.state == .on {
                            Self.saveSupressionKey(suppressionKey)
                        }
                        handler?(response)
                    }
                    store.original(object, #selector(self.beginSheetModal(for:completionHandler:)), window, wrappedHandler)
                }
            }
            }
            didSwizzleRunModal = true
        } catch {
            Swift.debugPrint()
        }
    }
    
    var didSwizzleRunModal: Bool {
        get { getAssociatedValue(key: "didSwizzleRunModal", object: self, initialValue: false) }
        set { set(associatedValue: newValue, key: "didSwizzleRunModal", object: self) }
    }
}

#endif
