//
//  NSApplication+.swift
//
//
//  Created by Florian Zand on 14.07.22.
//

#if os(macOS)

import AppKit
import Foundation
import FZSwiftUtils

public extension NSApplication {
    internal var holdcmdQMonitor: NSEvent.Monitor? {
        get { getAssociatedValue("") }
        set { setAssociatedValue(newValue, key: "") }
    }
        
        
        
    /// The app’s activation policy that control whether and how an app may be activated.
    var activationPolicy: NSApplication.ActivationPolicy {
        get { activationPolicy() }
        set { setActivationPolicy(newValue) }
    }
        
    /// Returns a description of the `NSResponder` responder chain starting from the first responder.
    var responderChainDebugDescription: String {
        (self as AnyObject).perform(
            NSSelectorFromString("_eventFirstResponderChainDescription")).takeUnretainedValue() as? String ?? "<Description Unavailable>"
    }
        
    /// All visible windows on the active space.
    var visibleWindows: [NSWindow] {
        windows.filter { $0.isVisible && $0.isOnActiveSpace && !$0.isFloatingPanel }
    }

    /**
     A Boolean value that indicates whether the application is a trusted accessibility client.
         
     - Parameter prompt: Indicates whether the user will be informed if the current process is untrusted. This could be used, for example, on application startup to always warn a user if accessibility is not enabled for the current process. Prompting occurs asynchronously and does not affect the return value.
     */
    func checkAccessibilityAccess(prompt: Bool = true) -> Bool {
        let checkOptPrompt = kAXTrustedCheckOptionPrompt.takeUnretainedValue() as NSString
        let options = [checkOptPrompt: prompt]
        let accessEnabled = AXIsProcessTrustedWithOptions(options as CFDictionary?)
        return accessEnabled
    }

    /// Relaunches the application (works only for non-sandboxed applications).
    func relaunch() {
        launchAnotherInstance()
        NSApp.terminate(self)
    }

    /// Launches another instance of the application (works only for-non sandboxed applications).
    func launchAnotherInstance() {
        let path = Bundle.main.bundleURL.path.replacingOccurrences(of: " ", with: "\\ ")
        shell("open -n \(path)")
    }
        
    /**
     The amount of seconds the user have to press `CMD+Q` to close the app via the keyboard.
     */
    var keyboardTerminationDelay: TimeInterval? {
        get { getAssociatedValue("keyboardTerminationDelay") }
        set {
            setAssociatedValue(newValue, key: "keyboardTerminationDelay")
            if let newValue = newValue {
                slowTerminationKeyDownMonitor = NSEvent.localMonitor(for: .keyDown) { event in
                    if event.keyCode == 12 && event.modifierFlags.contains(.command) {
                        if let startTime = self.slowTerminationStartTime {
                            let timeElapsed = CFAbsoluteTimeGetCurrent() - startTime
                            if timeElapsed >= newValue {
                                NSApp.terminate(nil)
                            }
                        } else {
                            self.slowTerminationStartTime = CFAbsoluteTimeGetCurrent()
                        }
                        return nil
                    } else {
                        self.slowTerminationStartTime = nil
                    }
                    return event
                }
            } else {
                slowTerminationKeyDownMonitor = nil
            }
        }
    }
        
    /// Handlers for the application.
    struct Handlers {
        /// Handler that gets called whenever the application becomes active/inactive.
        public var isActive: ((Bool)->())?
        /// Handler that gets called whenever the application hides/unhides.
        public var isHidden: ((Bool)->())?
        /// Handler that gets called whenever the configuration of the displays attached to the computer is changed.
        public var didChangeScreenParameters: (()->())?
    }
        
    /// The handlers for the application.
    var handlers: Handlers {
        get { getAssociatedValue("handlers", initialValue: Handlers()) }
        set {
            setAssociatedValue(newValue, key: "handlers")
   
            if let isHidden = newValue.isHidden {
                notificationTokens[NSApplication.didHideNotification] = NotificationCenter.default.observe(NSApplication.didHideNotification) { _ in
                    isHidden(true)
                }
                notificationTokens[NSApplication.didUnhideNotification] = NotificationCenter.default.observe(NSApplication.didUnhideNotification) { _ in
                    isHidden(false)
                }
            } else {
                notificationTokens[NSApplication.didHideNotification] = nil
                notificationTokens[NSApplication.didUnhideNotification] = nil
            }
            if let isActive = newValue.isActive {
                notificationTokens[NSApplication.didBecomeActiveNotification] = NotificationCenter.default.observe(NSApplication.didBecomeActiveNotification) { _ in
                    isActive(true)
                }
                notificationTokens[NSApplication.didResignActiveNotification] = NotificationCenter.default.observe(NSApplication.didResignActiveNotification) { _ in
                    isActive(false)
                }
            } else {
                notificationTokens[NSApplication.didBecomeActiveNotification] = nil
                notificationTokens[NSApplication.didResignActiveNotification] = nil
            }
            if let didChangeScreenParameters = handlers.didChangeScreenParameters {
                notificationTokens[NSApplication.didChangeScreenParametersNotification] = NotificationCenter.default.observe(NSApplication.didChangeScreenParametersNotification) { _ in
                    didChangeScreenParameters()
                }
            } else {
                notificationTokens[NSApplication.didChangeScreenParametersNotification] = nil
            }
        }
    }
        
    internal var notificationTokens: [Notification.Name: NotificationToken] {
        get { getAssociatedValue("notificationTokens", initialValue: [:]) }
        set { setAssociatedValue(newValue, key: "notificationTokens") }
    }
                
    internal var slowTerminationKeyDownMonitor: NSEvent.Monitor? {
        get { getAssociatedValue("slowTerminationKeyDownMonitor") }
        set { setAssociatedValue(newValue, key: "slowTerminationKeyDownMonitor") }
    }
        
    internal var slowTerminationStartTime: CFAbsoluteTime? {
        get { getAssociatedValue("slowTerminationStartTime") }
        set { setAssociatedValue(newValue, key: "slowTerminationStartTime") }
    }
}

@discardableResult
fileprivate func shell(_ command: String) -> String {
    let task = Process()
    let pipe = Pipe()
    
    task.standardOutput = pipe
    task.standardError = pipe
    task.arguments = ["-c", command]
    task.launchPath = "/bin/zsh"
    task.standardInput = nil
    task.launch()
    
    let data = pipe.fileHandleForReading.readDataToEndOfFile()
    let output = String(data: data, encoding: .utf8)!
    
    return output
}

#endif
