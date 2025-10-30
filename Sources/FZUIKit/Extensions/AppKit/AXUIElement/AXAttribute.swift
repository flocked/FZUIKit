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
    
    public init(_ rawValue: String) {
        self.rawValue = rawValue
    }
    
    public init(stringLiteral value: String) {
        self.rawValue = value
    }
    
    // MARK: - Informational Attributes
    /// Represents the primary purpose or type of the accessibility element.
    public static let role = AXAttribute(kAXRoleAttribute)
    /// Provides a more specific categorization of the element's role.
    public static let subrole = AXAttribute(kAXSubroleAttribute)
    /// Provides a localized description of the element's role.
    public static let roleDescription = AXAttribute(kAXRoleDescriptionAttribute)
    /// Represents the title or label of the accessibility element.
    public static let title = AXAttribute(kAXTitleAttribute)
    /// Provides a descriptive text about the accessibility element.
    public static let description = AXAttribute(kAXDescriptionAttribute)
    /// Contains additional contextual help text for the accessibility element.
    public static let help = AXAttribute(kAXHelpAttribute)
    /// Represents a unique identifier for the accessibility element.
    public static let identifier = AXAttribute(kAXIdentifierAttribute)
    
    // MARK: - Hierarchy or relationship attributes
    /// Represents the parent element of the accessibility element.
    public static let parent = AXAttribute(kAXParentAttribute)
    /// Represents the child elements of the accessibility element.
    public static let children = AXAttribute(kAXChildrenAttribute)
    /// Represents the currently selected child elements.
    public static let selectedChildren = AXAttribute(kAXSelectedChildrenAttribute)
    /// Represents the child elements that are currently visible.
    public static let visibleChildren = AXAttribute(kAXVisibleChildrenAttribute)
    /// Represents the window that contains the accessibility element.
    public static let window = AXAttribute(kAXWindowAttribute)
    /// Represents the highest-level UI element containing the element.
    public static let topLevelUIElement = AXAttribute(kAXTopLevelUIElementAttribute)
    /// Represents the UI element that serves as the title for the accessibility element.
    public static let titleUIElement = AXAttribute(kAXTitleUIElementAttribute)
    /// Represents UI elements for which the current element serves as a title.
    public static let servesAsTitle = AXAttribute(kAXServesAsTitleForUIElementsAttribute)
    /// Represents UI elements that are linked to the accessibility element.
    public static let linkedUIElements = AXAttribute(kAXLinkedUIElementsAttribute)
    /// Represents UI elements that share focus with the accessibility element.
    public static let sharedFocusElements = AXAttribute(kAXSharedFocusElementsAttribute)
    
    // MARK: - Visual state attributes
    /// Indicates whether the accessibility element is enabled and can be interacted with.
    public static let isEnabled = AXAttribute(kAXEnabledAttribute)
    /// Indicates whether the accessibility element currently has keyboard focus.
    public static let isFocused = AXAttribute(kAXFocusedAttribute)
    /// Represents the position of the accessibility element on the screen.
    public static let position = AXAttribute(kAXPositionAttribute)
    /// Represents the size (width and height) of the accessibility element.
    public static let size = AXAttribute(kAXSizeAttribute)
    /// Represents the frame of the accessibility element.
    public static let frame = AXAttribute("AXFrame")
    
    // MARK: - Value attributes
    /// Represents the current value of the accessibility element.
    public static let value = AXAttribute(kAXValueAttribute)
    /// Provides a textual description of the element's current value.
    public static let valueDescription = AXAttribute(kAXValueDescriptionAttribute)
    /// Represents the lowest value the element can take.
    public static let minValue = AXAttribute(kAXMinValueAttribute)
    /// Represents the highest value the element can take.
    public static let maxValue = AXAttribute(kAXMaxValueAttribute)
    /// Represents the step size for adjusting the element's value.
    public static let valueIncrement = AXAttribute(kAXValueIncrementAttribute)
    /// Indicates whether the value cycles back to the minimum when incremented beyond the maximum, and vice versa.
    public static let valueWraps = AXAttribute(kAXValueWrapsAttribute)
    /// Represents a list of predefined values that the element can take.
    public static let allowedValues = AXAttribute(kAXAllowedValuesAttribute)
    /// Represents placeholder text displayed in the element when no value is set.
    public static let placeholderValue = AXAttribute(kAXPlaceholderValueAttribute)
    
    // MARK: - Text-specific attributes
    /// Represents the currently selected text in the accessibility element.
    public static let selectedText = AXAttribute(kAXSelectedTextAttribute)
    /// Represents the range of the currently selected text.
    public static let selectedTextRange = AXAttribute(kAXSelectedTextRangeAttribute)
    /// Represents multiple ranges of selected text within the element.
    public static let selectedTextRanges = AXAttribute(kAXSelectedTextRangesAttribute)
    /// Represents the range of characters that are currently visible in the element.
    public static let visibleCharacterRange = AXAttribute(kAXVisibleCharacterRangeAttribute)
    /// Represents the total number of characters in the element's text content.
    public static let numberOfCharacters = AXAttribute(kAXNumberOfCharactersAttribute)
    /// Represents other UI elements that share the same text as the current element.
    public static let sharedTextUIElements = AXAttribute(kAXSharedTextUIElementsAttribute)
    /// Represents the character range shared across multiple UI elements.
    public static let sharedCharacterRange = AXAttribute(kAXSharedCharacterRangeAttribute)
    /// Represents the line number of the insertion point (caret) in a multi-line text element.
    public static let insertionPointLineNumber = AXAttribute(kAXInsertionPointLineNumberAttribute)
    
    // MARK: - Window, sheet, or drawer-specific attributes
    /// Indicates the main element in a window or interface.
    public static let isMainWindow = AXAttribute(kAXMainAttribute)
    /// Indicates whether the window or element is minimized.
    public static let isMinimized = AXAttribute(kAXMinimizedAttribute)
    /// Represents the button that closes the window or element.
    public static let closeButton = AXAttribute(kAXCloseButtonAttribute)
    /// Represents the button that toggles the zoom state of the window or element.
    public static let zoomButton = AXAttribute(kAXZoomButtonAttribute)
    /// Represents the button that toggles the full-screen state of the window or element.
    public static let fullScreenButton = AXAttribute(kAXFullScreenButtonAttribute)
    /// Represents the button that minimizes the window or element.
    public static let minimizeButton = AXAttribute(kAXMinimizeButtonAttribute)
    /// Represents a button in a toolbar.
    public static let toolbarButton = AXAttribute(kAXToolbarButtonAttribute)
    /// Represents a proxy or intermediary for the element.
    public static let proxy = AXAttribute(kAXProxyAttribute)
    /// Represents the area of the window or element that allows resizing.
    public static let growArea = AXAttribute(kAXGrowAreaAttribute)
    /// Indicates whether the element or window is modal (prevents interaction with other windows).
    public static let isModal = AXAttribute(kAXModalAttribute)
    /// Represents the default button in a dialog or window.
    public static let defaultButton = AXAttribute(kAXDefaultButtonAttribute)
    /// Represents the button that cancels an action or closes a dialog.
    public static let cancelButton = AXAttribute(kAXCancelButtonAttribute)
    /// Indicates whether the window is full screen.
    public static let isFullScreen = AXAttribute("AXFullScreen")
    
    
    // MARK: - Menu or menu item-specific attributes
    /// Represents the character associated with the command for a menu item.
    public static let menuItemCmdChar = AXAttribute(kAXMenuItemCmdCharAttribute)
    /// Represents the virtual key code associated with the command for a menu item.
    public static let menuItemCmdVirtualKey = AXAttribute(kAXMenuItemCmdVirtualKeyAttribute)
    /// Represents the visual representation (glyph) of the command for a menu item.
    public static let menuItemCmdGlyph = AXAttribute(kAXMenuItemCmdGlyphAttribute)
    /// Represents the modifier keys (e.g., Shift, Control) required for the menu item command.
    public static let menuItemCmdModifiers = AXAttribute(kAXMenuItemCmdModifiersAttribute)
    /// Represents the character used to mark the menu item (e.g., an arrow or checkmark).
    public static let menuItemMarkChar = AXAttribute(kAXMenuItemMarkCharAttribute)
    /// Represents the primary user interface element associated with the menu item.
    public static let menuItemPrimaryUIElement = AXAttribute(kAXMenuItemPrimaryUIElementAttribute)
    
    // MARK: - Application element-specific attributes
    /// Represents the menu bar for the application or system.
    public static let menuBar = AXAttribute(kAXMenuBarAttribute)
    /// Represents all windows associated with the application.
    public static let windows = AXAttribute(kAXWindowsAttribute)
    /// Indicates whether the element or window is currently the frontmost or active.
    public static let isFrontmost = AXAttribute(kAXFrontmostAttribute)
    /// Indicates whether the element or window is hidden.
    public static let isHidden = AXAttribute(kAXHiddenAttribute)
    /// Represents the primary window of the application.
    public static let mainWindow = AXAttribute(kAXMainWindowAttribute)
    /// Represents the window that currently has focus.
    public static let focusedWindow = AXAttribute(kAXFocusedWindowAttribute)
    /// Represents the UI element that currently has focus.
    public static let focusedUIElement = AXAttribute(kAXFocusedUIElementAttribute)
    /// Represents an additional menu bar in the application.
    public static let extrasMenuBar = AXAttribute(kAXExtrasMenuBarAttribute)
    
    // MARK: - Date/time-specific attributes
    /// Represents the hour input field in a time-related UI element.
    public static let hourField = AXAttribute(kAXHourFieldAttribute)
    /// Represents the minute input field in a time-related UI element.
    public static let minuteField = AXAttribute(kAXMinuteFieldAttribute)
    /// Represents the second input field in a time-related UI element.
    public static let secondField = AXAttribute(kAXSecondFieldAttribute)
    /// Represents the AM/PM input field in a time-related UI element.
    public static let ampmField = AXAttribute(kAXAMPMFieldAttribute)
    /// Represents the day input field in a date-related UI element.
    public static let dayField = AXAttribute(kAXDayFieldAttribute)
    /// Represents the month input field in a date-related UI element.
    public static let monthField = AXAttribute(kAXMonthFieldAttribute)
    /// Represents the year input field in a date-related UI element.
    public static let yearField = AXAttribute(kAXYearFieldAttribute)
    
    // MARK: - Table, outline, or browser-specific attributes
    /// Represents the collection of rows in a table-like UI element.
    public static let rows = AXAttribute(kAXRowsAttribute)
    /// Represents the rows that are currently visible in a table-like UI element.
    public static let visibleRows = AXAttribute(kAXVisibleRowsAttribute)
    /// Represents the rows that are currently selected in a table-like UI element.
    public static let selectedRows = AXAttribute(kAXSelectedRowsAttribute)
    /// Represents the collection of columns in a table-like UI element.
    public static let columns = AXAttribute(kAXColumnsAttribute)
    /// Represents the columns that are currently visible in a table-like UI element.
    public static let visibleColumns = AXAttribute(kAXVisibleColumnsAttribute)
    /// Represents the columns that are currently selected in a table-like UI element.
    public static let selectedColumns = AXAttribute(kAXSelectedColumnsAttribute)
    /// Represents the sort order for the rows in a table-like UI element (e.g., ascending or descending).
    public static let sortDirection = AXAttribute(kAXSortDirectionAttribute)
    /// Represents the UI elements that serve as column headers in a table-like UI element.
    public static let columnHeaderUIElements = AXAttribute(kAXColumnHeaderUIElementsAttribute)
    /// Represents the index or position of a specific element within a collection.
    public static let index = AXAttribute(kAXIndexAttribute)
    
    // MARK: - Outline attributes
    /// Represents whether a particular row or group is in a disclosed or expanded state.
    public static let isDisclosed = AXAttribute(kAXDisclosingAttribute)
    /// Represents the rows that are currently disclosed or expanded in a hierarchical list.
    public static let disclosedRows = AXAttribute(kAXDisclosedRowsAttribute)
    /// Represents the row or group that discloses or expands another row in a hierarchical list.
    public static let disclosedByRow = AXAttribute(kAXDisclosedByRowAttribute)
    /// Represents the level of disclosure within a hierarchical element.
    public static let disclosureLevel = AXAttribute(kAXDisclosureLevelAttribute)
    
    // MARK: - Matte-specific attributes
    /// Represents the area in a matte (overlay) where content is visible, such as in a modal or dialog.
    public static let matteHole = AXAttribute(kAXMatteHoleAttribute)
    /// Represents the UI element contained within a matte or overlay, such as content in a modal.
    public static let matteContentUIElement = AXAttribute(kAXMatteContentUIElementAttribute)
    
    // MARK: - Ruler-specific attributes
    /// Represents the UI elements that act as markers in a measurement or graph.
    public static let markerUIElements = AXAttribute(kAXMarkerUIElementsAttribute)
    /// Represents the units of measurement used in a UI element, such as pixels, inches, or degrees.
    public static let units = AXAttribute(kAXUnitsAttribute)
    /// Provides a description or label for the unit of measurement used in a UI element.
    public static let unitDescription = AXAttribute(kAXUnitDescriptionAttribute)
    /// Represents the type or style of a marker, such as a circle, square, or line.
    public static let markerType = AXAttribute(kAXMarkerTypeAttribute)
    /// Provides a description or further details about the type of marker used.
    public static let markerTypeDescription = AXAttribute(kAXMarkerTypeDescriptionAttribute)
    
    // MARK: - Miscellaneous or role-specific attributes
    /// Represents the horizontal scroll bar of a UI element.
    public static let horizontalScrollBar = AXAttribute(kAXHorizontalScrollBarAttribute)
    /// Represents the vertical scroll bar of a UI element.
    public static let verticalScrollBar = AXAttribute(kAXVerticalScrollBarAttribute)
    /// Indicates the orientation of a UI element, such as horizontal or vertical.
    public static let orientation = AXAttribute(kAXOrientationAttribute)
    /// Represents the header element of a UI component, like a table or list.
    public static let header = AXAttribute(kAXHeaderAttribute)
    /// Indicates whether a UI element's content has been edited or modified.
    public static let isEdited = AXAttribute(kAXEditedAttribute)
    /// Represents the set of tabs in a UI element, such as a tab view or window.
    public static let tabs = AXAttribute(kAXTabsAttribute)
    /// Represents a button that shows additional content when clicked.
    public static let overflowButton = AXAttribute(kAXOverflowButtonAttribute)
    /// Represents the name of a file associated with a UI element, such as in a file picker.
    public static let filename = AXAttribute(kAXFilenameAttribute)
    /// Indicates whether a collapsible UI element is expanded or not.
    public static let isExpanded = AXAttribute(kAXExpandedAttribute)
    /// Represents whether a UI element or item is selected.
    public static let isSelected = AXAttribute(kAXSelectedAttribute)
    /// Represents the splitter bars used to resize UI elements, such as in a split view.
    public static let splitters = AXAttribute(kAXSplittersAttribute)
    /// Represents the contents of a UI element, such as text in a text field or items in a list.
    public static let contents = AXAttribute(kAXContentsAttribute)
    /// Represents the next available content in a UI element, such as in a paginated view.
    public static let nextContents = AXAttribute(kAXNextContentsAttribute)
    /// Represents the previous available content in a UI element, such as in a paginated view.
    public static let previousContents = AXAttribute(kAXPreviousContentsAttribute)
    /// Represents the document or file associated with a UI element.
    public static let document = AXAttribute(kAXDocumentAttribute)
    /// Represents the UI element that allows incrementing a value, such as a stepper.
    public static let incrementor = AXAttribute(kAXIncrementorAttribute)
    /// Represents a button that decreases a value, such as in a stepper control.
    public static let decrementButton = AXAttribute(kAXDecrementButtonAttribute)
    /// Represents a button that increases a value, such as in a stepper control.
    public static let incrementButton = AXAttribute(kAXIncrementButtonAttribute)
    /// Represents the title of a column in a table or list view.
    public static let columnTitle = AXAttribute(kAXColumnTitleAttribute)
    /// Represents the URL associated with a UI element, such as a link in a browser.
    public static let url = AXAttribute(kAXURLAttribute)
    /// Represents the UI elements used for labeling content or sections.
    public static let labelUIElements = AXAttribute(kAXLabelUIElementsAttribute)
    /// Represents the value associated with a label in a UI element.
    public static let labelValue = AXAttribute(kAXLabelValueAttribute)
    /// Represents the currently visible menu or context menu in a UI.
    public static let shownMenuUIElement = AXAttribute(kAXShownMenuUIElementAttribute)
    /// Indicates whether an application is currently running.
    public static let isApplicationRunning = AXAttribute(kAXIsApplicationRunningAttribute)
    /// Represents the currently focused application in the system.
    public static let focusedApplication = AXAttribute(kAXFocusedApplicationAttribute)
    /// Indicates whether a UI element is busy performing a task.
    public static let isBusy = AXAttribute(kAXElementBusyAttribute)
    /// Indicates whether an alternate user interface is currently visible.
    public static let isAlternateUIVisible = AXAttribute(kAXAlternateUIVisibleAttribute)
    
    // MARK: - Undocumented attributes
    /// Indicates whether the user interface is enhanced for additional metadata for VoiceOver.
    public static let isEnhancedUserInterface = AXAttribute("AXEnhancedUserInterface")
    /**
     Indicates whether the user interface is enabled for accessibility with Electron apps.
     
     [See here](https://github.com/electron/electron/pull/10305)  for additional information.
     */
    public static let manualAccessibility = AXAttribute("AXManualAccessibility")
    
    // MARK: - Level indicator attributes
    /// Represents the warning value of a level indicator.
    public static let warningValue = AXAttribute(kAXWarningValueAttribute)
    /// Represents the critical value of a level indicator.
    public static let criticalValue = AXAttribute(kAXCriticalValueAttribute)
    
    // MARK: - Search field attributes
    /// Represents the search button of a search field.
    public static let searchButton = AXAttribute(kAXSearchButtonAttribute)
    /// Represents the clear button of a search field.
    public static let clearButton = AXAttribute(kAXClearButtonAttribute)
    
    // MARK: - Other
    
    /// Represents the number of rows in a table-like UI element.
    public static let rowCount = AXAttribute(kAXRowCountAttribute)
    /// Represents the number of columns in a table-like UI element.
    public static let columnCount = AXAttribute(kAXColumnCountAttribute)
    /// Indicates whether the rows or cells are ordered by row.
    public static let isOrderedByRow = AXAttribute(kAXOrderedByRowAttribute)
    /// Represents the currently selected cells in a table-like UI element.
    public static let selectedCells = AXAttribute(kAXSelectedCellsAttribute)
    /// Represents the currently visible cells in a table-like UI element.
    public static let visibleCells = AXAttribute(kAXVisibleCellsAttribute)
    /// Represents the UI elements that serve as row headers in a table-like UI element.
    public static let rowHeaderUIElements = AXAttribute(kAXRowHeaderUIElementsAttribute)
    /// Represents the range of row indices in a table-like UI element.
    public static let rowIndexRange = AXAttribute(kAXRowIndexRangeAttribute)
    /// Represents the range of column indices in a table-like UI element.
    public static let columnIndexRange = AXAttribute(kAXColumnIndexRangeAttribute)
    /// Represents the horizontal units used in a ruler or measurement UI element.
    public static let horizontalUnits = AXAttribute(kAXHorizontalUnitsAttribute)
    /// Represents the vertical units used in a ruler or measurement UI element.
    public static let verticalUnits = AXAttribute(kAXVerticalUnitsAttribute)
    /// Provides a description of the horizontal units used in a UI element.
    public static let horizontalUnitDescription = AXAttribute(kAXHorizontalUnitDescriptionAttribute)
    /// Provides a description of the vertical units used in a UI element.
    public static let verticalUnitDescription = AXAttribute(kAXVerticalUnitDescriptionAttribute)
    /// Represents the handles of a UI element, such as resize handles.
    public static let handles = AXAttribute(kAXHandlesAttribute)
    /// Represents the text content of a UI element.
    public static let text = AXAttribute(kAXTextAttribute)
    /// Represents the currently visible text of a UI element.
    public static let visibleText = AXAttribute(kAXVisibleTextAttribute)
    /// Indicates whether the UI element is editable.
    public static let isEditable = AXAttribute(kAXIsEditableAttribute)
    /// Represents the titles of all columns in a table-like UI element.
    public static let columnTitles = AXAttribute(kAXColumnTitlesAttribute)


    static let boolAttributes: [AXAttribute] = [.isBusy, .isEdited, .isMainWindow, .isModal, .isHidden, .isEnabled, .isExpanded, .isFocused, .isSelected, .isDisclosed, .isFrontmost, .isMinimized, .isApplicationRunning, .isAlternateUIVisible, .isEnhancedUserInterface, .isFullScreen, .isOrderedByRow, .isEditable, .manualAccessibility, .servesAsTitle, .valueWraps]
}

extension AXAttribute: CustomStringConvertible {
    public var description: String {
        rawValue
    }
}
#endif
