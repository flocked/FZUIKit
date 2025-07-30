//
//  CGEventTypeMask.swift
//  FZUIKit
//
//  Created by Florian Zand on 30.07.25.
//

#if os(macOS)
import AppKit

/// Constants that you use to filter out specific event types from the stream of incoming events.
public struct CGEventTypeMask: OptionSet, Hashable, Codable {
    /// A null event.
    public static let null = Self(1 << CGEventType.null.rawValue)
    /// A left mouse button down event.
    public static let leftMouseDown = Self(1 << CGEventType.leftMouseDown.rawValue)
    /// A left mouse button up event.
    public static let leftMouseUp = Self(1 << CGEventType.leftMouseUp.rawValue)
    /// A left mouse button dragged event.
    public static let leftMouseDragged = Self(1 << CGEventType.leftMouseDragged.rawValue)
    /// A right mouse button down event.
    public static let rightMouseDown = Self(1 << CGEventType.rightMouseDown.rawValue)
    /// A right mouse button up event.
    public static let rightMouseUp = Self(1 << CGEventType.rightMouseUp.rawValue)
    /// A right mouse button dragged event.
    public static let rightMouseDragged = Self(1 << CGEventType.rightMouseDragged.rawValue)
    /// An "other" mouse button down event (usually middle or additional buttons).
    public static let otherMouseDown = Self(1 << CGEventType.otherMouseDown.rawValue)
    /// An "other" mouse button up event (usually middle or additional buttons).
    public static let otherMouseUp = Self(1 << CGEventType.otherMouseUp.rawValue)
    /// An "other" mouse button dragged event (usually middle or additional buttons).
    public static let otherMouseDragged = Self(1 << CGEventType.otherMouseDragged.rawValue)
    /// A mouse moved event.
    public static let mouseMoved = Self(1 << CGEventType.mouseMoved.rawValue)
    /// A scroll wheel event.
    public static let scrollWheel = Self(1 << CGEventType.scrollWheel.rawValue)
    /// A key down event.
    public static let keyDown = Self(1 << CGEventType.keyDown.rawValue)
    /// A key up event.
    public static let keyUp = Self(1 << CGEventType.keyUp.rawValue)
    /// A flags changed event (e.g., modifier keys).
    public static let flagsChanged = Self(1 << CGEventType.flagsChanged.rawValue)
    /// A tablet pointer event.
    public static let tabletPointer = Self(1 << CGEventType.tabletPointer.rawValue)
    /// A tablet proximity event.
    public static let tabletProximity = Self(1 << CGEventType.tabletProximity.rawValue)
    /// A virtual event indicating the tap was disabled due to timeout.
    public static let tapDisabledByTimeout = Self(1 << CGEventType.tapDisabledByTimeout.rawValue)
    /// A virtual event indicating the tap was disabled due to user input.
    public static let tapDisabledByUserInput = Self(1 << CGEventType.tapDisabledByUserInput.rawValue)

    /// All keyboard-related events.
    public static let keyboard: CGEventTypeMask = [.keyDown, .keyUp, .flagsChanged]
    
    /// All mouse-related events.
    public static let mouse: CGEventTypeMask = [.leftMouseDown, .leftMouseUp, .rightMouseDown, .rightMouseUp, .mouseMoved, .leftMouseDragged, .rightMouseDragged, .otherMouseDown, .otherMouseUp, .otherMouseDragged, .scrollWheel]
    
    /// Left mouse events (`leftMouseDown`, `leftMouseUp` & `leftMouseDragged`).
    public static let leftMouse: CGEventTypeMask = [.leftMouseDown, .leftMouseUp, .leftMouseDragged]
    
    /// Right mouse events (`rightMouseDown`, `rightMouseUp` & `rightMouseDragged`).
    public static let rightMouse: CGEventTypeMask = [.rightMouseDown, .rightMouseUp, .rightMouseDragged]
    
    /// Other mouse events (`otherouseDown`, `otherMouseUp` & `otherMouseDragged`).
    public static let otherMouse: CGEventTypeMask = [.otherMouseDown, .otherMouseUp, .otherMouseDragged]
    
    /// All tablet-related events (`tabletPointer` & `tabletProximity`).
    public static let table: CGEventTypeMask = [.tabletPointer, .tabletProximity]
    
    /// All tap-disabling system virtual events.
    public static let allTapDisabling: CGEventTypeMask = [.tapDisabledByTimeout, .tapDisabledByUserInput]
    
    /// All available events.
    public static let all: CGEventTypeMask = [.null, .leftMouseDown, .leftMouseUp, .rightMouseDown, .rightMouseUp, .mouseMoved, .leftMouseDragged, .rightMouseDragged, .keyDown, .keyUp, .flagsChanged, .scrollWheel, .tabletPointer, .tabletProximity, .otherMouseDown, .otherMouseUp, .otherMouseDragged, .tapDisabledByTimeout, .tapDisabledByUserInput]
    
    /// A Boolean value that indicates whether the specified event type intersects with the mask.
    public func intersects(_ type: CGEventType) -> Bool {
        contains(Self(type: type))
    }
    
    public let rawValue: UInt64

    public init(rawValue: UInt64) {
        self.rawValue = rawValue
    }
    
    public init(_ rawValue: UInt64) {
        self.rawValue = rawValue
    }
    
    /// Returns the event mask for the specified type.
    public init(type: CGEventType) {
        switch type {
        case .null: self = .null
        case .leftMouseDown: self = .leftMouseDown
        case .leftMouseUp: self = .leftMouseUp
        case .rightMouseDown: self = .rightMouseDown
        case .rightMouseUp: self = .rightMouseUp
        case .mouseMoved: self = .mouseMoved
        case .leftMouseDragged: self = .leftMouseDragged
        case .rightMouseDragged: self = .rightMouseDragged
        case .keyDown: self = .keyDown
        case .keyUp: self = .keyUp
        case .flagsChanged: self = .flagsChanged
        case .scrollWheel: self = .scrollWheel
        case .tabletPointer: self = .tabletPointer
        case .tabletProximity: self = .tabletProximity
        case .otherMouseDown: self = .otherMouseDown
        case .otherMouseUp: self = .otherMouseUp
        case .otherMouseDragged: self = .otherMouseDragged
        case .tapDisabledByTimeout: self = .tapDisabledByTimeout
        case .tapDisabledByUserInput: self = .tapDisabledByUserInput
        default: self = []
        }
    }
}

public extension CGEvent {
    /**
     Creates an event tap.
     
     - Parameters:
        - mask: The events to be observed.
        - tap: The location of the new event tap. Only processes running as the root user may locate an event tap at the point where HID events enter the window server; for other users, this method returns `nil`.
        - place: The placement of the new event tap in the list of active event taps.
        - options: A constant that specifies whether the new event tap is a passive listener or an active filter.
        - userInfo: A pointer to user-defined data. This pointer is passed into the callback function specified in the callback parameter.
        - callback: An event tap callback function that you provide. Your callback function is invoked from the run loop to which the event tap is added as a source. The thread safety of the callback is defined by the run loop’s environment. To learn more about event tap callbacks, see [CGEventTapCallBack](https://developer.apple.com/documentation/coregraphics/cgeventtapcallback)].
     
     - Returns: The mach port that represents the new event tap, or `nil` if the event tap could not be created.
     */
    class func tapCreate(for mask: CGEventTypeMask, tap: CGEventTapLocation, place: CGEventTapPlacement = .tailAppendEventTap, options: CGEventTapOptions = .defaultTap, userInfo: UnsafeMutableRawPointer? = nil, callback: CGEventTapCallBack) -> CFMachPort? {
        tapCreate(tap: tap, place: place, options: options, eventsOfInterest: mask.rawValue, callback: callback, userInfo: userInfo)
    }
    
    /**
     Creates an event tap for the specified process.
     
     - Parameters:
        - mask: The events to be observed.
        - processSerialNumber: The process to monitor.
        - place: The placement of the new event tap in the list of active event taps.
        - options: A constant that specifies whether the new event tap is a passive listener or an active filter.
        - userInfo: A pointer to user-defined data. This pointer is passed into the callback function specified in the callback parameter.
        - callback: An event tap callback function that you provide. Your callback function is invoked from the run loop to which the event tap is added as a source. The thread safety of the callback is defined by the run loop’s environment. To learn more about event tap callbacks, see [CGEventTapCallBack](https://developer.apple.com/documentation/coregraphics/cgeventtapcallback)].
     
     - Returns: The mach port that represents the new event tap, or `nil` if the event tap could not be created.
     */
    class func tapCreate(for mask: CGEventTypeMask, processSerialNumber: UnsafeMutableRawPointer, place: CGEventTapPlacement = .tailAppendEventTap, options: CGEventTapOptions = .defaultTap, userInfo: UnsafeMutableRawPointer? = nil, callback: CGEventTapCallBack) -> CFMachPort? {
        tapCreateForPSN(processSerialNumber: processSerialNumber, place: place, options: options, eventsOfInterest: mask.rawValue, callback: callback, userInfo: userInfo)
    }
    
    /**
     Creates an event tap for the specified process identifier.
     
     - Parameters:
        - mask: The events to be observed.
        - pid: The process identifier.
        - place: The placement of the new event tap in the list of active event taps.
        - options: A constant that specifies whether the new event tap is a passive listener or an active filter.
        - userInfo: A pointer to user-defined data. This pointer is passed into the callback function specified in the callback parameter.
        - callback: An event tap callback function that you provide. Your callback function is invoked from the run loop to which the event tap is added as a source. The thread safety of the callback is defined by the run loop’s environment. To learn more about event tap callbacks, see [CGEventTapCallBack](https://developer.apple.com/documentation/coregraphics/cgeventtapcallback)].
     
     - Returns: The mach port that represents the new event tap, or `nil` if the event tap could not be created.
     */
    class func tapCreate(for mask: CGEventTypeMask, pid: pid_t, place: CGEventTapPlacement = .tailAppendEventTap, options: CGEventTapOptions = .defaultTap, userInfo: UnsafeMutableRawPointer? = nil, callback: CGEventTapCallBack) -> CFMachPort? {
        tapCreateForPid(pid: pid, place: place, options: options, eventsOfInterest: mask.rawValue, callback: callback, userInfo: userInfo)
    }
}

#endif
