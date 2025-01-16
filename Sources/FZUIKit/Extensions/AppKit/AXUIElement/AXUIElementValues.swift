//
//  AXUIElementValues.swift
//
//
//  Created by Florian Zand on 16.01.25.
//

#if canImport(ApplicationServices) && os(macOS)
import Foundation
import ApplicationServices
import FZSwiftUtils

public class AXUIElementValues {
    let element: AXUIElement
    
    /// Represents the primary purpose or type of the accessibility element.
    public var role: AXRole? {
        element[.role]
    }

    /// Provides a more specific categorization of the element's role.
    public var subrole: AXSubrole? {
        element[.subrole]
    }

    /// Provides a localized description of the element's role.
    public var roleDescription: String? {
        element[.roleDescription]
    }

    /// Represents the title or label of the accessibility element.
    public var title: String? {
        element[.title]
    }

    /// Provides a descriptive text about the accessibility element.
    public var description: String? {
        element[.description]
    }

    /// Contains additional contextual help text for the accessibility element.
    public var help: String? {
        element[.help]
    }

    /// Represents a unique identifier for the accessibility element.
    public var identifier: String? {
        element[.identifier]
    }
    
    /// The process ID associated with this accessibility object.
    public var pID: pid_t? {
        do {
            var pid: pid_t = -1
            try AXUIElementGetPid(element, &pid).throwIfError()
            guard pid > 0 else {
                AXLogger.print(AXError.invalidPid(pid))
                throw AXError.invalidPid(pid)
            }
            return pid
        } catch {
            return nil
        }
    }
    
    /// The window identifier for the accessibility element.
    public var windowID: CGWindowID? {
        do {
            var windowId = CGWindowID(0)
            try _AXUIElementGetWindow(element, &windowId).throwIfError("windowId()")
            return windowId
        } catch {
            AXLogger.print(error, "windowId")
            return nil
        }
    }

    /// Represents the parent element of the accessibility element.
    public var parent: AXUIElement? {
        element[.parent]
    }

    /// Represents the child elements of the accessibility element.
    public var children: [AXUIElement] {
        (element[.children] as [AXUIElement]?) ?? []
    }

    /// Represents the currently selected child elements.
    public var selectedChildren: [AXUIElement] {
        (element[.selectedChildren] as [AXUIElement]?) ?? []
    }

    /// Represents the child elements that are currently visible.
    public var visibleChildren: [AXUIElement] {
        (element[.visibleChildren] as [AXUIElement]?) ?? []
    }

    /// Represents the window that contains the accessibility element.
    public var window: AXUIElement? {
        element[.window]
    }

    /// Represents the highest-level UI element containing the element.
    public var topLevelUIElement: AXUIElement? {
        element[.topLevelUIElement]
    }

    /// Represents the UI element that serves as the title for the accessibility element.
    public var titleUIElement: AXUIElement? {
        element[.titleUIElement]
    }

    /// Represents UI elements for which the current element serves as a title.
    public var servesAsTitleForUIElements: [AXUIElement] {
        (element[.serves] as [AXUIElement]?) ?? []
    }

    /// Represents UI elements that are linked to the accessibility element.
    public var linkedUIElements: [AXUIElement] {
        (element[.linkedUIElements] as [AXUIElement]?) ?? []
    }

    /// Represents UI elements that share focus with the accessibility element.
    public var sharedFocusElements: [AXUIElement] {
        (element[.sharedFocusElements] as [AXUIElement]?) ?? []
    }
    
    // MARK: - Visual state attributes
    
    /// Indicates whether the accessibility element is enabled and can be interacted with.
    public var isEnabled: Bool? {
        element[.isEnabled]
    }

    /// Indicates whether the accessibility element currently has keyboard focus.
    public var isFocused: Bool? {
        element[.isFocused]
    }

    /// Represents the position of the accessibility element on the screen.
    public var position: CGPoint? {
        element[.position]
    }

    /// Represents the size (width and height) of the accessibility element.
    public var size: CGSize? {
        element[.size]
    }

    /// Represents the frame of the accessibility element.
    public var frame: CGRect? {
        element[.frame]
    }
    
    // MARK: - Value attributes

    /// Represents the current value of the accessibility element.
    public var value: Any? {
        element[.value]
    }
    
    /// Represents the current string value of the accessibility element.
    public var stringValue: String? {
        element[.value]
    }
    
    /// Represents the current integer value of the accessibility element.
    public var integerValue: Int? {
        element[.value]
    }
    
    /// Represents the current double value of the accessibility element.
    public var doubleValue: Double? {
        element[.value]
    }
    
    /// Represents the current boolean value of the accessibility element.
    public var boolValue: Bool? {
        element[.value]
    }

    /// Provides a textual description of the element's current value.
    public var valueDescription: String? {
        element[.valueDescription]
    }

    /// Represents the lowest value the element can take.
    public var minValue: Any? {
        element[.minValue]
    }

    /// Represents the highest value the element can take.
    public var maxValue: Any? {
        element[.maxValue]
    }

    /// Represents the step size for adjusting the element's value.
    public var valueIncrement: Any? {
        element[.valueIncrement]
    }

    /// Indicates whether the value cycles back to the minimum when incremented beyond the maximum, and vice versa.
    public var valueWraps: Bool? {
        element[.valueWraps]
    }

    /// Represents a list of predefined values that the element can take.
    public var allowedValues: [Any]? {
        element[.allowedValues]
    }

    /// Represents placeholder text displayed in the element when no value is set.
    public var placeholderValue: String? {
        element[.placeholderValue]
    }
    
    // MARK: - Text-specific attributes
    
    /// Represents the currently selected text in the accessibility element.
    public var selectedText: String? {
        get { element[.selectedText] }
        set { element[.selectedText] = newValue }
    }

    /// Represents the range of the currently selected text.
    public var selectedTextRange: NSRange? {
        get { (element[.selectedTextRange] as CFRange?)?.nsRange }
        set { element[.selectedTextRange] = newValue?.cfRange }
    }

    /// Represents multiple ranges of selected text within the element.
    public var selectedTextRanges: [NSRange] {
        ((element[.selectedTextRanges] as [CFRange]?) ?? []).compactMap({ $0.nsRange })
    }

    /// Represents the range of characters that are currently visible in the element.
    public var visibleCharacterRange: NSRange? {
        (element[.visibleCharacterRange] as CFRange?)?.nsRange
    }

    /// Represents the total number of characters in the element's text content.
    public var numberOfCharacters: Int? {
        (element[.numberOfCharacters] as NSNumber?)?.intValue
    }

    /// Represents other UI elements that share the same text as the current element.
    public var sharedTextUIElements: [AXUIElement] {
        (element[.sharedTextUIElements] as [AXUIElement]?) ?? []
    }

    /// Represents the character range shared across multiple UI elements.
    public var sharedCharacterRange: NSRange? {
        (element[.sharedCharacterRange] as CFRange?)?.nsRange
    }

    /// Represents the line number of the insertion point (caret) in a multi-line text element.
    public var insertionPointLineNumber: Int? {
        (element[.insertionPointLineNumber] as NSNumber?)?.intValue
    }
    
    // MARK: - Window, sheet, or drawer-specific attributes

    /// Indicates whether the window represented by this accessibility object is the main application window
    public var isMainWindow: Bool? {
        element[.isMainWindow]
    }

    /// Indicates whether the window or element is minimized.
    public var isMinimized: Bool? {
        element[.isMinimized]
    }

    /// Represents the button that closes the window or element.
    public var closeButton: AXUIElement? {
        element[.closeButton]
    }

    /// Represents the button that toggles the zoom state of the window or element.
    public var zoomButton: AXUIElement? {
        element[.zoomButton]
    }

    /// Represents the button that toggles the full-screen state of the window or element.
    public var fullScreenButton: AXUIElement? {
        element[.fullScreenButton]
    }

    /// Represents the button that minimizes the window or element.
    public var minimizeButton: AXUIElement? {
        element[.minimizeButton]
    }

    /// Represents a button in a toolbar.
    public var toolbarButton: AXUIElement? {
        element[.toolbarButton]
    }

    /// Represents a proxy or intermediary for the element.
    public var proxy: AXUIElement? {
        element[.proxy]
    }

    /// Represents the area of the window or element that allows resizing.
    public var growArea: AXUIElement? {
        element[.growArea]
    }

    /// Indicates whether the element or window is modal (prevents interaction with other windows).
    public var isModal: Bool? {
        element[.isModal]
    }

    /// Represents the default button in a dialog or window.
    public var defaultButton: AXUIElement? {
        element[.defaultButton]
    }

    /// Represents the button that cancels an action or closes a dialog.
    public var cancelButton: AXUIElement? {
        element[.cancelButton]
    }
    
    // MARK: - Menu or menu item-specific attributes

    
    /// Represents the character associated with the command for a menu item.
    public var menuItemCmdChar: String? {
        element[.menuItemCmdChar]
    }

    /// Represents the virtual key code associated with the command for a menu item.
    public var menuItemCmdVirtualKey: Int? {
        (element[.menuItemCmdVirtualKey] as NSNumber?)?.intValue
    }

    /// Represents the visual representation (glyph) of the command for a menu item.
    public var menuItemCmdGlyph: Int? {
        (element[.menuItemCmdGlyph] as NSNumber?)?.intValue
    }

    /// Represents the modifier keys (e.g., Shift, Control) required for the menu item command.
    public var menuItemCmdModifiers: Int? {
        (element[.menuItemCmdModifiers] as NSNumber?)?.intValue
    }

    /// Represents the character used to mark the menu item (e.g., an arrow or checkmark).
    public var menuItemMarkChar: String? {
        element[.menuItemMarkChar]
    }

    /// Represents the primary user interface element associated with the menu item.
    public var menuItemPrimaryUIElement: AXUIElement? {
        element[.menuItemPrimaryUIElement]
    }
    
    // MARK: - Application element-specific attributes
    
    /// Represents the menu bar for the application or system.
    public var menuBar: AXUIElement? {
        element[.menuBar]
    }

    /// Represents all windows associated with the application.
    public var windows: [AXUIElement] {
        (element[.windows] as [AXUIElement]?) ?? []
    }

    /// Indicates whether the application represented by this accessibility object is active.
    public var isFrontmost: Bool? {
        element[.isFrontmost]
    }

    /// Indicates whether the element or window is hidden.
    public var isHidden: Bool? {
        element[.isHidden]
    }

    /// Represents the primary window of the application.
    public var mainWindow: AXUIElement? {
        element[.mainWindow]
    }

    /// Represents the window that currently has focus.
    public var focusedWindow: AXUIElement? {
        element[.focusedWindow]
    }

    /// Represents the UI element that currently has focus.
    public var focusedUIElement: AXUIElement? {
        element[.focusedUIElement]
    }

    /// Represents an additional menu bar in the application.
    public var extrasMenuBar: AXUIElement? {
        element[.extrasMenuBar]
    }
    
    // MARK: - Date/time-specific attributes

    /// Represents the hour input field in a time-related UI element.
    public var hourField: AXUIElement? {
        element[.hourField]
    }

    /// Represents the minute input field in a time-related UI element.
    public var minuteField: AXUIElement? {
        element[.minuteField]
    }

    /// Represents the second input field in a time-related UI element.
    public var secondField: AXUIElement? {
        element[.secondField]
    }

    /// Represents the AM/PM input field in a time-related UI element.
    public var ampmField: AXUIElement? {
        element[.ampmField]
    }

    /// Represents the day input field in a date-related UI element.
    public var dayField: AXUIElement? {
        element[.dayField]
    }

    /// Represents the month input field in a date-related UI element.
    public var monthField: AXUIElement? {
        element[.monthField]
    }

    /// Represents the year input field in a date-related UI element.
    public var yearField: AXUIElement? {
        element[.yearField]
    }
    
    // MARK: - Table, outline, or browser-specific attributes
    
    /// Represents the collection of rows in a table-like UI element.
    public var rows: [AXUIElement] {
        (element[.rows] as [AXUIElement]?) ?? []
    }

    /// Represents the rows that are currently visible in a table-like UI element.
    public var visibleRows: [AXUIElement] {
        (element[.visibleRows] as [AXUIElement]?) ?? []
    }

    /// Represents the rows that are currently selected in a table-like UI element.
    public var selectedRows: [AXUIElement] {
        (element[.selectedRows] as [AXUIElement]?) ?? []
    }

    /// Represents the collection of columns in a table-like UI element.
    public var columns: [AXUIElement] {
        (element[.columns] as [AXUIElement]?) ?? []
    }

    /// Represents the columns that are currently visible in a table-like UI element.
    public var visibleColumns: [AXUIElement] {
        (element[.visibleColumns] as [AXUIElement]?) ?? []
    }

    /// Represents the columns that are currently selected in a table-like UI element.
    public var selectedColumns: [AXUIElement] {
        (element[.selectedColumns] as [AXUIElement]?) ?? []
    }

    /// Represents the sort order for the rows in a table-like UI element (e.g., ascending or descending).
    public var sortDirection: Int? {
        (element[.sortDirection] as NSNumber?)?.intValue
    }

    /// Represents the UI elements that serve as column headers in a table-like UI element.
    public var columnHeaderUIElements: [AXUIElement] {
        (element[.columnHeaderUIElements] as [AXUIElement]?) ?? []
    }

    /// Represents the index or position of a specific element within a collection.
    public var index: Int? {
        (element[.index] as NSNumber?)?.intValue
    }
    
    // MARK: - Outline attributes

    /// Represents whether a particular row or group is in a disclosed or expanded state.
    public var isDisclosed: Bool? {
        element[.isDisclosed]
    }

    /// Represents the rows that are currently disclosed or expanded in a hierarchical list.
    public var disclosedRows: [AXUIElement] {
        (element[.disclosedRows] as [AXUIElement]?) ?? []
    }

    /// Represents the row or group that discloses or expands another row in a hierarchical list.
    public var disclosedByRow: AXUIElement? {
        element[.disclosedByRow]
    }

    /// Represents the level of disclosure within a hierarchical element.
    public var disclosureLevel: Int? {
        (element[.disclosureLevel] as NSNumber?)?.intValue
    }
    
    
    // MARK: - Matte-specific attributes

    /// Represents the area in a matte (overlay) where content is visible, such as in a modal or dialog.
    public var matteHole: CGRect? {
        element[.matteHole]
    }

    /// Represents the UI element contained within a matte or overlay, such as content in a modal.
    public var matteContentUIElement: AXUIElement? {
        element[.matteContentUIElement]
    }
    
    // MARK: - Ruler-specific attributes

    /// Represents the UI elements that act as markers in a measurement or graph.
    public var markerUIElements: [AXUIElement] {
        (element[.markerUIElements] as [AXUIElement]?) ?? []
    }

    /// Represents the units of measurement used in a UI element, such as pixels, inches, or degrees.
    public var units: String? {
        element[.units]
    }

    /// Provides a description or label for the unit of measurement used in a UI element.
    public var unitDescription: String? {
        element[.unitDescription]
    }

    /// Represents the type or style of a marker, such as a circle, square, or line.
    public var markerType: String? {
        element[.markerType]
    }

    /// Provides a description or further details about the type of marker used.
    public var markerTypeDescription: String? {
        element[.markerTypeDescription]
    }

    /// Represents the horizontal scroll bar of a UI element.
    public var horizontalScrollBar: AXUIElement? {
        element[.horizontalScrollBar]
    }

    /// Represents the vertical scroll bar of a UI element.
    public var verticalScrollBar: AXUIElement? {
        element[.verticalScrollBar]
    }

    /// Indicates the orientation of a UI element, such as horizontal or vertical.
    public var orientation: String? {
        element[.orientation]
    }

    /// Represents the header element of a UI component, like a table or list.
    public var header: AXUIElement? {
        element[.header]
    }

    /// Indicates whether a UI element's content has been edited or modified.
    public var isEdited: Bool? {
        element[.isEdited]
    }
    
    /// Represents the set of tabs in a UI element, such as a tab view or window.
    public var tabs: [AXUIElement] {
        (element[.tabs] as [AXUIElement]?) ?? []
    }

    /// Represents a button that shows additional content when clicked.
    public var overflowButton: AXUIElement? {
        element[.overflowButton]
    }

    /// Represents the name of a file associated with a UI element, such as in a file picker.
    public var filename: String? {
        element[.filename]
    }

    /// Indicates whether a collapsible UI element is expanded or not.
    public var isExpanded: Bool? {
        element[.isExpanded]
    }

    /// Represents whether a UI element or item is selected.
    public var isSelected: Bool? {
        element[.isSelected]
    }

    /// Represents the splitter bars used to resize UI elements, such as in a split view.
    public var splitters: [AXUIElement] {
        (element[.splitters] as [AXUIElement]?) ?? []
    }

    /// Represents the contents of a UI element, such as text in a text field or items in a list.
    public var contents: [AXUIElement] {
        (element[.contents] as [AXUIElement]?) ?? []
    }

    /// Represents the next available content in a UI element, such as in a paginated view.
    public var nextContents: AXUIElement? {
        element[.nextContents]
    }

    /// Represents the previous available content in a UI element, such as in a paginated view.
    public var previousContents: AXUIElement? {
        element[.previousContents]
    }

    /// Represents the document or file associated with a UI element.
    public var document: String? {
        element[.document]
    }

    /// Represents the UI element that allows incrementing a value, such as a stepper.
    public var incrementor: AXUIElement? {
        element[.incrementor]
    }
    
    /// Represents a button that decreases a value, such as in a stepper control.
    public var decrementButton: AXUIElement? {
        element[.decrementButton]
    }

    /// Represents a button that increases a value, such as in a stepper control.
    public var incrementButton: AXUIElement? {
        element[.incrementButton]
    }

    /// Represents the title of a column in a table or list view.
    public var columnTitle: String? {
        element[.columnTitle]
    }

    /// Represents the URL associated with a UI element, such as a link in a browser.
    public var url: URL? {
        element[.url]
    }

    /// Represents the UI elements used for labeling content or sections.
    public var labelUIElements: [AXUIElement] {
        (element[.labelUIElements] as [AXUIElement]?) ?? []
    }

    /// Represents the value associated with a label in a UI element.
    public var labelValue: String? {
        element[.labelValue]
    }

    /// Represents the currently visible menu or context menu in a UI.
    public var shownMenuUIElement: AXUIElement? {
        element[.shownMenuUIElement]
    }

    /// Indicates whether an application is currently running.
    public var isApplicationRunning: Bool? {
        element[.isApplicationRunning]
    }

    /// Represents the currently focused application in the system.
    public var focusedApplication: AXUIElement? {
        element[.focusedApplication]
    }

    /// Indicates whether a UI element is busy performing a task.
    public var isBusy: Bool? {
        element[.isBusy]
    }

    /// Indicates whether an alternate user interface is currently visible.
    public var isAlternateUIVisible: Bool? {
        element[.isAlternateUIVisible]
    }
    
    // MARK: - Undocumented attributes

    /// Indicates whether the user interface is enhanced for additional metadata for VoiceOver.
    public var isEnhancedUserInterface: Bool? {
        element[.isEnhancedUserInterface]
    }

    /// Indicates whether the user interface is enabled for accessibility with Electron apps.
    public var manualAccessibility: Bool? {
        element[.manualAccessibility]
    }
    
    // MARK: - Text suite parameterized attributes

    /// Represents the line corresponding to a specific index in the text.
    public func lineForIndex(_ index: Int) -> Int? {
        try? element.get(.lineForIndex, with: index)
    }

    /// Represents the range of characters that form a specific line in the text.
    public func rangeForLine(_ line: Int) -> NSRange? {
        (try? element.get(.rangeForLine, with: line) as CFRange?)?.nsRange
    }

    /// Represents the string corresponding to a specific character range.
    public func stringForRange(_ range: NSRange) -> String? {
        try? element.get(.stringForRange, with: range.cfRange)
    }
    
    /// Represents the character range corresponding to a specific position in the text.
    public func rangeForPosition(_ position: CGPoint) -> NSRange? {
        try? element.get(.rangeForPosition, with: position)
    }

    /// Represents the character range corresponding to a specific index in the text.
    public func rangeForIndex(_ index: Int) -> NSRange? {
        (try? element.get(.rangeForIndex, with: index) as CFRange?)?.nsRange
    }

    /// Represents the bounds (position and size) of a specific character range.
    public func boundsForRange(_ range: NSRange) -> CGRect? {
        try? element.get(.boundsForRange, with: range.cfRange)
    }

    /// Represents the RTF content corresponding to a character range.
    public func rtfForRange(_ range: NSRange) -> Data? {
        try? element.get(.rtfForRange, with: range.cfRange)
    }

    /// Represents the attributed string corresponding to a specific character range.
    public func attributedStringForRange(_ range: NSRange) -> NSAttributedString? {
        try? element.get(.attributedStringForRange, with: range.cfRange)
    }

    /// Represents the style range for a specific index in the text.
    public func styleRangeForIndex(_ index: Int) -> NSRange? {
        (try? element.get(.styleRangeForIndex, with: index) as CFRange?)?.nsRange
    }
    
    // MARK: - Cell-based table parameterized attributes

    /// Represents a specific cell based on its column and row indices.
    public func cellForColumnAndRow(column: Int, row: Int) -> AXUIElement? {
        try? element.get(.cellForColumnAndRow, with: [column, row])
    }
    
    // MARK: - Layout area parameterized attributes

    /// Represents the layout point corresponding to a specific screen point.
    public func layoutPointForScreenPoint(_ screenPoint: CGPoint) -> CGPoint? {
        try? element.get(.layoutPointForScreenPoint, with: screenPoint)
    }

    /// Represents the layout size corresponding to a specific screen size.
    public func layoutSizeForScreenSize(_ screenSize: CGSize) -> CGSize? {
        try? element.get(.layoutSizeForScreenSize, with: screenSize)
    }

    /// Represents the screen point corresponding to a specific layout point.
    public func screenPointForLayoutPoint(_ layoutPoint: CGPoint) -> CGPoint? {
        try? element.get(.screenPointForLayoutPoint, with: layoutPoint)
    }

    /// Represents the screen size corresponding to a specific layout size.
    public func screenSizeForLayoutSize(_ layoutSize: CGSize) -> CGSize? {
        try? element.get(.screenSizeForLayoutSize, with: layoutSize)
    }
    
    // MARK: - Level indicator attributes

    /// Represents the warning value of a level indicator.
    public var warningValue: Double? {
        (element[.warningValue] as NSNumber?)?.doubleValue
    }

    /// Represents the critical value of a level indicator.
    public var criticalValue: Double? {
        (element[.criticalValue] as NSNumber?)?.doubleValue
    }
    
    // MARK: - Search field attributes

    /// Represents the search button of a search field.
    public var searchButton: AXUIElement? {
        element[.searchButton]
    }

    /// Represents the clear button of a search field.
    public var clearButton: AXUIElement? {
        element[.clearButton]
    }


    init(_ element: AXUIElement) {
        self.element = element
    }
}
#endif
