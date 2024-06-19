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
        /**
         Returns the windows of a application visible on the scrren.

         - Parameter application: The application for the windows

         - Returns: The visible windows of the application.
         */
        func visibleWindows(for application: NSApplication = NSApp) -> [NSWindow] {
            application.windows.filter { $0.isVisible && $0.screen == self && !$0.isFloatingPanel }
        }

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

        /// A Boolean value that indicates whether the mouse cursor is visble on the screen.
        var containsMouse: Bool {
            Self.withMouse == self
        }

        /// A Boolean value that indicates whether the screen is built-in.
        var isBuiltIn: Bool {
            CGDisplayIsBuiltin(displayID ?? 0) != 0
        }

        /// A Boolean value that indicates whether the screen is virtual (e.g. Sidecar or Airplay screens)
        var isVirtual: Bool {
            localizedName.contains("dummy") || localizedName.contains("airplay") || localizedName.contains("sidecar")
        }
        
        /// A Boolean value that indicates whether the screen is Airplay.
        var isAirplay: Bool {
            localizedName.lowercased().contains("airplay")
        }
        
        /// A Boolean value that indicates whether the screen is Sidecar.
        var isSidecar: Bool {
            localizedName.lowercased().contains("sidecar")
        }
        
        /// The bounds of the screen in the global display coordinate space.
        var displayBounds: CGRect {
            guard let displayID else {
                debugPrint("ERROR: Failed to get NSScreen.displayID in NSScreen.displayBounds")
                return CGRect(x: frame.minX, y: self.frame.maxY - frame.maxY, width: frame.width, height: frame.height)
            }
            return CGDisplayBounds(displayID)
        }
        
        /// Returns the screeen which includes the mouse cursor.
        static var withMouse: NSScreen? {
            let mouseLocation = NSEvent.mouseLocation
            let screens = NSScreen.screens
            let screenWithMouse = (screens.first { NSMouseInRect(mouseLocation, $0.frame, false) })
            return screenWithMouse
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
         Returns the screen that contains a point.

         - Parameter point: The point which the screen should contain.
         */
        static func screen(at point: NSPoint) -> NSScreen? {
            NSScreen.screens.first(where: { NSMouseInRect(point, $0.frame, false) })
        }
        
        /**
         Enables / Disables the screen sleep and returns a Boolean value that indicates whether it succeeded.

         - Parameter shouldScreenSleep: A Boolean value that indicates whether the screen sleep is enabled.
         */
        @discardableResult
        static func enableScreenSleep(_ shouldScreenSleep: Bool) -> Bool {
            shouldScreenSleep ? enableScreenSleep() : disableScreenSleep()
        }
        
        /// Enables screen sleep and returns a Boolean value that indicates whether enabling succeeded.
        @discardableResult
        private static func enableScreenSleep() -> Bool {
            guard _screenSleepIsDisabled == true else { return true }
            _screenSleepIsDisabled = !(IOPMAssertionRelease(noSleepAssertionID) == kIOReturnSuccess)
            return _screenSleepIsDisabled == false
        }
        
        /// Disables screen sleep and returns a Boolean value that indicates whether disabling succeeded.
        @discardableResult
        private static func disableScreenSleep() -> Bool {
            guard _screenSleepIsDisabled == false else { return true }
            _screenSleepIsDisabled = IOPMAssertionCreateWithName(kIOPMAssertionTypeNoDisplaySleep as CFString,
                                                                 IOPMAssertionLevel(kIOPMAssertionLevelOn),
                                                                 "Unknown reason" as CFString,
                                                                 &noSleepAssertionID) == kIOReturnSuccess
            return _screenSleepIsDisabled
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
