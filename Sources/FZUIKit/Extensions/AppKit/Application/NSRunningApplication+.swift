//
//  NSRunningApplication+.swift
//
//
//  Created by Florian Zand on 02.11.22.
//

#if os(macOS)
import AppKit

public extension NSRunningApplication {
    /// The frontmost application, which is the app that receives key events.
    class var frontmost: NSRunningApplication? {
        NSWorkspace.shared.frontmostApplication
    }
        
    /// The application that owns the currently displayed menu bar.
    class var menuBarOwning: NSRunningApplication? {
        NSWorkspace.shared.menuBarOwningApplication
    }
        
    /// The running applications.
    class var runningApplications: [NSRunningApplication] {
        NSWorkspace.shared.runningApplications
    }
        
    /**
     The running applications with the specified localized name.
         
     - Parameter name: Tha localized application name.
     */
    class func runningApplications(named name: String) -> [NSRunningApplication] {
        runningApplications.filter({ $0.localizedName == name })
    }
        
}
#endif
