//
//  NSTableView+SelectionStyle.swift
//
//
//  Created by Florian Zand on 22.02.26.
//

#if os(macOS)

import FZSwiftUtils
import AppKit

extension NSTableView.SelectionHighlightStyle {
    /// Tints the text and symbol / template image of selected cells with a light gray background.
    public static var tinted: Self {
        NSTableRowView.hookSelectionHighlightStyle()
        NSTableView.hookSelectionHighlightStyle()
        return Self.init(rawValue: 111122)!
    }
}

extension NSTableView {
    /**
     The background color of a selected row.
     
     The default value is `nil` and depends on the [style](https://developer.apple.com/documentation/appkit/nstableview/style-swift.property) of the table view.
     */
    public var selectionColor: NSColor? {
        get { getAssociatedValue("selectionColor") }
        set {
            guard newValue != selectionColor else { return }
            setAssociatedValue(newValue, key: "selectionColor")
            enumerateAvailableRowViews { rowView, _ in rowView.selectionColor = newValue }
            hookDidAddRow()
        }
    }
    
    public var selectionBackgroundStyle: NSView.BackgroundStyle? {
        get { getAssociatedValue("selectionBackgroundStyle") }
        set {
            guard newValue != selectionBackgroundStyle else { return }
            setAssociatedValue(newValue, key: "selectionBackgroundStyle")
        }
    }
    
    private func hookDidAddRow() {
        if selectionColor != nil || drawTinted {
            guard didAddRowHook == nil else { return }
            do {
                didAddRowHook =  try hook(#selector(NSTableView.didAdd(_:forRow:)), closure: {
                    original, tableView, selector, rowView, row in
                    rowView.selectionColor = tableView.selectionColor
                    rowView.drawTinted = tableView.drawTinted
                    original(tableView, selector, rowView, row)
                } as @convention(block) (
                    (NSTableView, Selector, NSTableRowView, Int) -> (),
                    NSTableView, Selector, NSTableRowView, Int) -> ())
            } catch {
                Swift.print(error)
            }
        } else {
            try? didAddRowHook?.revert()
            didAddRowHook = nil
        }
    }
    
    private var didAddRowHook: Hook? {
        get { getAssociatedValue("didAddRowHook") }
        set { setAssociatedValue(newValue, key: "didAddRowHook") }
    }
    
    private static func hookSelectionHighlightStyle() {
        guard setSelectionHighlightStyleHook == nil else { return }
        do {
            setSelectionHighlightStyleHook = try hook(setAll: \.selectionHighlightStyle) { tableView, newStyle in
                let drawTinted = newStyle == .tinted
                tableView.drawTinted = drawTinted
                tableView.enumerateAvailableRowViews { rowView, _ in rowView.drawTinted = drawTinted }
                return drawTinted ? .regular : newStyle
            }
        } catch {
            Swift.print(error)
        }
    }
    
    private var drawTinted: Bool {
        get { getSelectionHighlightStyleHook != nil }
        set {
            guard newValue != drawTinted else { return }
            hookDidAddRow()
            if newValue {
                do {
                    getSelectionHighlightStyleHook = try hook(\.selectionHighlightStyle) { _,_ in .tinted }
                } catch {
                    Swift.print(error)
                }
            } else {
                try? getSelectionHighlightStyleHook?.revert()
                getSelectionHighlightStyleHook = nil
            }
        }
    }
    
    private var getSelectionHighlightStyleHook: Hook? {
         get { getAssociatedValue("setSelectionHighlightStyleHook") }
         set { setAssociatedValue(newValue, key: "setSelectionHighlightStyleHook") }
     }
    
    private static var setSelectionHighlightStyleHook: Hook? {
         get { getAssociatedValue("setSelectionHighlightStyleHook") }
         set { setAssociatedValue(newValue, key: "setSelectionHighlightStyleHook") }
     }
}

extension NSTableRowView {
    /// The background color of a selected row.
    public var selectionColor: NSColor? {
        get { getAssociatedValue("selectionColor") }
        set {
            guard newValue != selectionColor else { return }
            setAssociatedValue(newValue, key: "selectionColor")
            setupSelectionHooks()
        }
    }
    
    fileprivate var drawTinted: Bool {
        get { getSelectionHighlightStyleHook != nil }
        set {
            guard newValue != drawTinted else { return  }
            if newValue {
                do {
                    getSelectionHighlightStyleHook = try hook(\.selectionHighlightStyle) { _,_ in .tinted }
                } catch {
                    Swift.print(error)
                }
            } else {
                try? getSelectionHighlightStyleHook?.revert()
                getSelectionHighlightStyleHook = nil
            }
        }
    }
    
    fileprivate static func hookSelectionHighlightStyle() {
        guard setSelectionHighlightStyleHook == nil else { return }
        do {
            setSelectionHighlightStyleHook = try hook(setAll: \.selectionHighlightStyle) { rowView, newStyle in
                let drawTinted = newStyle == .tinted
                rowView.drawTinted = drawTinted
                rowView.setupSelectionHooks()
                return drawTinted ? .regular : newStyle
            }
        } catch {
            Swift.print(error)
        }
    }
    
    private func setupSelectionHooks() {
        if drawTinted || selectionColor != nil {
            guard drawSelectionHooks.isEmpty else { return }
            do {
                drawSelectionHooks += try hook(\.interiorBackgroundStyle) { rowView, style in
                    guard  rowView.selectionHighlightStyle != .none, rowView.drawTinted || rowView.selectionColor != nil else { return style }
                    return rowView.getInteriorBackgroundStyle()
                }
                drawSelectionHooks += try hookAfter(set: \.isSelected) { rowView, isSelected in
                    guard rowView.selectionHighlightStyle == .none else { return }
                    rowView.setTintConfiguration(to: isSelected ? rowView.selectionColor : nil )
                }
                drawSelectionHooks += try hook(#selector(NSTableRowView.drawSelection(in:)), closure: {
                    original, rowView, selector, dirtyRect in
                    guard rowView.selectionHighlightStyle != .none, rowView.drawTinted || rowView.selectionColor != nil else {
                        original(rowView, selector, dirtyRect)
                        return
                    }
                    if rowView.isEmphasized {
                        if rowView.drawTinted {
                            NSColor.unemphasizedSelectedContentBackgroundColor.withAlphaComponent(0.4).setFill()
                        } else {
                            (rowView.selectionColor ?? .controlAccentColor).setFill()
                        }
                    } else {
                        NSColor.unemphasizedSelectedContentBackgroundColor.withAlphaComponent(0.4).setFill()
                    }
                    let selectionRect = rowView.bounds.insetBy(dx: Self.selectionInsets.width, dy: Self.selectionInsets.height)
                    let botR = (rowView.isFlipped ? rowView.isPreviousRowSelected : rowView.isNextRowSelected) ? 0 : Self.selectionRadius
                    let topR = (rowView.isFlipped ? rowView.isNextRowSelected : rowView.isPreviousRowSelected) ? 0 : Self.selectionRadius
                    NSBezierPath(roundedRect: selectionRect, topLeftRadius: topR, topRightRadius: topR, bottomLeftRadius: botR, bottomRightRadius: botR).fill()
                  //  rowView.drawSelection()
                 } as @convention(block) ((NSTableRowView, Selector, NSRect) -> (), NSTableRowView, Selector, NSRect) -> ())
                setIvarValue(true, named: "_subclassOverrides_drawSelectionInRect")
            } catch {
                Swift.print(error)
            }
        } else {
            drawSelectionHooks.forEach({ try? $0.revert() })
            drawSelectionHooks = []
            setIvarValue(false, named: "_subclassOverrides_drawSelectionInRect")
        }
    }
    
    private func getInteriorBackgroundStyle() -> NSView.BackgroundStyle {
        if drawTinted {
            setTintConfiguration(to: isSelected ? selectionColor ?? .controlAccentColor : nil)
            return isSelected ? .lowered : .normal
        } else {
            setTintConfiguration(to: !isEmphasized && isSelected ? selectionColor ?? .controlAccentColor : nil)
            guard isSelected && isEmphasized else { return .normal }
            return (superview as? NSTableView)?.selectionBackgroundStyle ?? .emphasized
        }
    }
    
    static let selectionRadius = 8.0
    static let selectionInsets = CGSize(width: 10, height: 0)
    
    private func setTintConfiguration(to color: NSColor?) {
        tintConfiguration = color != nil ? .init(fixedColor: color!) : nil
        subviews.compactMap({ $0 as? NSTableCellView }).forEach({
            $0.textField?.tintConfiguration = color != nil ? .init(fixedColor: color!) : nil
            $0.imageView?.tintConfiguration = color != nil ? .init(fixedColor: color!) : nil
        })
    }
    
    private var drawSelectionHooks: [Hook] {
        get { getAssociatedValue("drawSelectionHooks") ?? [] }
        set { setAssociatedValue(newValue, key: "drawSelectionHooks") }
    }
    
    private var getSelectionHighlightStyleHook: Hook? {
         get { getAssociatedValue("setSelectionHighlightStyleHook") }
         set { setAssociatedValue(newValue, key: "setSelectionHighlightStyleHook") }
     }
    
    private static var setSelectionHighlightStyleHook: Hook? {
        get { getAssociatedValue("setSelectionHighlightStyleHook") }
        set { setAssociatedValue(newValue, key: "setSelectionHighlightStyleHook") }
    }
}

/// A table row view with custom selection style.
class CustomSelectionRowView: NSTableRowView {
    private let selectionRadius = 8.0
    private let selectionInsets = CGSize(width: 10, height: 0)
    
    public var _selectionColor: NSColor?
    public var selectionBackgroundStyle: NSView.BackgroundStyle = .emphasized
    public var tintedSelection: Bool = false
    
    override var selectionHighlightStyle: NSTableView.SelectionHighlightStyle {
        get { tintedSelection ? .tinted : super.selectionHighlightStyle }
        set {
            tintedSelection = newValue == .tinted
            super.selectionHighlightStyle = tintedSelection ? .regular : newValue
        }
    }
    
    override var interiorBackgroundStyle: NSView.BackgroundStyle {
        guard selectionHighlightStyle != .none, tintedSelection || selectionColor != nil else {
            return super.interiorBackgroundStyle
        }
        if tintedSelection {
            setTintConfiguration(to: isSelected ? selectionColor ?? .controlAccentColor : nil)
            return isSelected ? .lowered : .normal
        } else {
            setTintConfiguration(to: !isEmphasized && isSelected ? selectionColor ?? .controlAccentColor : nil)
            guard isSelected && isEmphasized else { return .normal }
            return selectionBackgroundStyle
        }
    }
        
    override var isSelected: Bool {
        didSet {
            guard selectionHighlightStyle == .none else { return }
            setTintConfiguration(to: isSelected ? selectionColor : nil)
        }
    }
    
    private func setTintConfiguration(to color: NSColor?) {
        tintConfiguration = color != nil ? .init(fixedColor: color!) : nil
        subviews.compactMap({ $0 as? NSTableCellView }).forEach({
            $0.textField?.tintConfiguration = color != nil ? .init(fixedColor: color!) : nil
            $0.imageView?.tintConfiguration = color != nil ? .init(fixedColor: color!) : nil
        })
    }
    
    override func drawSelection(in dirtyRect: NSRect) {
        guard selectionHighlightStyle != .none, tintedSelection || selectionColor != nil else {
            super.drawSelection(in: dirtyRect)
            return
        }
        if isEmphasized {
            if tintedSelection {
                NSColor.unemphasizedSelectedContentBackgroundColor.withAlphaComponent(0.4).setFill()
            } else {
                (selectionColor ?? .controlAccentColor).setFill()
            }
        } else {
            NSColor.unemphasizedSelectedContentBackgroundColor.withAlphaComponent(0.4).setFill()
        }
        let selectionRect = bounds.insetBy(dx: selectionInsets.width, dy: selectionInsets.height)
        let botR = (isFlipped ? isPreviousRowSelected : isNextRowSelected) ? 0 : selectionRadius
        let topR = (isFlipped ? isNextRowSelected : isPreviousRowSelected) ? 0 : selectionRadius
        NSBezierPath(roundedRect: selectionRect, topLeftRadius: topR, topRightRadius: topR, bottomLeftRadius: botR, bottomRightRadius: botR).fill()
    }
}


#endif
