//
//  AXUIElementValues.swift
//
//
//  Created by Florian Zand on 16.01.25.
//

#if canImport(ApplicationServices) && os(macOS)
import Foundation
import ApplicationServices

class AXUIElementValues {
    let element: AXUIElement
    
    // MARK: - Informational Attributes
    public var role: AXRole? {
        element[.role]
    }
    
    public var subrole: AXSubrole? {
        element[.subrole]
    }
    
    public var roleDescription: String? {
        element[.roleDescription]
    }
    
    public var title: String? {
        element[.title]
    }
    
    public var description: String? {
        element[.description]
    }
    
    public var help: String? {
        element[.help]
    }
    
    public var identifier: String? {
        element[.identifier]
    }

    
    // MARK: - Hierarchy or relationship attributes

    public var parent: AXUIElement? {
        element[.parent]
    }
    
    public var children: [AXUIElement] {
        (element[.children] as [AXUIElement]?) ?? []
    }
    
    public var selectedChildren: [AXUIElement] {
        (element[.selectedChildren] as [AXUIElement]?) ?? []
    }
    
    public var visibleChildren: [AXUIElement] {
        (element[.visibleChildren] as [AXUIElement]?) ?? []
    }
    
    public var window: AXUIElement? {
        element[.window]
    }
    
    public var topLevelUIElement: AXUIElement? {
        element[.topLevelUIElement]
    }
    
    public var titleUIElement: AXUIElement? {
        element[.titleUIElement]
    }
    
    public var serves: [AXUIElement] {
        (element[.serves] as [AXUIElement]?) ?? []
    }
    
    public var linkedUIElements: [AXUIElement] {
        (element[.linkedUIElements] as [AXUIElement]?) ?? []
    }
    
    public var sharedFocusElements: [AXUIElement] {
        (element[.sharedFocusElements] as [AXUIElement]?) ?? []
    }
    
    // MARK: - Visual state attributes
    
    public var isEnabled: Bool? {
        element[.enabled]
    }
    
    public var isFocused: Bool? {
        element[.focused]
    }
    
    public var position: CGPoint? {
        element[.position]
    }
    
    public var size: CGSize? {
        element[.size]
    }
    
    public var frame: CGRect? {
        element[.frame]
    }
    
    // MARK: - Value attributes

    public var value: Any? {
        element[.value]
    }
    
    public var valueDescription: String? {
        element[.valueDescription]
    }
    
    public var minValue: Any? {
        element[.minValue]
    }
    
    public var maxValue: Any? {
        element[.maxValue]
    }
    
    public var valueIncrement: Any? {
        element[.valueIncrement]
    }
    
    public var valueWraps: Bool? {
        element[.valueWraps]
    }
    
    public var allowedValues: [Any]? {
        element[.allowedValues]
    }
    
    public var placeholderValue: Any? {
        element[.placeholderValue]
    }
    
    // MARK: - Window, sheet, or drawer-specific attributes

    public var main: AXUIElement? {
        element[.main]
    }
    
    public var isMinimized: Bool? {
        element[.minimized]
    }
    
    public var closeButton: AXUIElement? {
        element[.closeButton]
    }
    
    public var zoomButton: AXUIElement? {
        element[.zoomButton]
    }
    
    public var fullScreenButton: AXUIElement? {
        element[.fullScreenButton]
    }
    
    public var minimizeButton: AXUIElement? {
        element[.minimizeButton]
    }
    
    public var toolbarButton: AXUIElement? {
        element[.toolbarButton]
    }
    
    public var proxy: AXUIElement? {
        element[.proxy]
    }
    
    /*
    public var growArea: Any? {
        element[.growArea]
    }
     */
    
    public var isModal: Bool? {
        element[.modal]
    }
    
    public var defaultButton: AXUIElement? {
        element[.defaultButton]
    }
    
    public var cancelButton: AXUIElement? {
        element[.cancelButton]
    }
    
    // MARK: - Application element-specific attributes
    
    public var menuBar: AXUIElement? {
        element[.menuBar]
    }
    
    public var windows: [AXUIElement] {
        (element[.windows] as [AXUIElement]?) ?? []
    }
    
    public var frontmost: AXUIElement? {
        element[.frontmost]
    }
    
    public var isHidden: Bool? {
        element[.hidden]
    }
    
    public var mainWindow: AXUIElement? {
        element[.mainWindow]
    }
    
    public var focusedWindow: AXUIElement? {
        element[.focusedWindow]
    }
    
    public var focusedUIElement: AXUIElement? {
        element[.focusedUIElement]
    }
    
    public var extrasMenuBar: AXUIElement? {
        element[.extrasMenuBar]
    }
    
    // MARK: - Date/time-specific attributes

    
    public var hourField: AXUIElement? {
        element[.hourField]
    }
    
    public var minuteField: AXUIElement? {
        element[.minuteField]
    }
    
    public var secondField: AXUIElement? {
        element[.secondField]
    }
    
    public var ampmField: AXUIElement? {
        element[.ampmField]
    }
    
    public var dayField: AXUIElement? {
        element[.dayField]
    }
    
    public var monthField: AXUIElement? {
        element[.monthField]
    }
    
    public var yearField: AXUIElement? {
        element[.yearField]
    }
    
    // MARK: - Table, outline, or browser-specific attributes
    
    public var rows: [AXUIElement] {
        (element[.rows] as [AXUIElement]?) ?? []
    }
    
    public var visibleRows: [AXUIElement] {
        (element[.visibleRows] as [AXUIElement]?) ?? []
    }
    
    public var selectedRows: [AXUIElement] {
        (element[.selectedRows] as [AXUIElement]?) ?? []
    }
    
    public var columns: [AXUIElement] {
        (element[.columns] as [AXUIElement]?) ?? []
    }
    
    public var visibleColumns: [AXUIElement] {
        (element[.visibleColumns] as [AXUIElement]?) ?? []
    }
    
    public var selectedColumns: [AXUIElement] {
        (element[.selectedColumns] as [AXUIElement]?) ?? []
    }
    
    /*
    public var sortDirection: Any? {
        element[.sortDirection]
    }
     */
    
    public var columnHeaderUIElements: [AXUIElement] {
        (element[.columnHeaderUIElements] as [AXUIElement]?) ?? []
    }
    
    public var index: Int? {
        element[.index]
    }
    
    public var isDisclosing: Bool? {
        element[.disclosing]
    }
    
    public var disclosedRows: [AXUIElement] {
        (element[.disclosedRows] as [AXUIElement]?) ?? []
    }
    
    public var disclosedByRow: AXUIElement? {
        element[.disclosedByRow]
    }


    init(_ element: AXUIElement) {
        self.element = element
    }
}
#endif
