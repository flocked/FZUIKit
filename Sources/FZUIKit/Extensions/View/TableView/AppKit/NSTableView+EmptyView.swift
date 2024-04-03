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
        get { _emptyContentView.configuration }
        set {
            swizzleNumberOfRowsIfNeeded()
            updateEmptyView()
            _emptyContentView.configuration = newValue
        }
    }
    
    /// A handler that is called whenever the table view is empty.
    public var emptyContentHandler: ((Bool)->())? {
        get { getAssociatedValue("emptyContentHandler", initialValue: nil) }
        set { setAssociatedValue(newValue, key: "emptyContentHandler") }
    }
    
    var _emptyContentView: ContentConfigurationView {
        getAssociatedValue("_emptyContentView", initialValue: ContentConfigurationView())
    }
    
    func swizzleNumberOfRowsIfNeeded() {
        if let view = (self as? NSOutlineView) {
            guard !view.didSwizzleNumberOfRowsOutline else { return }
            _numberOfRows = numberOfRows
            view.swizzleNumberOfRowsOutline()
        } else if !didSwizzleNumberOfRows {
            _numberOfRows = numberOfRows
            swizzleNumberOfRows()
        }
    }
    
    func updateEmptyView() {
        if _numberOfRows > 0 {
            _emptyContentView.removeFromSuperview()
        } else if _emptyContentView.superview == nil {
            addSubview(withConstraint: _emptyContentView)
        }
    }
    
    var _numberOfRows: Int {
        get { getAssociatedValue("_numberOfRows", initialValue: .max) }
        set {
            guard newValue != _numberOfRows else { return }
            setAssociatedValue(newValue, key: "_numberOfRows")
            updateEmptyView()
        }
    }
        
    var didSwizzleNumberOfRows: Bool {
        isMethodReplaced(#selector(getter: NSTableView.numberOfRows))
    }
    
    func swizzleNumberOfRows() {
        guard !isMethodReplaced(#selector(getter: NSTableView.numberOfRows)) else { return }
        do {
           try replaceMethod(
            #selector(getter: NSTableView.numberOfRows),
           methodSignature: (@convention(c)  (AnyObject, Selector) -> (Int)).self,
           hookSignature: (@convention(block)  (AnyObject) -> (Int)).self) { store in {
               object in
               let numberOfRows = store.original(object, #selector(getter: NSTableView.numberOfRows))
               (object as? NSTableView)?._numberOfRows = numberOfRows
               return numberOfRows
               }
           }
        } catch {
           debugPrint(error)
        }
    }
}

extension NSOutlineView {
    var didSwizzleNumberOfRowsOutline: Bool {
        isMethodReplaced(#selector(getter: NSTableView.numberOfRows))
    }
    
    func swizzleNumberOfRowsOutline() {
        guard !isMethodReplaced(#selector(getter: NSTableView.numberOfRows)) else { return }
        do {
           try replaceMethod(
            #selector(getter: NSTableView.numberOfRows),
           methodSignature: (@convention(c)  (AnyObject, Selector) -> (Int)).self,
           hookSignature: (@convention(block)  (AnyObject) -> (Int)).self) { store in {
               object in
               let numberOfRows = store.original(object, #selector(getter: NSTableView.numberOfRows))
               (object as? NSOutlineView)?._numberOfRows = numberOfRows
               return numberOfRows
               }
           }
        } catch {
           debugPrint(error)
        }
    }
}

#endif
