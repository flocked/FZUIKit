//
//  NSWorkspace+.swift
//
//
//  Created by Florian Zand on 22.04.24.
//

#if os(macOS)
import AppKit
import FZSwiftUtils

public extension NSWorkspace {
    /// Handlers for the workspace.
    struct Handlers {
        /// Handler that gets called whenever the application hides/unhides.
        public var isHidden: ((Bool)->())?
        /// Handler that gets called whenever the active space changed.
        public var activeSpaceChanged: (()->())?
        /// Handler that gets called whenever the device wakes from sleep.
        public var didWake: (()->())?
        /// Handler that gets called whenever the device is about to sleep
        public var willSleep: (()->())?
        /// Handler that gets called whenever a new device mounts.
        public var willPowerOff: (()->())?
        /// Handler that gets called whenever the Finder is about to unmount a device.
        public var didMount: (()->())?
        /// Handler that gets called whenever the Finder is about to unmount a device.
        public var willUnmount: ((URL)->())?
        /// Handler that gets called whenever the Finder unmounts a device.
        public var didUnmount: ((URL)->())?
        /// Handler that gets called whenever the device’s screen goes to sleep.
        public var screensDidSleep: (()->())?
        /// Handler that gets called whenever the device’s screens wake.
        public var screensDidWake: (()->())?
    }
    
    /// The handlers for the workspace.
    var handlers: Handlers {
        get { getAssociatedValue("handlers", initialValue: Handlers()) }
        set {
            setAssociatedValue(newValue, key: "handlers")
            func setup(_ name: Notification.Name, keyPath: KeyPath<NSWorkspace.Handlers, (()->())?>) {
                if let handler = handlers[keyPath: keyPath] {
                    notificationTokens[name] = NotificationCenter.default.observe(name) { _ in
                        handler()
                    }
                } else {
                    notificationTokens[name] = nil
                }
            }
            setup(NSWorkspace.activeSpaceDidChangeNotification, keyPath: \.activeSpaceChanged)
            setup(NSWorkspace.screensDidWakeNotification, keyPath: \.screensDidWake)
            setup(NSWorkspace.screensDidSleepNotification, keyPath: \.screensDidSleep)
            setup(NSWorkspace.didMountNotification, keyPath: \.didMount)
            setup(NSWorkspace.willPowerOffNotification, keyPath: \.willPowerOff)
            setup(NSWorkspace.willSleepNotification, keyPath: \.willSleep)
            setup(NSWorkspace.didWakeNotification, keyPath: \.didWake)
            if let isHidden = newValue.isHidden {
                notificationTokens[NSWorkspace.didHideApplicationNotification] = NotificationCenter.default.observe(NSWorkspace.didHideApplicationNotification) { _ in
                    isHidden(true)
                }
                notificationTokens[NSWorkspace.didUnhideApplicationNotification] = NotificationCenter.default.observe(NSWorkspace.didUnhideApplicationNotification) { _ in
                    isHidden(false)
                }
            } else {
                notificationTokens[NSWorkspace.didHideApplicationNotification] = nil
                notificationTokens[NSWorkspace.didUnhideApplicationNotification] = nil
            }
            if let willUnmount = handlers.willUnmount {
                notificationTokens[NSWorkspace.willUnmountNotification] = NotificationCenter.default.observe(NSWorkspace.willUnmountNotification) { notification in
                    guard let path = notification.userInfo?["NSDevicePath"] as? String else { return }
                    willUnmount(URL(fileURLWithPath: path))
                }
            } else {
                notificationTokens[NSWorkspace.willUnmountNotification] = nil
            }
            if let didUnmount = handlers.didUnmount {
                notificationTokens[NSWorkspace.didUnmountNotification] = NotificationCenter.default.observe(NSWorkspace.didUnmountNotification) { notification in
                    guard let path = notification.userInfo?["NSDevicePath"] as? String else { return }
                    didUnmount(URL(fileURLWithPath: path))
                }
            } else {
                notificationTokens[NSWorkspace.didUnmountNotification] = nil
            }
        }
    }
    
    internal var notificationTokens: [Notification.Name: NotificationToken] {
        get { getAssociatedValue("notificationTokens", initialValue: [:]) }
        set { setAssociatedValue(newValue, key: "notificationTokens") }
    }
    
    /**
     Sets the desktop image for the given screen to the image at the specified URL.
     
     Instead of presenting a user interface for picking the options, choose appropriate defaults and allow the user to adjust them in the System Preference Pane.
     
     You must call this method from your app’s main thread.
     
     - Parameters:
        - url: A file URL to the image. The URL must not be nil.
        - screen: The screen on which to set the desktop image.
        - imageScaling: The scaling of the image.
        - allowClipping: A Boolean value which affects the interpretation of proportional scaling types. When the value is `false`, the workspace object makes the image fully visible, but it may include empty space on the sides or top and bottom. When the value is `true`, the image fills the entire screen, but may be clipped.
        - fillColor: The color for filling the empty space around the image.
     - Returns: `true` if the method set the desktop image; otherwise false. If the method returns false, the error parameter provides additional information.
     */
    func setDesktopImageURL(_ url: URL, for screen: NSScreen, imageScaling: NSImageScaling = .scaleProportionallyUpOrDown, allowClipping: Bool = false, fillColor: NSColor? = nil) throws {
        var options: [NSWorkspace.DesktopImageOptionKey: Any] = [.imageScaling: NSNumber(imageScaling.rawValue), .allowClipping: NSNumber(allowClipping)]
        options[.fillColor] = fillColor
        try setDesktopImageURL(url, for: screen, options: options)
    }
}

public extension NSWorkspace.OpenConfiguration {
    /// Sets the Boolean value indicating whether the system activates the app and brings it to the foreground.
    @discardableResult
    func activates(_ activates: Bool) -> Self {
        self.activates = activates
        return self
    }
    
    /// Sets the Boolean value indicating whether to add the app or documents to the Recent Items menu.
    @discardableResult
    func addsToRecentItems(_ addsToRecentItems: Bool) -> Self {
        self.addsToRecentItems = addsToRecentItems
        return self
    }
    
    /// Sets the Boolean value indicating whether you want the app to hide itself after it launches.
    @discardableResult
    func hides(_ hides: Bool) -> Self {
        self.hides = hides
        return self
    }
    
    /// Sets the Boolean value indicating whether you want to hide all apps except the one that launched.
    @discardableResult
    func hidesOthers(_ hidesOthers: Bool) -> Self {
        self.hidesOthers = hidesOthers
        return self
    }
    
    /// Sets the Boolean value indicating whether to display errors, authentication requests, or other UI elements to the user.
    @discardableResult
    func promptsUserIfNeeded(_ prompts: Bool) -> Self {
        promptsUserIfNeeded = prompts
        return self
    }
    
    /// Sets the Boolean value indicating whether you want to print the contents of documents and URLs instead of opening them.
    @discardableResult
    func isForPrinting(_ isForPrinting: Bool) -> Self {
        self.isForPrinting = isForPrinting
        return self
    }
    
    /// Sets the Boolean value indicating whether you require the URL to have an associated universal link.
    @discardableResult
    func requiresUniversalLinks(_ requires: Bool) -> Self {
        requiresUniversalLinks = requires
        return self
    }
    
    /// Sets the set of command-line arguments to pass to a new app instance at launch time.
    @discardableResult
    func arguments(_ arguments: [String]) -> Self {
        self.arguments = arguments
        return self
    }
    
    /// Sets the first Apple event to send to the new app.
    @discardableResult
    func appleEvent(_ appleEvent: NSAppleEventDescriptor?) -> Self {
        self.appleEvent = appleEvent
        return self
    }
    
    /// Sets the architecture version of the app to launch.
    @discardableResult
    func architecture(_ architecture: cpu_type_t) -> Self {
        self.architecture = architecture
        return self
    }
    
    /// Sets the set of environment variables to set in a new app instance.
    @discardableResult
    func environment(_ environment: [String : String]) -> Self {
        self.environment = environment
        return self
    }
}

#endif
