//
//  File.swift
//
//
//  Created by Florian Zand on 15.09.22.
//

#if os(macOS)

    import AppKit
    import FZSwiftUtils

    extension NSToolbarItem.Identifier: ExpressibleByStringLiteral {
        public typealias StringLiteralType = String
        public init(stringLiteral value: String) {
            self.init(value)
        }
    }

    public extension NSToolbarItem {
        @objc convenience init(_ itemIdentifier: NSToolbarItem.Identifier) {
            self.init(itemIdentifier: itemIdentifier)
        }

        var isDefaultItem: Bool {
            get { getAssociatedValue(key: "_toolbarItemIsDefault", object: self, initialValue: false) }
            set { set(associatedValue: newValue, key: "_toolbarItemIsDefault", object: self)
            }
        }

        var isImmovableItem: Bool {
            get { getAssociatedValue(key: "_toolbarItemIsImmovable", object: self, initialValue: false) }
            set { set(associatedValue: newValue, key: "_toolbarItemIsImmovable", object: self)
            }
        }

        internal var _isSelectable: Bool {
            get { getAssociatedValue(key: "_toolbarItemIsSelectable", object: self, initialValue: false) }
            set { set(associatedValue: newValue, key: "_toolbarItemIsSelectable", object: self)
            }
        }
    }

#endif
