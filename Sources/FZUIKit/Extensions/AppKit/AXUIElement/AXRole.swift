//
//  AXRole.swift
//  
//
//  Created by Florian Zand on 15.01.25.
//

#if canImport(ApplicationServices)
import ApplicationServices
import Foundation
import AppKit

/// The role of an accessibility object.
public struct AXRole: Hashable, RawRepresentable, ExpressibleByStringLiteral {
    public let rawValue: String

    public init(rawValue: String) {
        self.rawValue = rawValue
    }
    
    public init(stringLiteral value: String) {
        self.rawValue = value
    }

    /// An application element, representing an application running on the system.
    public static let application = AXRole(rawValue: kAXApplicationRole)
    /// A system-wide element that provides access to global system functionality.
    public static let systemWide = AXRole(rawValue: kAXSystemWideRole)
    /// A window element, representing a window in an application.
    public static let window = AXRole(rawValue: kAXWindowRole)
    /// A sheet element, typically a modal dialog attached to a window.
    public static let sheet = AXRole(rawValue: kAXSheetRole)
    /// A drawer element, typically a sliding panel attached to a window.
    public static let drawer = AXRole(rawValue: kAXDrawerRole)
    /// A grow area element, used to resize a window.
    public static let growArea = AXRole(rawValue: kAXGrowAreaRole)
    /// An image element, representing a static graphical element.
    public static let image = AXRole(rawValue: kAXImageRole)
    /// A button element, representing a clickable control.
    public static let button = AXRole(rawValue: kAXButtonRole)
    /// A radio button element, used to select one option from a group.
    public static let radioButton = AXRole(rawValue: kAXRadioButtonRole)
    /// A checkbox element, used to toggle a boolean state.
    public static let checkBox = AXRole(rawValue: kAXCheckBoxRole)
    /// A pop-up button element, used to display a pop-up menu.
    public static let popUpButton = AXRole(rawValue: kAXPopUpButtonRole)
    /// A menu button element, used to display a menu when clicked.
    public static let menuButton = AXRole(rawValue: kAXMenuButtonRole)
    /// A tab group element, used to organize content in a tabbed interface.
    public static let tabGroup = AXRole(rawValue: kAXTabGroupRole)
    /// A table element, representing a grid of data or controls.
    public static let table = AXRole(rawValue: kAXTableRole)
    /// A column element, representing a vertical division in a table.
    public static let column = AXRole(rawValue: kAXColumnRole)
    /// A row element, representing a horizontal division in a table.
    public static let row = AXRole(rawValue: kAXRowRole)
    /// An outline element, representing a hierarchical list of items.
    public static let outline = AXRole(rawValue: kAXOutlineRole)
    /// A browser element, typically used to navigate hierarchical data.
    public static let browser = AXRole(rawValue: kAXBrowserRole)
    /// A scroll area element, representing a region that can scroll to show additional content.
    public static let scrollArea = AXRole(rawValue: kAXScrollAreaRole)
    /// A scroll bar element, used to scroll content within a scrollable region.
    public static let scrollBar = AXRole(rawValue: kAXScrollBarRole)
    /// A radio group element, containing a group of radio buttons.
    public static let radioGroup = AXRole(rawValue: kAXRadioGroupRole)
    /// A list element, representing an ordered collection of items.
    public static let list = AXRole(rawValue: kAXListRole)
    /// A group element, used to organize related elements.
    public static let group = AXRole(rawValue: kAXGroupRole)
    /// A value indicator element, used to display a numerical or graphical value.
    public static let valueIndicator = AXRole(rawValue: kAXValueIndicatorRole)
    /// A combo box element, combining a text field and a drop-down menu.
    public static let comboBox = AXRole(rawValue: kAXComboBoxRole)
    /// A slider element, used to select a value from a range.
    public static let slider = AXRole(rawValue: kAXSliderRole)
    /// An incrementor element, used to adjust values in small steps.
    public static let incrementor = AXRole(rawValue: kAXIncrementorRole)
    /// A busy indicator element, typically a spinner or other animation indicating activity.
    public static let busyIndicator = AXRole(rawValue: kAXBusyIndicatorRole)
    /// A progress indicator element, used to show the completion of an ongoing task.
    public static let progressIndicator = AXRole(rawValue: kAXProgressIndicatorRole)
    /// A relevance indicator element, used to indicate the relevance of content.
    public static let relevanceIndicator = AXRole(rawValue: kAXRelevanceIndicatorRole)
    /// A toolbar element, containing controls for performing actions or changing views.
    public static let toolbar = AXRole(rawValue: kAXToolbarRole)
    /// A disclosure triangle element, used to show or hide a group of related elements.
    public static let disclosureTriangle = AXRole(rawValue: kAXDisclosureTriangleRole)
    /// A text field element, used to enter or display a single line of text.
    public static let textField = AXRole(rawValue: kAXTextFieldRole)
    /// A text area element, used to enter or display multiple lines of text.
    public static let textArea = AXRole(rawValue: kAXTextAreaRole)
    /// A static text element, used to display read-only text.
    public static let staticText = AXRole(rawValue: kAXStaticTextRole)
    /// A heading element, used to represent a heading or title within content.
    public static let heading = AXRole(rawValue: kAXHeadingRole)
    /// A menu bar element, representing the main menu bar of an application.
    public static let menuBar = AXRole(rawValue: kAXMenuBarRole)
    /// A menu bar item element, representing an item in the menu bar.
    public static let menuBarItem = AXRole(rawValue: kAXMenuBarItemRole)
    /// A menu element, representing a list of commands or options.
    public static let menu = AXRole(rawValue: kAXMenuRole)
    /// A menu item element, representing a single command or option within a menu.
    public static let menuItem = AXRole(rawValue: kAXMenuItemRole)
    /// A split group element, used to organize content into multiple resizable sections.
    public static let splitGroup = AXRole(rawValue: kAXSplitGroupRole)
    /// A splitter element, used to resize sections in a split group.
    public static let splitter = AXRole(rawValue: kAXSplitterRole)
    /// A color well element, used to select or display a color.
    public static let colorWell = AXRole(rawValue: kAXColorWellRole)
    /// A time field element, used to input or display time values.
    public static let timeField = AXRole(rawValue: kAXTimeFieldRole)
    /// A date field element, used to input or display date values.
    public static let dateField = AXRole(rawValue: kAXDateFieldRole)
    /// A help tag element, used to display contextual help or tooltips.
    public static let helpTag = AXRole(rawValue: kAXHelpTagRole)
    /// A matte element, used as a visual background or overlay.
    public static let matte = AXRole(rawValue: kAXMatteRole)
    /// A dock item element, representing an item in the Dock.
    public static let dockItem = AXRole(rawValue: kAXDockItemRole)
    /// A ruler element, used to measure or align content.
    public static let ruler = AXRole(rawValue: kAXRulerRole)
    /// A ruler marker element, used to indicate a specific point or alignment on a ruler.
    public static let rulerMarker = AXRole(rawValue: kAXRulerMarkerRole)
    /// A grid element, used to display content in a structured, grid-like layout.
    public static let grid = AXRole(rawValue: kAXGridRole)
    /// A level indicator element, used to display a value within a predefined range.
    public static let levelIndicator = AXRole(rawValue: kAXLevelIndicatorRole)
    /// A cell element, representing a single unit within a table, grid, or similar structure.
    public static let cell = AXRole(rawValue: kAXCellRole)
    /// A layout area element, used to organize and arrange content in a defined space.
    public static let layoutArea = AXRole(rawValue: kAXLayoutAreaRole)
    /// A layout item element, representing an individual item within a layout area.
    public static let layoutItem = AXRole(rawValue: kAXLayoutItemRole)
    /// A handle element, used to adjust or manipulate an object, such as resizing a window or moving an object.
    public static let handle = AXRole(rawValue: kAXHandleRole)
    /// A popover element, used to display additional information or controls in a floating view.
    public static let popover = AXRole(rawValue: kAXPopoverRole)
    /// An unknown element, for roles that cannot be identified.
    public static let unknown = AXRole(rawValue: kAXUnknownRole)
    
    public func description(with subrole: AXSubrole?) -> String? {
        if let subrole = subrole {
            return NSAccessibility.Role(rawValue: rawValue).description(with: .init(rawValue: subrole.rawValue))
        }
        return NSAccessibility.Role(rawValue: rawValue).description(with: nil)
    }
}

extension AXRole: CustomStringConvertible {
    public var description: String {
        rawValue
    }
}
#endif
