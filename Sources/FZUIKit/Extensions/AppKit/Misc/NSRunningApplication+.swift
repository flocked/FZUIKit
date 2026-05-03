//
//  NSRunningApplication+.swift
//
//
//  Created by Florian Zand on 03.05.26.
//

#if os(macOS)
import AppKit

public extension NSRunningApplication {
    /// Returns all running applications.
    static var running: [NSRunningApplication] {
        NSWorkspace.shared.runningApplications
    }
    
    /// Returns the frontmost app, which is the app that receives key events.
    static var frontmost: NSRunningApplication? {
        NSWorkspace.shared.frontmostApplication
    }
    
    /// Returns the app that owns the currently displayed menu bar.
    static var menubarOwning: NSRunningApplication? {
        NSWorkspace.shared.menuBarOwningApplication
    }
}
#endif
