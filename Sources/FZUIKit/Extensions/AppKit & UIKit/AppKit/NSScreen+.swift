//
//  NSScreen+.swift
//
//
//  Created by Florian Zand on 10.07.22.
//

#if os(macOS)
import Cocoa
import CoreGraphics

public extension NSScreen {
    /**
     Returns the windows of a application visible on the scrren.

     - Parameters:
        - application: The application for the windows

     - Returns: The visible windows of the application.
     */
    func visibleWindows(for application: NSApplication = NSApp) -> [NSWindow] {
        application.windows.filter { $0.isVisible && $0.screen == self && !$0.isFloatingPanel }
    }

    /// Returns the identifier of the display.
    var displayID: CGDirectDisplayID {
        let key = NSDeviceDescriptionKey(rawValue: "NSScreenNumber")
        return deviceDescription[key] as? CGDirectDisplayID ?? 0
    }

    /// Returns the ordered index of the screen.
    var orderedIndex: Int? {
        let screens = NSScreen.screens.sorted { $0.frame.minX < $1.frame.minX }
        return screens.firstIndex(of: self)
    }

    // Returns the bounds of the screen in the global display coordinate space.
    var quartzFrame: CGRect {
        return CGDisplayBounds(displayID)
    }

    /// A Boolean that indicates whether the mouse cursor is visble on the screen.
    var containsMouse: Bool {
        Self.withMouse == self
    }

    /// Returns the screeen which includes the mouse cursor.
    static var withMouse: NSScreen? {
        let mouseLocation = NSEvent.mouseLocation
        let screens = NSScreen.screens
        let screenWithMouse = (screens.first { NSMouseInRect(mouseLocation, $0.frame, false) })
        return screenWithMouse
    }

    //// Returns the AirPlay screen.
    static var airplay: NSScreen? {
        return NSScreen.screens.first(where: { $0.localizedName.lowercased().contains("airplay") })
    }

    /// Returns the Sidecar screen.
    static var sidecar: NSScreen? {
        return NSScreen.screens.first(where: { $0.localizedName.lowercased().contains("sidecar") })
    }

    /// Returns the built-in screen.
    static var builtIn: NSScreen? {
        return NSScreen.screens.first(where: { CGDisplayIsBuiltin($0.displayID) != 0 })
    }

    /// A Boolean that indicates whether the screen is built-in.
    var isBuiltIn: Bool {
        self == NSScreen.builtIn
    }

    /// A Boolean that indicates whether the screen is virtual (like Sidecar or Airplay screens)
    var isVirtual: Bool {
        var isVirtual = false
        let name = localizedName
        if name.contains("dummy") || name.contains("airplay") || name.contains("sidecar") {
            isVirtual = true
        }
        return isVirtual
    }

    /**
     Returns the screen that contains a point.

     - Parameters:
        - point: The point which the screen should contain

     - Returns: The screen which contains the point.
     */
    static func screen(at point: NSPoint) -> NSScreen? {
        var returnScreen: NSScreen?
        let screens = NSScreen.screens
        for screen in screens {
            if NSMouseInRect(point, screen.frame, false) {
                returnScreen = screen
            }
        }
        return returnScreen
    }
}
#endif
