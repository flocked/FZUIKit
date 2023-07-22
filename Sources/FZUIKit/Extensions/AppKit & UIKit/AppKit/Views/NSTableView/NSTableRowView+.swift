//
//  NSTableRowView+.swift
//
//
//  Created by Florian Zand on 26.01.23.
//

#if os(macOS)
import AppKit
import FZSwiftUtils

extension NSTableRowView {
    /**
     The array of cell views embedded in the current row.

     This array contains zero or more NSTableCellView objects that represent the cell views embedded in the current row view’s content.
     */
    public var cellViews: [NSTableCellView] {
        (0 ..< numberOfColumns).compactMap { self.view(atColumn: $0) as? NSTableCellView }
        //    self.subviews.compactMap({$0 as? NSTableCellView})
    }

    /**
     The  cell views for the column.
     */
    public func cellView(for column: NSTableColumn) -> NSTableCellView? {
        if let index = tableView?.tableColumns.firstIndex(of: column), index < cellViews.count {
            return (view(atColumn: index) as? NSTableCellView)
        }
        return nil
    }

    /**
     The table view that displays the current row view.

     The table view that displays the current row view. The value of this property is nil when the row view is not displayed in a table view.
     */
    public var tableView: NSTableView? {
        firstSuperview(for: NSTableView.self)
    }

    public var selectionColor: NSColor? {
        get { getAssociatedValue(key: "_selectionColor", object: self, initialValue: nil) }
        set {
            set(associatedValue: newValue, key: "_selectionColor", object: self)
            if newValue != nil {
                Self.swizzleDrawSelection()
            }
        }
    }

    public var separatorInsets: NSEdgeInsets? {
        get { getAssociatedValue(key: "_separatorInsets", object: self, initialValue: nil) }
        set {
            set(associatedValue: newValue, key: "_separatorInsets", object: self)
            if newValue != nil {
                Self.swizzleDrawSeparator()
            }
        }
    }

    public var separatorColor: NSColor {
        get { getAssociatedValue(key: "_separatorInsets", object: self, initialValue: .separatorColor) }
        set {
            set(associatedValue: newValue, key: "_separatorInsets", object: self)
            Self.swizzleDrawSeparator()
        }
    }

    internal static var didSwizzleDrawSelection: Bool {
        get { getAssociatedValue(key: "_didSwizzleDrawSelection", object: self, initialValue: false) }
        set {
            set(associatedValue: newValue, key: "_didSwizzleDrawSelection", object: self)
        }
    }

    @objc internal func swizzled_drawSelection(in dirtyRect: NSRect) {
        if selectionHighlightStyle != .none {
            if let selectionColor = selectionColor {
                let selectionRect = dirtyRect.insetBy(dx: 2.5, dy: 2.5)
                selectionColor.setFill()
                let selectionPath = NSBezierPath(roundedRect: selectionRect, cornerRadius: 4.0)
                selectionPath.fill()
            } else {
                swizzled_drawSelection(in: dirtyRect)
            }
        }
    }

    @objc internal static func swizzleDrawSelection() {
        if didSwizzleDrawSelection == false {
            didSwizzleDrawSelection = true
            _ = try? Swizzle(NSTableRowView.self) {
                #selector(drawSelection) <-> #selector(swizzled_drawSelection)
            }
        }
    }

    internal static var didSwizzleDrawSeparator: Bool {
        get { getAssociatedValue(key: "NSTableRowView_didSwizzleDrawSeparator", object: self, initialValue: false) }
        set {
            set(associatedValue: newValue, key: "NSTableRowView_didSwizzleDrawSeparator", object: self)
        }
    }

    @objc internal func swizzled_drawSeparator(in dirtyRect: NSRect) {
        if separatorInsets != nil {
            let separatorRect = calculateSeparatorRect()
            swizzled_drawSeparator(in: separatorRect)
        } else {
            swizzled_drawSelection(in: dirtyRect)
        }
    }

    @objc internal func calculateSeparatorRect() -> CGRect {
        guard let separatorInsets = separatorInsets else {
            return .zero
        }

        guard numberOfColumns > 0 else { return .zero }
        let viewRect = (view(atColumn: 0)! as! NSView).frame

        let separatorRect = NSRect(
            x: viewRect.origin.x,
            y: max(0, viewRect.height - 1),
            width: viewRect.width,
            height: 1
        )

        return CGRect(
            x: separatorRect.origin.x + separatorInsets.left,
            y: separatorRect.origin.y + separatorInsets.top,
            width: separatorRect.width - separatorInsets.left - separatorInsets.right,
            height: separatorRect.height - separatorInsets.top - separatorInsets.bottom
        )
    }

    @objc internal static func swizzleDrawSeparator() {
        if didSwizzleDrawSeparator == false {
            didSwizzleDrawSeparator = true
            do {
                try Swizzle(NSTableRowView.self) {
                    #selector(drawSeparator) <-> #selector(swizzled_drawSelection)
                }
            } catch {
                Swift.print(error)
            }
        }
    }
}
#endif
