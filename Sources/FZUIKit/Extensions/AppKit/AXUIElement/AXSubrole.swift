//
//  AXSubrole.swift
//  
//
//  Created by Florian Zand on 15.01.25.
//

#if canImport(ApplicationServices)
import ApplicationServices
import Foundation

/// The subrole of an accessibility object.
public struct AXSubrole: Hashable, RawRepresentable, ExpressibleByStringLiteral {
    public let rawValue: String

    public init(rawValue: String) {
        self.rawValue = rawValue
    }
    
    public init(stringLiteral value: String) {
        self.rawValue = value
    }

    // MARK: - Standard subroles
    /// A close button (that is, the red button in a window’s title bar that closes the window).
    public static let closeButton = AXSubrole(rawValue: kAXCloseButtonSubrole)
    /// A minimize button (that is, the yellow button in a window’s title bar that minimizes the window).
    public static let minimizeButton = AXSubrole(rawValue: kAXMinimizeButtonSubrole)
    /// A zoom button (that is, the green button in a window’s title bar that zooms the window).
    public static let zoomButton = AXSubrole(rawValue: kAXZoomButtonSubrole)
    /// A toolbar button, typically used to show or hide a window’s toolbar.
    public static let toolbarButton = AXSubrole(rawValue: kAXToolbarButtonSubrole)
    /// A full-screen button that toggles a window’s full-screen state.
    public static let full = AXSubrole(rawValue: kAXFullScreenButtonSubrole)
    /// A secure text field, such as those used to enter passwords.
    public static let secureTextField = AXSubrole(rawValue: kAXSecureTextFieldSubrole)
    /// A row in a table view.
    public static let tableRow = AXSubrole(rawValue: kAXTableRowSubrole)
    /// A row in an outline view.
    public static let outlineRow = AXSubrole(rawValue: kAXOutlineRowSubrole)
    /// An unknown subrole.
    public static let unknown = AXSubrole(rawValue: kAXUnknownSubrole)

    // MARK: - New subroles
    /// A standard window, typically a document window or app main window.
    public static let standardWindow = AXSubrole(rawValue: kAXStandardWindowSubrole)
    /// A dialog window, such as an alert or modal dialog.
    public static let dialog = AXSubrole(rawValue: kAXDialogSubrole)
    /// A system dialog window, such as the Force Quit Applications window.
    public static let systemDialog = AXSubrole(rawValue: kAXSystemDialogSubrole)
    /// A floating window, such as a utility or palette window.
    public static let floatingWindow = AXSubrole(rawValue: kAXFloatingWindowSubrole)
    /// A system floating window, typically reserved for high-priority or system-level utilities.
    public static let systemFloatingWindow = AXSubrole(rawValue: kAXSystemFloatingWindowSubrole)
    /// A decorative element that provides visual context but no interactivity.
    public static let decorative = AXSubrole(rawValue: kAXDecorativeSubrole)
    /// An increment arrow in a stepper control.
    public static let incrementArrow = AXSubrole(rawValue: kAXIncrementArrowSubrole)
    /// A decrement arrow in a stepper control.
    public static let decrementArrow = AXSubrole(rawValue: kAXDecrementArrowSubrole)
    /// An increment page control, such as the "Page Down" button in a scroll bar.
    public static let incrementPage = AXSubrole(rawValue: kAXIncrementPageSubrole)
    /// A decrement page control, such as the "Page Up" button in a scroll bar.
    public static let decrementPage = AXSubrole(rawValue: kAXDecrementPageSubrole)
    /// A button that sorts items in a table view.
    public static let sortButton = AXSubrole(rawValue: kAXSortButtonSubrole)
    /// A search field, typically used to filter content.
    public static let searchField = AXSubrole(rawValue: kAXSearchFieldSubrole)
    /// A timeline control, such as those found in video or audio editing software.
    public static let timeline = AXSubrole(rawValue: kAXTimelineSubrole)
    /// A rating indicator, such as a star rating control.
    public static let ratingIndicator = AXSubrole(rawValue: kAXRatingIndicatorSubrole)
    /// A list of content, such as a file browser or collection view.
    public static let contentList = AXSubrole(rawValue: kAXContentListSubrole)
    /// A definition list, typically used to describe terms and definitions (superseded in macOS 10.9).
    public static let definitionList = AXSubrole(rawValue: kAXDefinitionListSubrole)
    /// A description list, typically used to describe terms and definitions.
    public static let descriptionList = AXSubrole(rawValue: kAXDescriptionListSubrole)
    /// A toggle button, such as a checkbox or switch.
    public static let toggle = AXSubrole(rawValue: kAXToggleSubrole)
    /// A switch control, used to toggle between two states.
    public static let `switch` = AXSubrole(rawValue: kAXSwitchSubrole)

    // MARK: - Dock subroles
    /// An application item in the Dock.
    public static let applicationDockItem = AXSubrole(rawValue: kAXApplicationDockItemSubrole)
    /// A document item in the Dock.
    public static let documentDockItem = AXSubrole(rawValue: kAXDocumentDockItemSubrole)
    /// A folder item in the Dock.
    public static let folderDockItem = AXSubrole(rawValue: kAXFolderDockItemSubrole)
    /// A minimized window item in the Dock.
    public static let minimizedWindowDockItem = AXSubrole(rawValue: kAXMinimizedWindowDockItemSubrole)
    /// A URL item in the Dock, such as a website shortcut.
    public static let urlDockItem = AXSubrole(rawValue: kAXURLDockItemSubrole)
    /// An extra item in the Dock, often added by third-party applications.
    public static let dockExtraDockItem = AXSubrole(rawValue: kAXDockExtraDockItemSubrole)
    /// The Trash item in the Dock.
    public static let trashDockItem = AXSubrole(rawValue: kAXTrashDockItemSubrole)
    /// A separator item in the Dock, typically used to distinguish different sections.
    public static let separatorDockItem = AXSubrole(rawValue: kAXSeparatorDockItemSubrole)
    /// The list of running processes shown in the application switcher.
    public static let process = AXSubrole(rawValue: kAXProcessSwitcherListSubrole)
}
    
#endif
