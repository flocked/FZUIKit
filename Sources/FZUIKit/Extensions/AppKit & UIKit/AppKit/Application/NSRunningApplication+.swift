//
//  NSRunningApplication+.swift
//
//
//  Created by Florian Zand on 02.11.22.
//

#if os(macOS)
import AppKit

public extension NSRunningApplication {
    /// Returns the frontmost app, which is the app that receives key events.
    class var frontmostApplication: NSRunningApplication! {
        return NSWorkspace.shared.frontmostApplication
    }

    /// Returns an array of running apps.
    class var runningApplications: [NSRunningApplication] {
        return NSWorkspace.shared.runningApplications
    }
}
#endif
