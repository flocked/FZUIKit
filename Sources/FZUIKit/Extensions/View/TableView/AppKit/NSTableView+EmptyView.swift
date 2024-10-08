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
               (object as? NSTableView)?.isEmpty = numberOfRows <= 0
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
               (object as? NSOutlineView)?.isEmpty = numberOfRows <= 0
               return numberOfRows
               }
           }
        } catch {
           debugPrint(error)
        }
    }
}

#endif
