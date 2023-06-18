//
//  File.swift
//
//
//  Created by Florian Zand on 15.09.22.
//

#if os(macOS)

import AppKit
import FZSwiftUtils

public extension NSToolbarItem {
    /**
     Creates a toolbar item with the specified identifier.

     - Parameters itemIdentifier: The identifier for the toolbar item. You use this value to identify the item within your app, so you don’t need to localize it. For example, your toolbar delegate uses this value to identify the specific toolbar item.
     - Returns: A new toolbar item.
     */
    @objc convenience init(_ itemIdentifier: NSToolbarItem.Identifier) {
        self.init(itemIdentifier: itemIdentifier)
    }
    
    /**
     A Boolean value that marks the item as a default item for toolbar with a managed delegate. The default value is true.
     
     - Note: This property is only used for toolbar with managed delegate. Use NSToolbar's init(_: items:) or ManagedToolbarDelegate.
     */
    var isDefaultItem: Bool {
        get { getAssociatedValue(key: "_toolbarItemIsDefault", object: self, initialValue: true) }
        set { set(associatedValue: newValue, key: "_toolbarItemIsDefault", object: self)
        }
    }

    /**
     A Boolean value that marks the item as immovable for toolbar with a managed delegate. The default value is false.
     
     If true it can't be removed from the toolbar.
     
     - Note: This property is only used for toolbar with managed delegate. Use NSToolbar's init(_: items:) or ManagedToolbarDelegate.
     */
    var isImmovableItem: Bool {
        get { getAssociatedValue(key: "_toolbarItemIsImmovable", object: self, initialValue: false) }
        set { set(associatedValue: newValue, key: "_toolbarItemIsImmovable", object: self)
        }
    }

    /**
     A Boolean value that marks the item as selectable for toolbar with a managed delegate. The default value is false.
     
     - Note: This property is only used for toolbar with managed delegate. Use NSToolbar's init(_: items:) or ManagedToolbarDelegate.
     */
    var isSelectable: Bool {
        get { getAssociatedValue(key: "_toolbarItemIsSelectable", object: self, initialValue: false) }
        set { set(associatedValue: newValue, key: "_toolbarItemIsSelectable", object: self)
        }
    }
}

extension NSToolbarItem.Identifier: ExpressibleByStringLiteral {
    public typealias StringLiteralType = String
    public init(stringLiteral value: String) {
        self.init(value)
    }
}

#endif
