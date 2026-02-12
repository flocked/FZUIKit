//
//  NSScreen+.swift
//
//
//  Created by Florian Zand on 10.07.22.
//

#if os(macOS)
import AppKit
import CoreGraphics
import FZSwiftUtils
import IOKit.pwr_mgt

public extension NSScreen {
    /// Returns the identifier of the display.
    var displayID: CGDirectDisplayID? {
        deviceDescription[.screenNumber] as? CGDirectDisplayID
    }

    /// Returns the ordered index of the screen.
    var orderedIndex: Int? {
        let screens = NSScreen.screens.sorted { $0.frame.minX < $1.frame.minX }
        return screens.firstIndex(of: self)
    }

    /// The bounds of the screen in the global display coordinate space.
    var quartzFrame: CGRect? {
        guard let displayID = displayID else { return nil }
        return CGDisplayBounds(displayID)
    }

    /// A Boolean value indicating whether the mouse cursor is visble on the screen.
    var containsMouse: Bool {
        Self.withMouse == self
    }

    /// A Boolean value indicating whether the screen is built-in.
    var isBuiltIn: Bool {
        CGDisplayIsBuiltin(displayID ?? 0) != 0
    }

    /// A Boolean value indicating whether the screen is virtual (e.g. Sidecar or Airplay screens)"
    var isVirtual: Bool {
        localizedName.lowercased().contains(any: ["dummy", "airplay", "sidecar"])
    }

    /// A Boolean value indicating whether the screen is Airplay.
    var isAirplay: Bool {
        localizedName.lowercased().contains("airplay")
    }

    /// A Boolean value indicating whether the screen is Sidecar.
    var isSidecar: Bool {
        localizedName.lowercased().contains("sidecar")
    }

    /// A Boolean value indicating whether the screen is the main screen with the keyboard focus.
    var isMain: Bool {
        self == NSScreen.main
    }
    
    /// A Boolean value indicating whether the screen represents the system’s primary display (the one that owns the menu bar).
    var isPrimary: Bool {
        displayID == CGMainDisplayID()
    }

    /// The bounds of the screen in the global display coordinate space.
    var displayBounds: CGRect {
        guard let displayID else {
            debugPrint("ERROR: Failed to get NSScreen.displayID in NSScreen.displayBounds")
            return CGRect(x: frame.minX, y: self.frame.maxY - frame.maxY, width: frame.width, height: frame.height)
        }
        return CGDisplayBounds(displayID)
    }

    /// Returns an image containing the contents of the screen.
    var screenshot: CGImage? {
        guard let displayID = displayID else { return nil }
        return CGDisplayCreateImage(displayID)
    }

    /// Returns the screeen which includes the mouse cursor.
    static var withMouse: NSScreen? {
        let mouseLocation = NSEvent.mouseLocation
        return NSScreen.screens.first { NSMouseInRect(mouseLocation, $0.frame, false) }
    }

    /// Returns the built-in screen.
    static var builtIn: NSScreen? {
        NSScreen.screens.first(where: {$0.isBuiltIn})
    }

    //// Returns the first AirPlay screen.
    static var airplay: NSScreen? {
        NSScreen.screens.first(where: {$0.isAirplay})
    }

    /// Returns the first Sidecar screen.
    static var sidecar: NSScreen? {
        NSScreen.screens.first(where: {$0.isSidecar})
    }

    /**
     Returns the screen that contains a point in screen coordinates.

     - Parameter point: The point which the screen should contain.
     */
    static func screen(at point: NSPoint) -> NSScreen? {
        screens.first(where: { NSMouseInRect(point, $0.frame, false) })
    }
    
    /**
     Returns the screen for the specified frame rectangle in screen coordinates.
     
     - Parameter frame: The frame rectangle in screen coordinates.
     */
    static func screen(for frame: CGRect) -> NSScreen? {
        screens.max {
            $0.frame.intersection(frame).area < $1.frame.intersection(frame).area
        }
    }

    /// Enables screen sleep and returns a Boolean value indicating whether enabling succeeded.
    @discardableResult
    static func enableScreenSleep() -> Bool {
        guard _screenSleepIsDisabled else { return true }
        _screenSleepIsDisabled = !(IOPMAssertionRelease(noSleepAssertionID) == kIOReturnSuccess)
        return !_screenSleepIsDisabled
    }

    /// Disables screen sleep and returns a Boolean value indicating whether disabling succeeded.
    @discardableResult
    static func disableScreenSleep() -> Bool {
        guard !_screenSleepIsDisabled else { return true }
        _screenSleepIsDisabled = IOPMAssertionCreateWithName(kIOPMAssertionTypeNoDisplaySleep as CFString, IOPMAssertionLevel(kIOPMAssertionLevelOn), "Unknown reason" as CFString, &noSleepAssertionID) == kIOReturnSuccess
        return _screenSleepIsDisabled
    }

    /// A Boolean value indicating whether screen sleep is disabled.
    static var screenSleepIsDisabled: Bool {
        get { _screenSleepIsDisabled }
        set { _ = newValue ? disableScreenSleep() : enableScreenSleep() }
    }

    private static var _screenSleepIsDisabled: Bool {
        get { getAssociatedValue("screenSleepIsDisabled", initialValue: false) }
        set { setAssociatedValue(newValue, key: "screenSleepIsDisabled") }
    }

    private static var noSleepAssertionID: IOPMAssertionID {
        get { getAssociatedValue("noSleepAssertionID", initialValue: 0) }
        set { setAssociatedValue(newValue, key: "noSleepAssertionID") }
    }
}

public extension NSDeviceDescriptionKey {
    /// The corresponding value is an `UInt32` value that identifies a `NSScreen` object.
    static let screenNumber = NSDeviceDescriptionKey("NSScreenNumber")
}
#endif
