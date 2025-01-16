//
//  AXAttribute.swift
//
//
//  Created by Florian Zand on 15.01.25.
//

#if canImport(ApplicationServices)
import ApplicationServices
import Foundation

/// Values that describe the attributes of an accessibility object.
public struct AXAttribute: Hashable, RawRepresentable, ExpressibleByStringLiteral {
    public let rawValue: String

    public init(rawValue: String) {
        self.rawValue = rawValue
    }
    
    public init(stringLiteral value: String) {
        self.rawValue = value
    }

    // MARK: - Informational Attributes
    /// Represents the primary purpose or type of the accessibility element.
    public static let role = AXAttribute(rawValue: kAXRoleAttribute)
    /// Provides a more specific categorization of the element's role.
    public static let subrole = AXAttribute(rawValue: kAXSubroleAttribute)
    /// Provides a localized description of the element's role.
    public static let roleDescription = AXAttribute(rawValue: kAXRoleDescriptionAttribute)
    /// Represents the title or label of the accessibility element.
    public static let title = AXAttribute(rawValue: kAXTitleAttribute)
    /// Provides a descriptive text about the accessibility element.
    public static let description = AXAttribute(rawValue: kAXDescriptionAttribute)
    /// Contains additional contextual help text for the accessibility element.
    public static let help = AXAttribute(rawValue: kAXHelpAttribute)
    /// Represents a unique identifier for the accessibility element.
    public static let identifier = AXAttribute(rawValue: kAXIdentifierAttribute)

    // MARK: - Hierarchy or relationship attributes
    /// Represents the parent element of the accessibility element.
    public static let parent = AXAttribute(rawValue: kAXParentAttribute)
    /// Represents the child elements of the accessibility element.
    public static let children = AXAttribute(rawValue: kAXChildrenAttribute)
    /// Represents the currently selected child elements.
    public static let selectedChildren = AXAttribute(rawValue: kAXSelectedChildrenAttribute)
    /// Represents the child elements that are currently visible.
    public static let visibleChildren = AXAttribute(rawValue: kAXVisibleChildrenAttribute)
    /// Represents the window that contains the accessibility element.
    public static let window = AXAttribute(rawValue: kAXWindowAttribute)
    /// Represents the highest-level UI element containing the element.
    public static let topLevelUIElement = AXAttribute(rawValue: kAXTopLevelUIElementAttribute)
    /// Represents the UI element that serves as the title for the accessibility element.
    public static let titleUIElement = AXAttribute(rawValue: kAXTitleUIElementAttribute)
    /// Represents UI elements for which the current element serves as a title.
    public static let serves = AXAttribute(rawValue: kAXServesAsTitleForUIElementsAttribute)
    /// Represents UI elements that are linked to the accessibility element.
    public static let linkedUIElements = AXAttribute(rawValue: kAXLinkedUIElementsAttribute)
    /// Represents UI elements that share focus with the accessibility element.
    public static let sharedFocusElements = AXAttribute(rawValue: kAXSharedFocusElementsAttribute)

    // MARK: - Visual state attributes
    /// Indicates whether the accessibility element is enabled and can be interacted with.
    public static let isEnabled = AXAttribute(rawValue: kAXEnabledAttribute)
    /// Indicates whether the accessibility element currently has keyboard focus.
    public static let isFocused = AXAttribute(rawValue: kAXFocusedAttribute)
    /// Represents the position of the accessibility element on the screen.
    public static let position = AXAttribute(rawValue: kAXPositionAttribute)
    /// Represents the size (width and height) of the accessibility element.
    public static let size = AXAttribute(rawValue: kAXSizeAttribute)
    /// Represents the frame of the accessibility element.
    public static let frame = AXAttribute(rawValue: "AXFrame")

    // MARK: - Value attributes
    /// Represents the current value of the accessibility element.
    public static let value = AXAttribute(rawValue: kAXValueAttribute)
    /// Provides a textual description of the element's current value.
    public static let valueDescription = AXAttribute(rawValue: kAXValueDescriptionAttribute)
    /// Represents the lowest value the element can take.
    public static let minValue = AXAttribute(rawValue: kAXMinValueAttribute)
    /// Represents the highest value the element can take.
    public static let maxValue = AXAttribute(rawValue: kAXMaxValueAttribute)
    /// Represents the step size for adjusting the element's value.
    public static let valueIncrement = AXAttribute(rawValue: kAXValueIncrementAttribute)
    /// Indicates whether the value cycles back to the minimum when incremented beyond the maximum, and vice versa.
    public static let valueWraps = AXAttribute(rawValue: kAXValueWrapsAttribute)
    /// Represents a list of predefined values that the element can take.
    public static let allowedValues = AXAttribute(rawValue: kAXAllowedValuesAttribute)
    /// Represents placeholder text displayed in the element when no value is set.
    public static let placeholderValue = AXAttribute(rawValue: kAXPlaceholderValueAttribute)

    // MARK: - Text-specific attributes
    /// Represents the currently selected text in the accessibility element.
    public static let selectedText = AXAttribute(rawValue: kAXSelectedTextAttribute)
    /// Represents the range of the currently selected text.
    public static let selectedTextRange = AXAttribute(rawValue: kAXSelectedTextRangeAttribute)
    /// Represents multiple ranges of selected text within the element.
    public static let selectedTextRanges = AXAttribute(rawValue: kAXSelectedTextRangesAttribute)
    /// Represents the range of characters that are currently visible in the element.
    public static let visibleCharacterRange = AXAttribute(rawValue: kAXVisibleCharacterRangeAttribute)
    /// Represents the total number of characters in the element's text content.
    public static let numberOfCharacters = AXAttribute(rawValue: kAXNumberOfCharactersAttribute)
    /// Represents other UI elements that share the same text as the current element.
    public static let sharedTextUIElements = AXAttribute(rawValue: kAXSharedTextUIElementsAttribute)
    /// Represents the character range shared across multiple UI elements.
    public static let sharedCharacterRange = AXAttribute(rawValue: kAXSharedCharacterRangeAttribute)
    /// Represents the line number of the insertion point (caret) in a multi-line text element.
    public static let insertionPointLineNumber = AXAttribute(rawValue: kAXInsertionPointLineNumberAttribute)

    // MARK: - Window, sheet, or drawer-specific attributes
    /// Indicates the main element in a window or interface.
    public static let isMainWindow = AXAttribute(rawValue: kAXMainAttribute)
    /// Indicates whether the window or element is minimized.
    public static let isMinimized = AXAttribute(rawValue: kAXMinimizedAttribute)
    /// Represents the button that closes the window or element.
    public static let closeButton = AXAttribute(rawValue: kAXCloseButtonAttribute)
    /// Represents the button that toggles the zoom state of the window or element.
    public static let zoomButton = AXAttribute(rawValue: kAXZoomButtonAttribute)
    /// Represents the button that toggles the full-screen state of the window or element.
    public static let fullScreenButton = AXAttribute(rawValue: kAXFullScreenButtonAttribute)
    /// Represents the button that minimizes the window or element.
    public static let minimizeButton = AXAttribute(rawValue: kAXMinimizeButtonAttribute)
    /// Represents a button in a toolbar.
    public static let toolbarButton = AXAttribute(rawValue: kAXToolbarButtonAttribute)
    /// Represents a proxy or intermediary for the element.
    public static let proxy = AXAttribute(rawValue: kAXProxyAttribute)
    /// Represents the area of the window or element that allows resizing.
    public static let growArea = AXAttribute(rawValue: kAXGrowAreaAttribute)
    /// Indicates whether the element or window is modal (prevents interaction with other windows).
    public static let isModal = AXAttribute(rawValue: kAXModalAttribute)
    /// Represents the default button in a dialog or window.
    public static let defaultButton = AXAttribute(rawValue: kAXDefaultButtonAttribute)
    /// Represents the button that cancels an action or closes a dialog.
    public static let cancelButton = AXAttribute(rawValue: kAXCancelButtonAttribute)
    /// Indicates whether the window is full screen.
    public static let isFullScreen = AXAttribute(rawValue: "AXFullScreen")

    
    // MARK: - Menu or menu item-specific attributes
    /// Represents the character associated with the command for a menu item.
    public static let menuItemCmdChar = AXAttribute(rawValue: kAXMenuItemCmdCharAttribute)
    /// Represents the virtual key code associated with the command for a menu item.
    public static let menuItemCmdVirtualKey = AXAttribute(rawValue: kAXMenuItemCmdVirtualKeyAttribute)
    /// Represents the visual representation (glyph) of the command for a menu item.
    public static let menuItemCmdGlyph = AXAttribute(rawValue: kAXMenuItemCmdGlyphAttribute)
    /// Represents the modifier keys (e.g., Shift, Control) required for the menu item command.
    public static let menuItemCmdModifiers = AXAttribute(rawValue: kAXMenuItemCmdModifiersAttribute)
    /// Represents the character used to mark the menu item (e.g., an arrow or checkmark).
    public static let menuItemMarkChar = AXAttribute(rawValue: kAXMenuItemMarkCharAttribute)
    /// Represents the primary user interface element associated with the menu item.
    public static let menuItemPrimaryUIElement = AXAttribute(rawValue: kAXMenuItemPrimaryUIElementAttribute)

    // MARK: - Application element-specific attributes
    /// Represents the menu bar for the application or system.
    public static let menuBar = AXAttribute(rawValue: kAXMenuBarAttribute)
    /// Represents all windows associated with the application.
    public static let windows = AXAttribute(rawValue: kAXWindowsAttribute)
    /// Indicates whether the element or window is currently the frontmost or active.
    public static let isFrontmost = AXAttribute(rawValue: kAXFrontmostAttribute)
    /// Indicates whether the element or window is hidden.
    public static let isHidden = AXAttribute(rawValue: kAXHiddenAttribute)
    /// Represents the primary window of the application.
    public static let mainWindow = AXAttribute(rawValue: kAXMainWindowAttribute)
    /// Represents the window that currently has focus.
    public static let focusedWindow = AXAttribute(rawValue: kAXFocusedWindowAttribute)
    /// Represents the UI element that currently has focus.
    public static let focusedUIElement = AXAttribute(rawValue: kAXFocusedUIElementAttribute)
    /// Represents an additional menu bar in the application.
    public static let extrasMenuBar = AXAttribute(rawValue: kAXExtrasMenuBarAttribute)

    // MARK: - Date/time-specific attributes
    /// Represents the hour input field in a time-related UI element.
    public static let hourField = AXAttribute(rawValue: kAXHourFieldAttribute)
    /// Represents the minute input field in a time-related UI element.
    public static let minuteField = AXAttribute(rawValue: kAXMinuteFieldAttribute)
    /// Represents the second input field in a time-related UI element.
    public static let secondField = AXAttribute(rawValue: kAXSecondFieldAttribute)
    /// Represents the AM/PM input field in a time-related UI element.
    public static let ampmField = AXAttribute(rawValue: kAXAMPMFieldAttribute)
    /// Represents the day input field in a date-related UI element.
    public static let dayField = AXAttribute(rawValue: kAXDayFieldAttribute)
    /// Represents the month input field in a date-related UI element.
    public static let monthField = AXAttribute(rawValue: kAXMonthFieldAttribute)
    /// Represents the year input field in a date-related UI element.
    public static let yearField = AXAttribute(rawValue: kAXYearFieldAttribute)

    // MARK: - Table, outline, or browser-specific attributes
    /// Represents the collection of rows in a table-like UI element.
    public static let rows = AXAttribute(rawValue: kAXRowsAttribute)
    /// Represents the rows that are currently visible in a table-like UI element.
    public static let visibleRows = AXAttribute(rawValue: kAXVisibleRowsAttribute)
    /// Represents the rows that are currently selected in a table-like UI element.
    public static let selectedRows = AXAttribute(rawValue: kAXSelectedRowsAttribute)
    /// Represents the collection of columns in a table-like UI element.
    public static let columns = AXAttribute(rawValue: kAXColumnsAttribute)
    /// Represents the columns that are currently visible in a table-like UI element.
    public static let visibleColumns = AXAttribute(rawValue: kAXVisibleColumnsAttribute)
    /// Represents the columns that are currently selected in a table-like UI element.
    public static let selectedColumns = AXAttribute(rawValue: kAXSelectedColumnsAttribute)
    /// Represents the sort order for the rows in a table-like UI element (e.g., ascending or descending).
    public static let sortDirection = AXAttribute(rawValue: kAXSortDirectionAttribute)
    /// Represents the UI elements that serve as column headers in a table-like UI element.
    public static let columnHeaderUIElements = AXAttribute(rawValue: kAXColumnHeaderUIElementsAttribute)
    /// Represents the index or position of a specific element within a collection.
    public static let index = AXAttribute(rawValue: kAXIndexAttribute)
    
    // MARK: - Outline attributes
    /// Represents whether a particular row or group is in a disclosed or expanded state.
    public static let isDisclosed = AXAttribute(rawValue: kAXDisclosingAttribute)
    /// Represents the rows that are currently disclosed or expanded in a hierarchical list.
    public static let disclosedRows = AXAttribute(rawValue: kAXDisclosedRowsAttribute)
    /// Represents the row or group that discloses or expands another row in a hierarchical list.
    public static let disclosedByRow = AXAttribute(rawValue: kAXDisclosedByRowAttribute)
    /// Represents the level of disclosure within a hierarchical element.
    public static let disclosureLevel = AXAttribute(rawValue: kAXDisclosureLevelAttribute)
    
    // MARK: - Matte-specific attributes
    /// Represents the area in a matte (overlay) where content is visible, such as in a modal or dialog.
    public static let matteHole = AXAttribute(rawValue: kAXMatteHoleAttribute)
    /// Represents the UI element contained within a matte or overlay, such as content in a modal.
    public static let matteContentUIElement = AXAttribute(rawValue: kAXMatteContentUIElementAttribute)
    
    // MARK: - Ruler-specific attributes
    /// Represents the UI elements that act as markers in a measurement or graph.
    public static let markerUIElements = AXAttribute(rawValue: kAXMarkerUIElementsAttribute)
    /// Represents the units of measurement used in a UI element, such as pixels, inches, or degrees.
    public static let units = AXAttribute(rawValue: kAXUnitsAttribute)
    /// Provides a description or label for the unit of measurement used in a UI element.
    public static let unitDescription = AXAttribute(rawValue: kAXUnitDescriptionAttribute)
    /// Represents the type or style of a marker, such as a circle, square, or line.
    public static let markerType = AXAttribute(rawValue: kAXMarkerTypeAttribute)
    /// Provides a description or further details about the type of marker used.
    public static let markerTypeDescription = AXAttribute(rawValue: kAXMarkerTypeDescriptionAttribute)
    
    // MARK: - Miscellaneous or role-specific attributes
    /// Represents the horizontal scroll bar of a UI element.
    public static let horizontalScrollBar = AXAttribute(rawValue: kAXHorizontalScrollBarAttribute)
    /// Represents the vertical scroll bar of a UI element.
    public static let verticalScrollBar = AXAttribute(rawValue: kAXVerticalScrollBarAttribute)
    /// Indicates the orientation of a UI element, such as horizontal or vertical.
    public static let orientation = AXAttribute(rawValue: kAXOrientationAttribute)
    /// Represents the header element of a UI component, like a table or list.
    public static let header = AXAttribute(rawValue: kAXHeaderAttribute)
    /// Indicates whether a UI element's content has been edited or modified.
    public static let isEdited = AXAttribute(rawValue: kAXEditedAttribute)
    /// Represents the set of tabs in a UI element, such as a tab view or window.
    public static let tabs = AXAttribute(rawValue: kAXTabsAttribute)
    /// Represents a button that shows additional content when clicked.
    public static let overflowButton = AXAttribute(rawValue: kAXOverflowButtonAttribute)
    /// Represents the name of a file associated with a UI element, such as in a file picker.
    public static let filename = AXAttribute(rawValue: kAXFilenameAttribute)
    /// Indicates whether a collapsible UI element is expanded or not.
    public static let isExpanded = AXAttribute(rawValue: kAXExpandedAttribute)
    /// Represents whether a UI element or item is selected.
    public static let isSelected = AXAttribute(rawValue: kAXSelectedAttribute)
    /// Represents the splitter bars used to resize UI elements, such as in a split view.
    public static let splitters = AXAttribute(rawValue: kAXSplittersAttribute)
    /// Represents the contents of a UI element, such as text in a text field or items in a list.
    public static let contents = AXAttribute(rawValue: kAXContentsAttribute)
    /// Represents the next available content in a UI element, such as in a paginated view.
    public static let nextContents = AXAttribute(rawValue: kAXNextContentsAttribute)
    /// Represents the previous available content in a UI element, such as in a paginated view.
    public static let previousContents = AXAttribute(rawValue: kAXPreviousContentsAttribute)
    /// Represents the document or file associated with a UI element.
    public static let document = AXAttribute(rawValue: kAXDocumentAttribute)
    /// Represents the UI element that allows incrementing a value, such as a stepper.
    public static let incrementor = AXAttribute(rawValue: kAXIncrementorAttribute)
    /// Represents a button that decreases a value, such as in a stepper control.
    public static let decrementButton = AXAttribute(rawValue: kAXDecrementButtonAttribute)
    /// Represents a button that increases a value, such as in a stepper control.
    public static let incrementButton = AXAttribute(rawValue: kAXIncrementButtonAttribute)
    /// Represents the title of a column in a table or list view.
    public static let columnTitle = AXAttribute(rawValue: kAXColumnTitleAttribute)
    /// Represents the URL associated with a UI element, such as a link in a browser.
    public static let url = AXAttribute(rawValue: kAXURLAttribute)
    /// Represents the UI elements used for labeling content or sections.
    public static let labelUIElements = AXAttribute(rawValue: kAXLabelUIElementsAttribute)
    /// Represents the value associated with a label in a UI element.
    public static let labelValue = AXAttribute(rawValue: kAXLabelValueAttribute)
    /// Represents the currently visible menu or context menu in a UI.
    public static let shownMenuUIElement = AXAttribute(rawValue: kAXShownMenuUIElementAttribute)
    /// Indicates whether an application is currently running.
    public static let isApplicationRunning = AXAttribute(rawValue: kAXIsApplicationRunningAttribute)
    /// Represents the currently focused application in the system.
    public static let focusedApplication = AXAttribute(rawValue: kAXFocusedApplicationAttribute)
    /// Indicates whether a UI element is busy performing a task.
    public static let isBusy = AXAttribute(rawValue: kAXElementBusyAttribute)
    /// Indicates whether an alternate user interface is currently visible.
    public static let isAlternateUIVisible = AXAttribute(rawValue: kAXAlternateUIVisibleAttribute)

    // MARK: - Undocumented attributes
    /// Indicates whether the user interface is enhanced for additional metadata for VoiceOver.
    public static let isEnhancedUserInterface = AXAttribute(rawValue: "AXEnhancedUserInterface")
    /**
    /// Indicates whether the user interface is enabled for accessibility with Electron apps.
     
     [See here](https://github.com/electron/electron/pull/10305)  for additional information.
     */
    public static let manualAccessibility = AXAttribute(rawValue: "AXManualAccessibility")

    // MARK: - Level indicator attributes
    /// Represents the warning value of a level indicator.
    public static let warningValue = AXAttribute(rawValue: kAXWarningValueAttribute)
    /// Represents the critical value of a level indicator.
    public static let criticalValue = AXAttribute(rawValue: kAXCriticalValueAttribute)
    
    // MARK: - Search field attributes
    /// Represents the search button of a search field.
    public static let searchButton = AXAttribute(rawValue: kAXSearchButtonAttribute)
    /// Represents the clear button of a search field.
    public static let clearButton = AXAttribute(rawValue: kAXClearButtonAttribute)
    
    static let boolAttributes: [AXAttribute] = [.isBusy, .isEdited, .isMainWindow, .isModal, .isHidden, .isEnabled, .isExpanded, .isFocused, .isSelected, .isDisclosed, .isFrontmost, .isMinimized, .isApplicationRunning, .isAlternateUIVisible, .isEnhancedUserInterface, .isFullScreen]
}

extension AXAttribute: CustomStringConvertible {
    public var description: String {
        rawValue
    }
}
#endif
