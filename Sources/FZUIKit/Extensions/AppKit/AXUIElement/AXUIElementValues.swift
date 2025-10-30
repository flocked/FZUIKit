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
    
    /// The primary purpose or type of the accessibility element.
    public var role: AXRole? {
        element[.role]
    }

    /// A more specific categorization of the element's role.
    public var subrole: AXSubrole? {
        element[.subrole]
    }

    /// A localized description of the element's role.
    public var roleDescription: String? {
        element[.roleDescription]
    }

    /// The title or label of the accessibility element.
    public var title: String? {
        element[.title]
    }

    /// A descriptive text about the accessibility element.
    public var description: String? {
        element[.description]
    }

    /// Contains additional contextual help text for the accessibility element.
    public var help: String? {
        element[.help]
    }

    /// A unique identifier for the accessibility element.
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
        DispatchQueue.main.syncSafely {
            do {
                var windowId = CGWindowID(0)
                try _AXUIElementGetWindow(element, &windowId).throwIfError("windowId()")
                return windowId
            } catch {
                AXLogger.print(error, "windowId")
                return nil
            }
        }
    }

    /// The parent element of the accessibility element.
    public var parent: AXUIElement? {
        element[.parent]
    }

    /// The child elements of the accessibility element.
    public var children: [AXUIElement] {
        (element[.children] as [AXUIElement]?) ?? []
    }

    /// The currently selected child elements.
    public var selectedChildren: [AXUIElement] {
        (element[.selectedChildren] as [AXUIElement]?) ?? []
    }

    /// The child elements that are currently visible.
    public var visibleChildren: [AXUIElement] {
        (element[.visibleChildren] as [AXUIElement]?) ?? []
    }

    /// The window that contains the accessibility element.
    public var window: AXUIElement? {
        element[.window]
    }

    /// The highest-level UI element containing the element.
    public var topLevelUIElement: AXUIElement? {
        element[.topLevelUIElement]
    }

    /// The UI element that serves as the title for the accessibility element.
    public var titleUIElement: AXUIElement? {
        element[.titleUIElement]
    }

    /// UI elements for which the current element serves as a title.
    public var servesAsTitleForUIElements: [AXUIElement] {
        (element[.servesAsTitle] as [AXUIElement]?) ?? []
    }

    /// UI elements that are linked to the accessibility element.
    public var linkedUIElements: [AXUIElement] {
        (element[.linkedUIElements] as [AXUIElement]?) ?? []
    }

    /// UI elements that share focus with the accessibility element.
    public var sharedFocusElements: [AXUIElement] {
        (element[.sharedFocusElements] as [AXUIElement]?) ?? []
    }
    
    // MARK: - Visual state attributes
    /// A Boolean value indicating whether the UI element is enabled and can be interacted with.
    public var isEnabled: Bool? {
        element[.isEnabled]
    }
    
    /// A Boolean value indicating whether the UI element currently has keyboard focus.
    public var isFocused: Bool? {
        element[.isFocused]
    }

    /// The position of the accessibility element on the screen.
    public var position: CGPoint? {
        element[.position]
    }

    /// The size (width and height) of the accessibility element.
    public var size: CGSize? {
        element[.size]
    }

    /// The frame of the accessibility element.
    public var frame: CGRect? {
        element[.frame]
    }
    
    // MARK: - Value attributes

    /// The current value of the accessibility element.
    public var value: Any? {
        element[.value]
    }
    
    /// The current string value of the accessibility element.
    public var stringValue: String? {
        element[.value]
    }
    
    /// The current integer value of the accessibility element.
    public var integerValue: Int? {
        element[.value]
    }
    
    /// The current double value of the accessibility element.
    public var doubleValue: Double? {
        element[.value]
    }
    
    /// The current boolean value of the accessibility element.
    public var boolValue: Bool? {
        element[.value]
    }

    /// A textual description of the element's current value.
    public var valueDescription: String? {
        element[.valueDescription]
    }

    /// The lowest value the element can take.
    public var minValue: Any? {
        element[.minValue]
    }

    /// The highest value the element can take.
    public var maxValue: Any? {
        element[.maxValue]
    }

    /// The step size for adjusting the element's value.
    public var valueIncrement: Any? {
        element[.valueIncrement]
    }

    /// A Boolean value indicating whether the value cycles back to the minimum when incremented beyond the maximum, and vice versa.
    public var valueWraps: Bool? {
        element[.valueWraps]
    }

    /// A list of predefined values that the element can take.
    public var allowedValues: [Any]? {
        element[.allowedValues]
    }

    /// The placeholder text displayed in the element when no value is set.
    public var placeholderValue: String? {
        element[.placeholderValue]
    }
    
    // MARK: - Text-specific attributes
    
    /// The currently selected text in the accessibility element.
    public var selectedText: String? {
        get { element[.selectedText] }
        set { element[.selectedText] = newValue }
    }

    /// The range of the currently selected text.
    public var selectedTextRange: NSRange? {
        get { (element[.selectedTextRange] as CFRange?)?.nsRange }
        set { element[.selectedTextRange] = newValue?.cfRange }
    }

    /// Multiple ranges of selected text within the element.
    public var selectedTextRanges: [NSRange] {
        ((element[.selectedTextRanges] as [CFRange]?) ?? []).compactMap({ $0.nsRange })
    }

    /// The range of characters that are currently visible in the element.
    public var visibleCharacterRange: NSRange? {
        (element[.visibleCharacterRange] as CFRange?)?.nsRange
    }

    /// The total number of characters in the element's text content.
    public var numberOfCharacters: Int? {
        (element[.numberOfCharacters] as NSNumber?)?.intValue
    }

    /// Other UI elements that share the same text as the current element.
    public var sharedTextUIElements: [AXUIElement] {
        (element[.sharedTextUIElements] as [AXUIElement]?) ?? []
    }

    /// The character range shared across multiple UI elements.
    public var sharedCharacterRange: NSRange? {
        (element[.sharedCharacterRange] as CFRange?)?.nsRange
    }

    /// The line number of the insertion point (caret) in a multi-line text element.
    public var insertionPointLineNumber: Int? {
        (element[.insertionPointLineNumber] as NSNumber?)?.intValue
    }
    
    // MARK: - Window, sheet, or drawer-specific attributes
    /// A Boolean value indicating whether the window represented by this accessibility object is the main application window.
    public var isMainWindow: Bool? {
        element[.isMainWindow]
    }
    
    /// A Boolean value indicating whether the window or element is minimized.
    public var isMinimized: Bool? {
        element[.isMinimized]
    }
    
    /// A Boolean value indicating whether the window or element is fullscreen.
    public var isFullScreen: Bool? {
        element[.isFullScreen]
    }

    /// The button that closes the window or element.
    public var closeButton: AXUIElement? {
        element[.closeButton]
    }

    /// The button that toggles the zoom state of the window or element.
    public var zoomButton: AXUIElement? {
        element[.zoomButton]
    }

    /// The button that toggles the full-screen state of the window or element.
    public var fullScreenButton: AXUIElement? {
        element[.fullScreenButton]
    }

    /// The button that minimizes the window or element.
    public var minimizeButton: AXUIElement? {
        element[.minimizeButton]
    }

    /// A button in a toolbar.
    public var toolbarButton: AXUIElement? {
        element[.toolbarButton]
    }

    /// A proxy or intermediary for the element.
    public var proxy: AXUIElement? {
        element[.proxy]
    }

    /// The area of the window or element that allows resizing.
    public var growArea: AXUIElement? {
        element[.growArea]
    }
    
    /// A Boolean value indicating whether the element or window is modal (prevents interaction with other windows).
    public var isModal: Bool? {
        element[.isModal]
    }

    /// The default button in a dialog or window.
    public var defaultButton: AXUIElement? {
        element[.defaultButton]
    }

    /// The button that cancels an action or closes a dialog.
    public var cancelButton: AXUIElement? {
        element[.cancelButton]
    }
    
    // MARK: - Menu or menu item-specific attributes

    
    /// The character associated with the command for a menu item.
    public var menuItemCmdChar: String? {
        element[.menuItemCmdChar]
    }

    /// The virtual key code associated with the command for a menu item.
    public var menuItemCmdVirtualKey: Int? {
        (element[.menuItemCmdVirtualKey] as NSNumber?)?.intValue
    }

    /// The visual representation (glyph) of the command for a menu item.
    public var menuItemCmdGlyph: Int? {
        (element[.menuItemCmdGlyph] as NSNumber?)?.intValue
    }

    /// The modifier keys (e.g., Shift, Control) required for the menu item command.
    public var menuItemCmdModifiers: AXMenuItemModifiers? {
        element[.menuItemCmdModifiers]
    }

    /// The character used to mark the menu item (e.g., an arrow or checkmark).
    public var menuItemMarkChar: String? {
        element[.menuItemMarkChar]
    }

    /// The primary user interface element associated with the menu item.
    public var menuItemPrimaryUIElement: AXUIElement? {
        element[.menuItemPrimaryUIElement]
    }
    
    // MARK: - Application element-specific attributes
    
    /// The menu bar for the application or system.
    public var menuBar: AXUIElement? {
        element[.menuBar]
    }

    /// All windows associated with the application.
    public var windows: [AXUIElement] {
        (element[.windows] as [AXUIElement]?) ?? []
    }
    
    /// A Boolean value indicating whether the application represented by this accessibility object is active.
    public var isFrontmost: Bool? {
        element[.isFrontmost]
    }
    
    /// A Boolean value indicating whether the element or window is hidden.
    public var isHidden: Bool? {
        element[.isHidden]
    }

    /// The primary window of the application.
    public var mainWindow: AXUIElement? {
        element[.mainWindow]
    }

    /// The window that currently has focus.
    public var focusedWindow: AXUIElement? {
        element[.focusedWindow]
    }

    /// The UI element that currently has focus.
    public var focusedUIElement: AXUIElement? {
        element[.focusedUIElement]
    }

    /// An additional menu bar in the application.
    public var extrasMenuBar: AXUIElement? {
        element[.extrasMenuBar]
    }
    
    // MARK: - Date/time-specific attributes

    /// The hour input field in a time-related UI element.
    public var hourField: AXUIElement? {
        element[.hourField]
    }

    /// The minute input field in a time-related UI element.
    public var minuteField: AXUIElement? {
        element[.minuteField]
    }

    /// The second input field in a time-related UI element.
    public var secondField: AXUIElement? {
        element[.secondField]
    }

    /// The AM/PM input field in a time-related UI element.
    public var ampmField: AXUIElement? {
        element[.ampmField]
    }

    /// The day input field in a date-related UI element.
    public var dayField: AXUIElement? {
        element[.dayField]
    }

    /// The month input field in a date-related UI element.
    public var monthField: AXUIElement? {
        element[.monthField]
    }

    /// The year input field in a date-related UI element.
    public var yearField: AXUIElement? {
        element[.yearField]
    }
    
    // MARK: - Table, outline, or browser-specific attributes
    
    /// The collection of rows in a table-like UI element.
    public var rows: [AXUIElement] {
        (element[.rows] as [AXUIElement]?) ?? []
    }

    /// The rows that are currently visible in a table-like UI element.
    public var visibleRows: [AXUIElement] {
        (element[.visibleRows] as [AXUIElement]?) ?? []
    }

    /// The rows that are currently selected in a table-like UI element.
    public var selectedRows: [AXUIElement] {
        (element[.selectedRows] as [AXUIElement]?) ?? []
    }

    /// The collection of columns in a table-like UI element.
    public var columns: [AXUIElement] {
        (element[.columns] as [AXUIElement]?) ?? []
    }

    /// The columns that are currently visible in a table-like UI element.
    public var visibleColumns: [AXUIElement] {
        (element[.visibleColumns] as [AXUIElement]?) ?? []
    }

    /// The columns that are currently selected in a table-like UI element.
    public var selectedColumns: [AXUIElement] {
        (element[.selectedColumns] as [AXUIElement]?) ?? []
    }

    /// The sort order for the rows in a table-like UI element (e.g., ascending or descending).
    public var sortDirection: Int? {
        (element[.sortDirection] as NSNumber?)?.intValue
    }

    /// The UI elements that serve as column headers in a table-like UI element.
    public var columnHeaderUIElements: [AXUIElement] {
        (element[.columnHeaderUIElements] as [AXUIElement]?) ?? []
    }

    /// The index or position of a specific element within a collection.
    public var index: Int? {
        (element[.index] as NSNumber?)?.intValue
    }
    
    /// A Boolean value indicating whether the rows or cells are ordered by row.
    public var isOrderedByRow: Bool? {
        element[.isOrderedByRow]
    }
    
    /// The the number of rows in a table-like UI element.
    public var rowCount: Int? {
        element[.rowCount]
    }
    
    /// The the number of columns in a table-like UI element.
    public var columnCount: Int? {
        element[.columnCount]
    }
    
    /// The the currently selected cells in a table-like UI element.
    public var selectedCells: [AXUIElement]? {
        element[.selectedCells]
    }
    
    /// The the currently visible cells in a table-like UI element.
    public var visibleCells: [AXUIElement]? {
        element[.visibleCells]
    }
    /// The the UI elements that serve as row headers in a table-like UI element.
    public var rowHeaderUIElements: [AXUIElement]? {
        element[.rowHeaderUIElements]
    }
    
    /// The the range of row indices in a table-like UI element.
    public var rowIndexRange: NSRange? {
        element[.rowIndexRange]
    }
    
    /// The range of column indices in a table-like UI element.
    public var columnIndexRange: NSRange? {
        element[.columnIndexRange]
    }
    
    // MARK: - Outline attributes
    /// A Boolean value indicating whether a particular row or group is in a disclosed or expanded state.
    public var isDisclosed: Bool? {
        element[.isDisclosed]
    }

    /// The rows that are currently disclosed or expanded in a hierarchical list.
    public var disclosedRows: [AXUIElement] {
        (element[.disclosedRows] as [AXUIElement]?) ?? []
    }

    /// The row or group that discloses or expands another row in a hierarchical list.
    public var disclosedByRow: AXUIElement? {
        element[.disclosedByRow]
    }

    /// The level of disclosure within a hierarchical element.
    public var disclosureLevel: Int? {
        (element[.disclosureLevel] as NSNumber?)?.intValue
    }
    
    
    // MARK: - Matte-specific attributes

    /// The area in a matte (overlay) where content is visible, such as in a modal or dialog.
    public var matteHole: CGRect? {
        element[.matteHole]
    }

    /// The UI element contained within a matte or overlay, such as content in a modal.
    public var matteContentUIElement: AXUIElement? {
        element[.matteContentUIElement]
    }
    
    // MARK: - Ruler-specific attributes

    /// The UI elements that act as markers in a measurement or graph.
    public var markerUIElements: [AXUIElement] {
        (element[.markerUIElements] as [AXUIElement]?) ?? []
    }

    /// The units of measurement used in a UI element, such as pixels, inches, or degrees.
    public var units: String? {
        element[.units]
    }

    /// A description or label for the unit of measurement used in a UI element.
    public var unitDescription: String? {
        element[.unitDescription]
    }

    /// The type or style of a marker, such as a circle, square, or line.
    public var markerType: String? {
        element[.markerType]
    }

    /// A description or further details about the type of marker used.
    public var markerTypeDescription: String? {
        element[.markerTypeDescription]
    }

    /// The horizontal scroll bar of a UI element.
    public var horizontalScrollBar: AXUIElement? {
        element[.horizontalScrollBar]
    }

    /// The vertical scroll bar of a UI element.
    public var verticalScrollBar: AXUIElement? {
        element[.verticalScrollBar]
    }

    /// The orientation of a UI element, such as horizontal or vertical.
    public var orientation: String? {
        element[.orientation]
    }

    /// The header element of a UI component, like a table or list.
    public var header: AXUIElement? {
        element[.header]
    }
    /// A Boolean value indicating whether a UI element's content has been edited or modified.
    public var isEdited: Bool? {
        element[.isEdited]
    }
    
    /// A Boolean value indicating whether the UI element is editable.
    public var isEditable: Bool? {
        element[.isEditable]
    }
    
    /// The set of tabs in a UI element, such as a tab view or window.
    public var tabs: [AXUIElement] {
        (element[.tabs] as [AXUIElement]?) ?? []
    }

    /// A button that shows additional content when clicked.
    public var overflowButton: AXUIElement? {
        element[.overflowButton]
    }

    /// The name of a file associated with a UI element, such as in a file picker.
    public var filename: String? {
        element[.filename]
    }
    /// A Boolean value indicating whether a collapsible UI element is expanded or not.
    public var isExpanded: Bool? {
        element[.isExpanded]
    }
    /// A Boolean value indicating whether a UI element or item is selected.
    public var isSelected: Bool? {
        element[.isSelected]
    }

    /// The splitter bars used to resize UI elements, such as in a split view.
    public var splitters: [AXUIElement] {
        (element[.splitters] as [AXUIElement]?) ?? []
    }

    /// The contents of a UI element, such as text in a text field or items in a list.
    public var contents: [AXUIElement] {
        (element[.contents] as [AXUIElement]?) ?? []
    }

    /// The next available content in a UI element, such as in a paginated view.
    public var nextContents: AXUIElement? {
        element[.nextContents]
    }

    /// The previous available content in a UI element, such as in a paginated view.
    public var previousContents: AXUIElement? {
        element[.previousContents]
    }

    /// The document or file associated with a UI element.
    public var document: String? {
        element[.document]
    }

    /// The UI element that allows incrementing a value, such as a stepper.
    public var incrementor: AXUIElement? {
        element[.incrementor]
    }
    
    /// A button that decreases a value, such as in a stepper control.
    public var decrementButton: AXUIElement? {
        element[.decrementButton]
    }

    /// A button that increases a value, such as in a stepper control.
    public var incrementButton: AXUIElement? {
        element[.incrementButton]
    }

    /// The title of a column in a table or list view.
    public var columnTitle: String? {
        element[.columnTitle]
    }

    /// The URL associated with a UI element, such as a link in a browser.
    public var url: URL? {
        element[.url]
    }

    /// The UI elements used for labeling content or sections.
    public var labelUIElements: [AXUIElement] {
        (element[.labelUIElements] as [AXUIElement]?) ?? []
    }

    /// The value associated with a label in a UI element.
    public var labelValue: String? {
        element[.labelValue]
    }

    /// The currently visible menu or context menu in a UI.
    public var shownMenuUIElement: AXUIElement? {
        element[.shownMenuUIElement]
    }
    /// A Boolean value indicating whether an application is currently running.
    public var isApplicationRunning: Bool? {
        element[.isApplicationRunning]
    }

    /// The currently focused application in the system.
    public var focusedApplication: AXUIElement? {
        element[.focusedApplication]
    }
    /// A Boolean value indicating whether a UI element is busy performing a task.
    public var isBusy: Bool? {
        element[.isBusy]
    }
    
    /// A Boolean value indicating whether an alternate user interface is currently visible.
    public var isAlternateUIVisible: Bool? {
        element[.isAlternateUIVisible]
    }
    
    // MARK: - Undocumented attributes
    /// A Boolean value indicating whether the user interface is enhanced for additional metadata for VoiceOver.
    public var isEnhancedUserInterface: Bool? {
        element[.isEnhancedUserInterface]
    }
    
    /// A Boolean value indicating whether the user interface is enabled for accessibility with Electron apps.
    public var manualAccessibility: Bool? {
        element[.manualAccessibility]
    }
    
    // MARK: - Text suite parameterized attributes

    /// The line corresponding to a specific index in the text.
    public func line(forIndex index: Int) -> Int? {
        try? element.get(.lineForIndex, with: index)
    }

    /// The range of characters that form a specific line in the text.
    public func range(forLine line: Int) -> NSRange? {
        (try? element.get(.rangeForLine, with: line) as CFRange?)?.nsRange
    }

    /// The string corresponding to a specific character range.
    public func string(forRange range: NSRange) -> String? {
        try? element.get(.stringForRange, with: range.cfRange)
    }
    
    /// The character range corresponding to a specific position in the text.
    public func range(forPosition position: CGPoint) -> NSRange? {
        try? element.get(.rangeForPosition, with: position)
    }

    /// The character range corresponding to a specific index in the text.
    public func range(forIndex index: Int) -> NSRange? {
        (try? element.get(.rangeForIndex, with: index) as CFRange?)?.nsRange
    }

    /// The bounds (position and size) of a specific character range.
    public func bounds(forRange range: NSRange) -> CGRect? {
        try? element.get(.boundsForRange, with: range.cfRange)
    }

    /// The RTF content corresponding to a character range.
    public func rtf(forRange range: NSRange) -> Data? {
        try? element.get(.rtfForRange, with: range.cfRange)
    }

    /// The attributed string corresponding to a specific character range.
    public func attributedString(forRange range: NSRange) -> NSAttributedString? {
        try? element.get(.attributedStringForRange, with: range.cfRange)
    }

    /// The style range for a specific index in the text.
    public func styleRange(forIndex index: Int) -> NSRange? {
        (try? element.get(.styleRangeForIndex, with: index) as CFRange?)?.nsRange
    }
    
    // MARK: - Cell-based table parameterized attributes

    /// A specific cell based on its column and row indices.
    public func cell(forColumn column: Int, row: Int) -> AXUIElement? {
        try? element.get(.cellForColumnAndRow, with: [column, row])
    }
    
    // MARK: - Layout area parameterized attributes

    /// The layout point corresponding to a specific screen point.
    public func layoutPoint(forScreenPoint screenPoint: CGPoint) -> CGPoint? {
        try? element.get(.layoutPointForScreenPoint, with: screenPoint)
    }

    /// The layout size corresponding to a specific screen size.
    public func layoutSize(forScreenSize screenSize: CGSize) -> CGSize? {
        try? element.get(.layoutSizeForScreenSize, with: screenSize)
    }

    /// The screen point corresponding to a specific layout point.
    public func screenPoint(forLayoutPoint layoutPoint: CGPoint) -> CGPoint? {
        try? element.get(.screenPointForLayoutPoint, with: layoutPoint)
    }

    /// The screen size corresponding to a specific layout size.
    public func screenSize(forLayoutPoint layoutSize: CGSize) -> CGSize? {
        try? element.get(.screenSizeForLayoutSize, with: layoutSize)
    }
    
    // MARK: - Level indicator attributes

    /// The warning value of a level indicator.
    public var warningValue: Double? {
        (element[.warningValue] as NSNumber?)?.doubleValue
    }

    /// The critical value of a level indicator.
    public var criticalValue: Double? {
        (element[.criticalValue] as NSNumber?)?.doubleValue
    }
    
    // MARK: - Search field attributes

    /// The search button of a search field.
    public var searchButton: AXUIElement? {
        element[.searchButton]
    }

    /// The clear button of a search field.
    public var clearButton: AXUIElement? {
        element[.clearButton]
    }

    init(_ element: AXUIElement) {
        self.element = element
    }
}
#endif
