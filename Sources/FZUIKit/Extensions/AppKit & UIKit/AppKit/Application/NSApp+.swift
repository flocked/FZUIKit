//
//  NSApp+.swift
//  FZExtensions
//
//  Created by Florian Zand on 14.07.22.
//

#if os(macOS)

    import AppKit
    import Foundation

    public extension NSApplication {
        var visibleWindows: [NSWindow] {
            return windows.filter {
                $0.isVisible && $0.isOnActiveSpace && !$0.isFloatingPanel
            }
        }

        func relaunch() {
            let executablePath = Bundle.main.executablePath! as NSString
            let fileSystemRepresentedPath = executablePath.fileSystemRepresentation
            let fileSystemPath = FileManager.default.string(withFileSystemRepresentation: fileSystemRepresentedPath, length: Int(strlen(fileSystemRepresentedPath)))
            Process.launchedProcess(launchPath: fileSystemPath, arguments: [])
            NSApp.terminate(self)
        }

        func checkAccessibilityAccess() -> Bool {
            let checkOptPrompt = kAXTrustedCheckOptionPrompt.takeUnretainedValue() as NSString
            let options = [checkOptPrompt: true]
            let accessEnabled = AXIsProcessTrustedWithOptions(options as CFDictionary?)
            return accessEnabled
        }

        func launchAnotherInstance() {
            let path = Bundle.main.bundleURL.path
            Shell.run(.bash, "open", "-n", atPath: path)
        }
    }

#endif
