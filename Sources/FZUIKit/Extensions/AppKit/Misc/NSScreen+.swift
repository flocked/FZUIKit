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

         - Parameters:
            - application: The application for the windows

         - Returns: The visible windows of the application.
         */
        func visibleWindows(for application: NSApplication = NSApp) -> [NSWindow] {
            application.windows.filter { $0.isVisible && $0.screen == self && !$0.isFloatingPanel }
        }

        /// Returns the identifier of the display.
        var displayID: CGDirectDisplayID {
            deviceDescription[.screenNumber] as? CGDirectDisplayID ?? 0
        }

        /// Returns the ordered index of the screen.
        var orderedIndex: Int? {
            let screens = NSScreen.screens.sorted { $0.frame.minX < $1.frame.minX }
            return screens.firstIndex(of: self)
        }

        // Returns the bounds of the screen in the global display coordinate space.
        var quartzFrame: CGRect {
            CGDisplayBounds(displayID)
        }

        /// A Boolean value that indicates whether the mouse cursor is visble on the screen.
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
            NSScreen.screens.first(where: { $0.localizedName.lowercased().contains("airplay") })
        }

        /// Returns the Sidecar screen.
        static var sidecar: NSScreen? {
            NSScreen.screens.first(where: { $0.localizedName.lowercased().contains("sidecar") })
        }

        /// Returns the built-in screen.
        static var builtIn: NSScreen? {
            NSScreen.screens.first(where: { CGDisplayIsBuiltin($0.displayID) != 0 })
        }

        /// A Boolean value that indicates whether the screen is built-in.
        var isBuiltIn: Bool {
            self == NSScreen.builtIn
        }

        /// A Boolean value that indicates whether the screen is virtual (e.g. Sidecar or Airplay screens)
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

         - Parameter point: The point which the screen should contain.
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

        /// Disables screen sleep and returns a Boolean value that indicates whether disabling succeeded.
        @discardableResult
        static func disableScreenSleep() -> Bool {
            guard _screenSleepIsDisabled == false else { return true }
            _screenSleepIsDisabled = IOPMAssertionCreateWithName(kIOPMAssertionTypeNoDisplaySleep as CFString,
                                                                 IOPMAssertionLevel(kIOPMAssertionLevelOn),
                                                                 "Unknown reason" as CFString,
                                                                 &noSleepAssertionID) == kIOReturnSuccess
            return _screenSleepIsDisabled
        }

        /// Enables screen sleep and returns a Boolean value that indicates whether enabling succeeded.
        @discardableResult
        static func enableScreenSleep() -> Bool {
            guard _screenSleepIsDisabled == true else { return true }
            _screenSleepIsDisabled = !(IOPMAssertionRelease(noSleepAssertionID) == kIOReturnSuccess)
            return _screenSleepIsDisabled == false
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
