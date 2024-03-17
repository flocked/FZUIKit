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
        get { getAssociatedValue("helpHandler", initialValue: nil) }
        set { setAssociatedValue(newValue, key: "helpHandler")
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
        get { getAssociatedValue("helpDelegate", initialValue: nil) }
        set { setAssociatedValue(newValue, key: "helpDelegate") }
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
     
     To reset the supression for alerts with a specified key to let them show again, remove the key from ``supressionKeys``.
     
     ```swift
     NSAlert.supressionKeys.remove("mySuppressionKey")
     ```
     
     To reset all supressions, remove all keys from the set.
     */
    public var suppressionKey: String? {
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
    public static var supressionKeys: Set<String> {
        get { Defaults.shared.get("AlertSupressions", initalValue: []) }
        set { Defaults.shared.set(newValue, for: "AlertSupressions") }
    }
    
    func swizzleRunModal() {
        guard !isMethodReplaced(#selector(self.runModal)) else { return }
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
                    NSAlert.supressionKeys.insert(suppressionKey)
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
                            NSAlert.supressionKeys.insert(suppressionKey)
                        }
                        handler?(response)
                    }
                    store.original(object, #selector(self.beginSheetModal(for:completionHandler:)), window, wrappedHandler)
                }
            }
            }
        } catch {
            Swift.debugPrint()
        }
    }
}

#endif
