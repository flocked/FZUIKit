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
        class var frontmost: NSRunningApplication? {
            NSWorkspace.shared.frontmostApplication
        }
        
        /// Returns the app that owns the currently displayed menu bar.
        class var menuBarOwning: NSRunningApplication? {
            NSWorkspace.shared.menuBarOwningApplication
        }
        
        /// Returns an array of running apps.
        class var runningApplications: [NSRunningApplication] {
            NSWorkspace.shared.runningApplications
        }
        
        /**
         Returns an array of running apps with the specified localized name.
         
         - Parameter name: Tha localized application name.
         */
       class func runningApplications(withName name: String) -> [NSRunningApplication] {
           runningApplications.filter({ $0.localizedName == name })
       }
        
    }
#endif
