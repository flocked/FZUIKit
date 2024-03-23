//
//  NSApp+.swift
//
//
//  Created by Florian Zand on 14.07.22.
//

#if os(macOS)

    import AppKit
    import Foundation

    public extension NSApplication {
        
        /// Returns a description of the `NSResponder` responder chain starting from the first responder.
        var responderChainDebugDescription: String {
            (self as AnyObject).perform(
                NSSelectorFromString("_eventFirstResponderChainDescription")).takeUnretainedValue() as? String ?? "<Description Unavailable>"
        }
        
        /// All visible windows on the active space.
        var visibleWindows: [NSWindow] {
            windows.filter {
                $0.isVisible && $0.isOnActiveSpace && !$0.isFloatingPanel
            }
        }

        /// A Boolean value that indicates whether the application is a trusted accessibility client.
        func checkAccessibilityAccess() -> Bool {
            let checkOptPrompt = kAXTrustedCheckOptionPrompt.takeUnretainedValue() as NSString
            let options = [checkOptPrompt: true]
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
