//
//  AXNotification.swift
//
//
//  Created by Florian Zand on 15.01.25.
//

#if canImport(ApplicationServices)
import ApplicationServices
import Foundation

/// The notification of an accessibility object.
public struct AXNotification: Hashable, RawRepresentable, ExpressibleByStringLiteral {
    public let rawValue: String

    public init(rawValue: String) {
        self.rawValue = rawValue
    }
    
    public init(stringLiteral value: String) {
        self.rawValue = value
    }

    public init(_ notification: CFString) {
        self.init(rawValue: notification as String)
    }
    
    public init(_ rawValue: String) {
        self.rawValue = rawValue
    }
    
    // MARK: - Application notifications
    /// Notification that an application was activated.
    public static let applicationActivated = AXNotification(kAXApplicationActivatedNotification)
    /// Notification that an application was deactivated.
    public static let applicationDeactivated = AXNotification(kAXApplicationDeactivatedNotification)
    /// Notification that an application has been hidden.
    public static let applicationHidden = AXNotification(kAXApplicationHiddenNotification)
    /// Notification that an application is no longer hidden.
    public static let applicationShown = AXNotification(kAXApplicationShownNotification)

    // MARK: - Window notifications
    /// Notification that the main window changed.
    public static let mainWindowChanged = AXNotification(kAXMainWindowChangedNotification)
    /// Notification that the focused window changed.
    public static let focusedWindowChanged = AXNotification(kAXFocusedWindowChangedNotification)
    /// Notification that a window was created.
    public static let windowCreated = AXNotification(kAXWindowCreatedNotification)
    /// Notification that a window was moved (sent at the end of the window-move operation).
    public static let windowMoved = AXNotification(kAXWindowMovedNotification)
    /// Notification that a window was resized (sent at the end of the window-resize operation).
    public static let windowResized = AXNotification(kAXWindowResizedNotification)
    /// Notification that a window was minimized.
    public static let windowMiniaturized = AXNotification(kAXWindowMiniaturizedNotification)
    /// Notification that a window is no longer minimized.
    public static let windowDeminiaturized = AXNotification(kAXWindowDeminiaturizedNotification)

    // MARK: - New Drawer, Sheet, and Help notifications
    /// Notification that a drawer was created.
    public static let drawerCreated = AXNotification(kAXDrawerCreatedNotification)
    /// Notification that a sheet was created.
    public static let sheetCreated = AXNotification(kAXSheetCreatedNotification)
    /// Notification that a help tag was created.
    public static let helpTagCreated = AXNotification(kAXHelpTagCreatedNotification)

    // MARK: - Element notifications
    /// Notification that the focused element has changed.
    public static let focusedElementChanged = AXNotification(kAXFocusedUIElementChangedNotification)
    /// Notification that an element's value changes.
    public static let valueChanged = AXNotification(kAXValueChangedNotification)
    /**
     Notification that an element was disposed of is no longer valid in the target application.
     
     You can still use the local reference with calls like CFEqual (for example, to remove it from a list), but you should not pass it to the accessibility APIs.
     */
    public static let elementDestroyed = AXNotification(kAXUIElementDestroyedNotification)
    /// Notification that an element's busy state has changed.
    public static let elementBusyChanged = AXNotification(kAXElementBusyChangedNotification)
    /// Notification that a different set of children was selected.
    public static let selectedChildrenChanged = AXNotification(kAXSelectedChildrenChangedNotification)
    /// Notification that an element has been resized.
    public static let elementResized = AXNotification(kAXResizedNotification)
    /// Notification that an element has moved.
    public static let elementMoved = AXNotification(kAXMovedNotification)
    /// Notification that an element was created.
    public static let elementCreated = AXNotification(kAXCreatedNotification)

    // MARK: - Menu notifications
    /// Notification that a menu has been opened.
    public static let menuOpened = AXNotification(kAXMenuOpenedNotification)
    /// Notification that a menu has been closed.
    public static let menuClosed = AXNotification(kAXMenuClosedNotification)
    /// Notification that a menu item has been selected.
    public static let menuItemSelected = AXNotification(kAXMenuItemSelectedNotification)

    // MARK: - Table/Outline notifications
    /// Notification that the number of rows in a table has changed.
    public static let rowCountChanged = AXNotification(kAXRowCountChangedNotification)
    /// Notification that the set of selected rows changes.
    public static let selectedRowsChanged = AXNotification(kAXSelectedRowsChangedNotification)
    /// Notification that the selected cells in a table changed.
    public static let selectedCellsChanged = AXNotification(kAXSelectedCellsChangedNotification)
    /// Notification that the set of selected columns changed.
    public static let selectedColumnsChanged = AXNotification(kAXSelectedColumnsChangedNotification)

    // MARK: - Outline notifications
    /// Notification that a row in an outline was expanded.
    public static let rowExpanded = AXNotification(kAXRowExpandedNotification)
    /// Notification that a row in an outline was collapsed.
    public static let rowCollapsed = AXNotification(kAXRowCollapsedNotification)

    // MARK: - Layout and unit notifications
    /// Notification that the measurement units changed.
    public static let unitsChanged = AXNotification(kAXUnitsChangedNotification)
    /// Notification that selected children were moved.
    public static let selectedChildrenMoved = AXNotification(kAXSelectedChildrenMovedNotification)
    /// Posted when an element's layout changes.
    public static let layoutChanged = AXNotification(kAXLayoutChangedNotification)
    
    // MARK: - Text and title notifications
    /// Notification that the selected text changed.
    public static let selectedTextChanged = AXNotification(kAXSelectedTextChangedNotification)
    /// Notification that an element's title changed.
    public static let titleChanged = AXNotification(kAXTitleChangedNotification)

    // MARK: - Announcement notifications
    /// Notification to request an announcement to be spoken.
    public static let announcementRequested = AXNotification(kAXAnnouncementRequestedNotification)
}

extension AXNotification: CustomStringConvertible {
    public var description: String { rawValue }
}
#endif
