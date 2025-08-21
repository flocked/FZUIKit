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
    /**
     A view that is displayed whenever the table view is empty.
     
     Applying this property, will set ``AppKit/NSTableView/emptyContentConfiguration`` to `nil`.
     */
    public var emptyContentView: NSView? {
        get { getAssociatedValue("emptyContentView") }
        set {
            guard newValue != emptyContentView else { return }
            setAssociatedValue(newValue, key: "emptyContentView")
            if let newValue = newValue {
                emptyContentConfiguration = nil
                if emptyView == nil {
                    emptyView = .init(frame: .zero)
                }
                emptyView?.emptyView = newValue
            } else if let emptyView = emptyView, emptyView.contentConfiguration == nil {
                self.emptyView = nil
            }
            swizzleNumberOfRowsIfNeeded()
            updateEmptyView()
        }
    }
    
    /**
     A content configuration that is displayed whenever the table view is empty.
     
     Applying this property, will set ``AppKit/NSTableView/emptyContentView`` to `nil`.
     */
    public var emptyContentConfiguration: NSContentConfiguration? {
        get { getAssociatedValue("emptyContentConfiguration") }
        set {
            setAssociatedValue(newValue, key: "emptyContentConfiguration")
            if let newValue = newValue {
                emptyContentView = nil
                if emptyView == nil {
                    emptyView = .init(frame: .zero)
                }
                emptyView?.contentConfiguration = newValue
            } else if let emptyView = emptyView, emptyView.contentConfiguration != nil {
                self.emptyView = nil
            }
            swizzleNumberOfRowsIfNeeded()
            updateEmptyView()
        }
    }
    
    /// A handler that is called whenever the table view is empty.
    public var emptyContentHandler: ((_ isEmpty: Bool)->())? {
        get { getAssociatedValue("emptyContentHandler") }
        set { 
            setAssociatedValue(newValue, key: "emptyContentHandler")
            guard newValue != nil else { return }
            swizzleNumberOfRowsIfNeeded()
        }
    }
    
    fileprivate var emptyView: EmptyCollectionTableView? {
        get { getAssociatedValue("emptyView") }
        set {
            guard newValue !== emptyView else { return }
            emptyView?.removeFromSuperview()
            setAssociatedValue(newValue, key: "emptyView")
        }
    }
    
    fileprivate func swizzleNumberOfRowsIfNeeded() {
        if emptyContentHandler != nil || emptyContentHandler != nil || emptyContentView != nil {
            guard numberOfRowsHook == nil else { return }
            isEmpty = numberOfRows <= 0
            do {
                numberOfRowsHook = try hook(#selector(getter: NSTableView.numberOfRows), closure: {
                    original, tableView, selector in
                    let numberOfRows = original(tableView, selector)
                    tableView.isEmpty = numberOfRows <= 0
                    return numberOfRows
                } as @convention(block) ( (NSTableView, Selector) -> Int, NSTableView, Selector) -> Int)
            } catch {
               debugPrint(error)
            }
        } else {
            try? numberOfRowsHook?.revert()
            numberOfRowsHook = nil
        }
    }
    
    fileprivate var numberOfRowsHook: Hook? {
        get { getAssociatedValue("numberOfRowsHook") }
        set { setAssociatedValue(newValue, key: "numberOfRowsHook") }
    }
    
    fileprivate func updateEmptyView() {
        guard let emptyView = emptyView else { return }
        if isEmpty == false {
            emptyView.removeFromSuperview()
        } else if emptyView.superview == nil {
            addSubview(withConstraint: emptyView)
        }
    }
    
    fileprivate var isEmpty: Bool {
        get { getAssociatedValue("isEmpty", initialValue: numberOfRows == 0) }
        set {
            guard newValue != isEmpty else { return }
            setAssociatedValue(newValue, key: "isEmpty")
            updateEmptyView()
            emptyContentHandler?(newValue)
        }
    }
}

fileprivate class EmptyCollectionTableView: NSView {
    fileprivate var boundsSize: CGSize = .zero
    
    var emptyView: NSView? {
        didSet {
            guard oldValue != emptyView else { return }
            emptyView?.removeFromSuperview()
            guard let emptyView = emptyView?.size(bounds.size) else { return }
            addSubview(emptyView)
        }
    }
    
    var contentConfiguration: NSContentConfiguration? {
        didSet {
            if let configuration = contentConfiguration {
                if let contentView = contentView, contentView.supports(configuration) {
                    contentView.configuration = configuration
                } else {
                    emptyView = configuration.makeContentView()
                }
            } else {
                emptyView = nil
            }
        }
    }
    
    fileprivate var contentView: (NSView & NSContentView)? {
        emptyView as? NSView & NSContentView
    }
    
    override func layout() {
        super.layout()
        guard bounds.size != boundsSize else { return }
        boundsSize = bounds.size
        emptyView?.frame.size = boundsSize
    }
}

#endif
