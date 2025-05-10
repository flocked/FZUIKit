//
//  NSTableView+EmptyView.swift
//
//
//  Created by Florian Zand on 03.04.24.
//


#if os(macOS)

import AppKit
import FZSwiftUtils

extension NSTableView {
    /// A view that is displayed whenever the table view is empty.
    public var emptyContentView: NSView {
        swizzleNumberOfRowsIfNeeded()
        updateEmptyView()
        return _emptyContentView
    }
    
    /// A content configuration that is displayed whenever the table view is empty.
    public var emptyContentConfiguration: NSContentConfiguration? {
        get { _emptyContentView.contentConfiguration }
        set {
            swizzleNumberOfRowsIfNeeded()
            updateEmptyView()
            _emptyContentView.contentConfiguration = newValue
        }
    }
    
    /// A handler that is called whenever the table view is empty.
    public var emptyContentHandler: ((_ isEmpty: Bool)->())? {
        get { getAssociatedValue("emptyContentHandler") }
        set { 
            setAssociatedValue(newValue, key: "emptyContentHandler")
            if newValue != nil {
                swizzleNumberOfRowsIfNeeded()
            }
        }
    }
    
    var _emptyContentView: ContentConfigurationView {
        getAssociatedValue("_emptyContentView", initialValue: ContentConfigurationView())
    }
    
    func swizzleNumberOfRowsIfNeeded() {
        if let view = (self as? NSOutlineView) {
            guard !view.didSwizzleNumberOfRowsOutline else { return }
            isEmpty = numberOfRows <= 0
            view.swizzleNumberOfRowsOutline()
        } else if !didSwizzleNumberOfRows {
            isEmpty = numberOfRows <= 0
            swizzleNumberOfRows()
        }
    }
    
    func updateEmptyView() {
        if isEmpty == false {
            _emptyContentView.removeFromSuperview()
        } else if _emptyContentView.superview == nil {
            addSubview(withConstraint: _emptyContentView)
        }
    }
    
    var isEmpty: Bool {
        get { getAssociatedValue("isEmpty", initialValue: numberOfRows == 0) }
        set {
            guard newValue != isEmpty else { return }
            setAssociatedValue(newValue, key: "isEmpty")
            updateEmptyView()
            emptyContentHandler?(newValue)
        }
    }
        
    var didSwizzleNumberOfRows: Bool {
        isMethodHooked(#selector(getter: NSTableView.numberOfRows))
    }
    
    func swizzleNumberOfRows() {
        guard !isMethodHooked(#selector(getter: NSTableView.numberOfRows)) else { return }
        do {
            try hook(#selector(getter: NSTableView.numberOfRows), closure: { original, object, sel in
                let numberOfRows = original(object, sel)
                (object as? NSTableView)?.isEmpty = numberOfRows <= 0
                return numberOfRows
            } as @convention(block) (
                (AnyObject, Selector) -> Int,
                AnyObject, Selector) -> Int)
        } catch {
           debugPrint(error)
        }
    }
}

extension NSOutlineView {
    var didSwizzleNumberOfRowsOutline: Bool {
        isMethodHooked(#selector(getter: NSTableView.numberOfRows))
    }
    
    func swizzleNumberOfRowsOutline() {
        guard !isMethodHooked(#selector(getter: NSTableView.numberOfRows)) else { return }
        do {
            try hook(#selector(getter: NSTableView.numberOfRows), closure: { original, object, sel in
                let numberOfRows = original(object, sel)
                (object as? NSOutlineView)?.isEmpty = numberOfRows <= 0
                return numberOfRows
            } as @convention(block) (
                (AnyObject, Selector) -> Int,
                AnyObject, Selector) -> Int)
        } catch {
           debugPrint(error)
        }
    }
}

#endif
