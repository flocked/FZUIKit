//
//  CGWindowInfo.swift
//  FZUIKit
//
//  Created by Florian Zand on 07.11.25.
//

#if os(macOS)
import AppKit
import FZSwiftUtils

/// Information for a window.
public struct CGWindowInfo: Hashable {
    /// The window identifier, a unique value within the user session representing the window.
    public let windowNumber: CGWindowID
    
    /// The name of the window.
    public let name: String?
    
    /// The process identifier of the process that owns the window.
    public let ownerPID: pid_t
    
    /// The name of the application process which owns the window.
    public let ownerName: String?
    
    /// The application that owns the window.
    public var ownerApplication: NSRunningApplication? {
        NSRunningApplication(processIdentifier: ownerPID)
    }
    
    /// A Boolean value indicating whether the window is ordered on screen.
    public let isOnScreen: Bool
    
    /// The window layer number of the window.
    public let windowLayer: Int
    
    /// The window’s frame rectangle in screen coordinates.
    public let frame: CGRect
    
    /// The alpha value of the window.
    public let alpha: CGFloat
    
    /// An estimate of the memory currently used by the window and its supporting data structures.
    public let memoryUsage: DataSize
    
    /// The sharing state of the window.
    public let sharingState: CGWindowSharingType
    
    /// The backing store type of the window.
    public let backingStore: CGWindowBackingType
    
    /// A Boolean value indicating whether the window's backing store is in video memory.
    public let backingStoreIsInVideoMemory: Bool
    
    /// The screen of the window.
    public var screen: NSScreen? {
        .screen(for: frame)
    }
    
    /// Returns all windows below this window.
    public func windowsBelow(excludeDesktop: Bool = true) -> [Self] {
        Self.onScreen(below: windowNumber, excludingDesktop: excludeDesktop)
    }
    
    /// Returns all windows above this window.
    public func windowsAbove(excludeDesktop: Bool = true) -> [Self] {
        Self.onScreen(above: windowNumber, excludingDesktop: excludeDesktop)
    }
    
    /**
     Returns a refreshed copy of this window’s information.
     
     Use this method to retrieve the most recent state of the window represented by this instance.
     
     The returned information may be identical to the current instance if no window properties have changed.
     
     If the window no longer exists, this method returns `nil`.
     */
    public func refreshed() -> Self? {
        .init(windowNumber: windowNumber)
    }
    
    /**
     Creates a window information for the specified window number.
     
     - Parameter windowNumber: The number identifying the window.
     - Returns: A `CGWindowInfo` instance describing the specified window, or `nil` if the window is no longer available or the window number is invalid.
     */
    public init?(windowNumber: CGWindowID) {
        guard let dict = (CGWindowListCopyWindowInfo(.optionAll, kCGNullWindowID) as? [[CFString: Any]] ?? [])
            .first(where: { $0[typed: kCGWindowNumber] == windowNumber }) else { return nil }
        self.init(dict)
    }
    
    /**
     Creates a window information for the specified window.
     
     - Parameter window: The window whose system-level information to retrieve.
     - Returns: A `CGWindowInfo` instance describing the specified window, or `nil` if the window is no longer available.
     */
    public init?(window: NSWindow) {
        self.init(windowNumber: CGWindowID(window.windowNumber))
    }
    
    init?(_ dict: [CFString: Any]) {
        guard let windowNumber: CGWindowID = dict[typed: kCGWindowNumber],
              let backingStore = CGWindowBackingType(rawValue: dict[typed: kCGWindowStoreType] ?? 111),
              let windowLayer: Int = dict[typed: kCGWindowLayer],
              let frameDict = dict[kCGWindowBounds] as? NSDictionary as CFDictionary?,
              let frame = CGRect(dictionaryRepresentation: frameDict),
              let sharingState = CGWindowSharingType(rawValue: dict[typed: kCGWindowSharingState] ?? 111),
              let alpha: CGFloat = dict[typed: kCGWindowAlpha],
              let ownerPID: pid_t = dict[typed: kCGWindowOwnerPID],
              let memoryUsage: Int = dict[typed: kCGWindowMemoryUsage]
        else {
            return nil
        }
        self.windowNumber = windowNumber
        self.frame = frame
        self.ownerPID = ownerPID
        self.name = dict[typed: kCGWindowName]
        self.isOnScreen = dict[typed: kCGWindowIsOnscreen] ?? false
        self.windowLayer = windowLayer
        self.backingStore = backingStore
        self.sharingState = sharingState
        self.alpha = alpha
        self.memoryUsage = .bytes(memoryUsage)
        self.backingStoreIsInVideoMemory = dict[typed: kCGWindowBackingLocationVideoMemory] ?? false
        self.ownerName = dict[typed: kCGWindowOwnerName]
    }
}

extension CGWindowInfo {
    
    // MARK: - All Windows
    
    /**
     Returns information for all known windows.
     
     - Parameter excludingDesktop: A Boolean value indicating whether to exclude desktop-related windows,
     such as the background picture and desktop icons.
     - Returns: An array of window information objects describing all known windows.
     */
    public static func all(excludingDesktop: Bool = true) -> [CGWindowInfo] {
        var option: CGWindowListOption = .optionAll
        option[.excludeDesktopElements] = excludingDesktop
        return fetch(option)
    }
    
    // MARK: - Application and Process Windows
    
    /**
     Returns information for all windows belonging to the specified application.
     
     - Parameter application: The running application whose windows should be returned.
     - Returns: An array of window information objects belonging to the application.
     */
    public static func forApplication(_ application: NSRunningApplication) -> [CGWindowInfo] {
        forProcess(application.processIdentifier)
    }
    
    /**
     Returns information for all windows belonging to the specified application.

     - Parameter application: The running application whose windows should be returned.
     - Returns: An array of window information objects belonging to the application.
     */
    @_disfavoredOverload
    public static func forApplication(_ application: NSRunningApplication?) -> [CGWindowInfo] {
        guard let application = application else { return [] }
        return forApplication(application)
    }
    
    /**
     Returns information for all windows belonging to applications with the specified name.

     - Parameter name: The name of a running application whose windows should be returned.
     - Returns: An array of window information objects belonging to the application with the specified name.
     */
    public static func forApplication(named name: String) -> [CGWindowInfo] {
        NSRunningApplication.runningApplications(named: name).flatMap(forApplication)
    }
    
    /**
     Returns information for all windows belonging to the specified process identifier.

     - Parameter pid: The process identifier.
     - Returns: An array of window information objects owned by the specified process.
     */
    public static func forProcess(_ pid: pid_t) -> [CGWindowInfo] {
        (CGWindowListCopyWindowInfo(.optionAll, kCGNullWindowID) as? [[CFString: Any]] ?? [])
            .filter { pid == $0[typed: kCGWindowOwnerPID] }
            .compactMap(CGWindowInfo.init)
    }
    
    /**
     Returns information for all windows belonging to applications with the specified bundle identifier.

     - Parameter identifier: The bundle identifier.
     - Returns: An array of window information objects belonging to matching applications.
     */
    public static func forBundleIdentifier(_ identifier: String) -> [CGWindowInfo] {
        NSRunningApplication.runningApplications(withBundleIdentifier: identifier).flatMap(forApplication)
    }
    
    // MARK: - On-Screen Windows
    
    /**
     Returns information for all windows currently visible on screen.

     - Parameter excludingDesktop: A Boolean value indicating whether to exclude desktop-related windows,
       such as the background picture and desktop icons.
     - Returns: An array of window information objects describing visible windows.
     */
    public static func onScreen(excludingDesktop: Bool = true) -> [CGWindowInfo] {
        var option: CGWindowListOption = .optionOnScreenOnly
        option[.excludeDesktopElements] = excludingDesktop
        return fetch(option)
    }
    
    /**
     Returns information for all windows on screen above the window with the specified window identifier.

     - Parameters:
        - windowNumber: The reference window identifier.
        - includingWindow: A Boolean value indicating whether the reference window should be included in the results.
        - excludingDesktop: A Boolean value indicating whether to exclude desktop-related windows.
     - Returns: An array of window information objects describing windows above the specified one.
     */
    public static func onScreen(above windowNumber: CGWindowID, includingWindow: Bool = false, excludingDesktop: Bool = true) -> [CGWindowInfo] {
        var option: CGWindowListOption = .optionOnScreenAboveWindow
        option[.excludeDesktopElements] = excludingDesktop
        option[.optionIncludingWindow] = includingWindow
        return fetch(option, relativeTo: windowNumber)
    }
    
    /**
     Returns information for all windows on screen above the specified window.

     - Parameters:
        - window: The reference window.
        - includingWindow: A Boolean value indicating whether the reference window should be included in the results.
        - excludingDesktop: A Boolean value indicating whether to exclude desktop-related windows.
     - Returns: An array of window information objects describing windows above the specified one.
     */
    public static func onScreen(above window: NSWindow, includingWindow: Bool = false, excludingDesktop: Bool = true) -> [CGWindowInfo] {
        onScreen(above: CGWindowID(window.windowNumber), includingWindow: includingWindow, excludingDesktop: excludingDesktop)
    }
    
    /**
     Returns information for all windows on screen below the window with the specified window identifier.

     - Parameters:
        - windowNumber: The reference window identifier.
        - includingWindow: A Boolean value indicating whether the reference window should be included in the results.
        - excludingDesktop: A Boolean value indicating whether to exclude desktop-related windows.
     - Returns: An array of window information objects describing windows below the specified one.
     */
    public static func onScreen(below windowNumber: CGWindowID, includingWindow: Bool = false, excludingDesktop: Bool = true) -> [CGWindowInfo] {
        var option: CGWindowListOption = .optionOnScreenBelowWindow
        option[.excludeDesktopElements] = excludingDesktop
        option[.optionIncludingWindow] = includingWindow
        return fetch(option, relativeTo: windowNumber)
    }
    
    /**
     Returns information for all windows on screen below the specified window.

     - Parameters:
        - window: The reference window.
        - includingWindow: A Boolean value indicating whether the reference window should be included in the results.
        - excludingDesktop: A Boolean value indicating whether to exclude desktop-related windows.
     - Returns: An array of window information objects describing windows below the specified one.
     */
    public static func onScreen(below window: NSWindow, includingWindow: Bool = false, excludingDesktop: Bool = true) -> [CGWindowInfo] {
        onScreen(below: CGWindowID(window.windowNumber), includingWindow: includingWindow, excludingDesktop: excludingDesktop)
    }
    
    // MARK: - Private
    
    private static func fetch(_ options: CGWindowListOption, relativeTo windowID: CGWindowID? = nil) -> [CGWindowInfo] {
        (CGWindowListCopyWindowInfo(options, windowID ?? kCGNullWindowID) as? [[CFString: Any]])?.compactMap(CGWindowInfo.init) ?? []
    }
}

extension CGWindowInfo: CustomStringConvertible, CustomDebugStringConvertible {
    public var description: String {
        "(window: \(windowString), owner: \(ownerString), frame: \(frame), isOnScreen: \(isOnScreen))"
    }
    
    public var debugDescription: String {
        """
        CGWindowInfo(
            window: \(windowString),
            owner: \(ownerString),
            frame: \(frame),
            isOnScreen: \(isOnScreen),
            alpha: \(alpha),
            windowLayer: \(windowLayer),
            backingStore: \(backingStore),
            backingStoreIsInVideoMemory: \(backingStoreIsInVideoMemory),
            sharingState: \(sharingState),
            memoryUsage: \(memoryUsage.string()) (\(memoryUsage.bytes) bytes)
        )
        """
    }
    
    private var ownerString: String {
        if let name = ownerName {
            return "\(ownerPID) (\"\(name)\")"
        }
        return "\(ownerPID)"
    }
    
    private var windowString: String {
        if let name = name {
            return "\(windowNumber) (\"\(name)\")"
        }
        return "\(windowNumber)"
    }
}

extension NSWindow {
    /// Returns system-level information about the window.
    public var info: CGWindowInfo? {
        CGWindowInfo(window: self)
    }
}

extension NSRunningApplication {
    /// Returns information for all windows belonging to this application.
    public var windows: [CGWindowInfo] {
        CGWindowInfo.forApplication(self)
    }
}

extension CGWindowBackingType: CustomStringConvertible, Hashable {
    public var description: String {
        switch self {
        case .backingStoreRetained: return "retained"
        case .backingStoreNonretained: return "nonRetained"
        default: return "buffered"
        }
    }
}

extension CGWindowSharingType: CustomStringConvertible, Hashable {
    public var description: String {
        switch self {
        case .readOnly: return "readOnly"
        case .readWrite: return "readWrite"
        default: return "none"
        }
    }
}
#endif
