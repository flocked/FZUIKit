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
     
     See ``AppKit/NSAlert/suppressionKey`` for more information.
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
        get { getAssociatedValue("helpHandler") }
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
    
    /// Sets the handler that gets called when the user clicks the help button.
    @discardableResult
    public func helpHandler(_ handler: (()->())?) -> Self {
        self.helpHandler = handler
        return self
    }
    
    /// Sets the alert’s informative text.
    @discardableResult
    public func informativeText(_ text: String) -> Self {
        self.informativeText = text
        return self
    }
    
    /// Sets the alert’s message text or title.
    @discardableResult
    public func messageText(_ text: String) -> Self {
        self.messageText = text
        return self
    }
    
    /// Sets the custom icon displayed in the alert.
    @discardableResult
    public func icon(_ icon: NSImage?) -> Self {
        self.icon = icon
        return self
    }
    
    /// Sets the Boolean value that indicates whether the alert has a help button.
    @discardableResult
    public func showsHelp(_ showsHelp: Bool) -> Self {
        self.showsHelp = showsHelp
        return self
    }
    
    /// Sets the alert’s accessory view.
    @discardableResult
    public func accessoryView(_ view: NSView?) -> Self {
        self.accessoryView = view
        return self
    }
    
    /// Sets the alert’s severity level.
    @discardableResult
    public func style(_ style: Style) -> Self {
        self.alertStyle = style
        return self
    }
    
    /// Sets the Boolean value that indicates whether the alert includes a suppression checkbox, which you can employ to allow a user to opt out of seeing the alert again.
    @discardableResult
    public func showsSuppressionButton(_ shows: Bool) -> Self {
        self.showsSuppressionButton = shows
        return self
    }
        
    var helpDelegate: HelpDelegate? {
        get { getAssociatedValue("helpDelegate") }
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
     
     Provide this key to allow the user to opt out of showing the alert again by showing a suppression checkbox.
     
     If the user opts out, the alert won't be shown again and will instead return as response `suppress`.
     
     ```swift
     myAlert.supressionKey = "someKey"
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
        get { getAssociatedValue("suppressionKey") }
        set {
            setAssociatedValue(newValue, key: "suppressionKey")
            swizzleRunModal()
        }
    }
    
    /// Sets the key for supression of the alert.
    @discardableResult
    public func suppressionKey(_ suppressionKey: String?) -> Self {
        self.suppressionKey = suppressionKey
        return self
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
        guard !isMethodHooked(#selector(self.runModal)) else { return }
        do {
            try hook(#selector(self.runModal), closure: { original, object, sel in
                guard let alert = object as? NSAlert, let suppressionKey = alert.suppressionKey else {
                    return original(object, sel)
                }
                if let supressionKeys: [String] = Defaults.shared["AlertSupressions"], supressionKeys.contains(suppressionKey) {
                    return .suppress
                }
                alert.showsSuppressionButton = true
                let runModal = original(object, sel)
                if alert.suppressionButton?.state == .on {
                    NSAlert.supressionKeys.insert(suppressionKey)
                }
                return runModal
            } as @convention(block) (
                (AnyObject, Selector) -> NSApplication.ModalResponse,
                AnyObject, Selector) -> NSApplication.ModalResponse)
            
            try hook(#selector(self.beginSheetModal(for:completionHandler:)), closure: { original, object, sel, window, handler in
                guard let alert = object as? NSAlert, let suppressionKey = alert.suppressionKey else {
                    original(object, sel, window, handler)
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
                    original(object, sel, window, wrappedHandler)
                }
            } as @convention(block) (
                (AnyObject, Selector, NSWindow, ((NSApplication.ModalResponse) -> Void)?) -> Void,
                AnyObject, Selector, NSWindow, ((NSApplication.ModalResponse) -> Void)?) -> Void)
        } catch {
            Swift.debugPrint()
        }
    }
}

#endif
