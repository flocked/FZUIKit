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
    /// All visible windows on the active space.
    var visibleWindows: [NSWindow] {
        return windows.filter {
            $0.isVisible && $0.isOnActiveSpace && !$0.isFloatingPanel
        }
    }
    
    /// A boolean value that indicates whether the application is a trusted accessibility client.
    func checkAccessibilityAccess() -> Bool {
        let checkOptPrompt = kAXTrustedCheckOptionPrompt.takeUnretainedValue() as NSString
        let options = [checkOptPrompt: true]
        let accessEnabled = AXIsProcessTrustedWithOptions(options as CFDictionary?)
        return accessEnabled
    }

    /// Relaunches the application (works only for non sandboxed applications).
    func relaunch() {
        self.launchAnotherInstance()
        NSApp.terminate(self)
    }

    /// Launches another instance of the application (works only for non sandboxed applications).
    func launchAnotherInstance() {
        let path = Bundle.main.bundleURL.path
        Shell.run(.bash, "open", "-n", atPath: path)
    }
}

#endif
