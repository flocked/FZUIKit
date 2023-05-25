//
//  File.swift
//
//
//  Created by Florian Zand on 09.04.23.
//

#if os(macOS)
    import Cocoa
    import SwiftUI

    public extension ToolbarItem {
        class SharingServicePicker: ToolbarItem {
            internal lazy var servicePickerItem = NSSharingServicePickerToolbarItem(identifier)
            override internal var item: NSToolbarItem {
                return servicePickerItem
            }

            internal var itemsHandler: (() -> ([Any]))? = nil
            internal var delegateObject: DelegateObject!

            public func items(_ items: @escaping (() -> ([Any]))) {
                itemsHandler = items
            }

            override public init(
                _ identifier: NSToolbarItem.Identifier)
            {
                super.init(identifier)
                delegateObject = DelegateObject(self)
            }
        }
    }

    internal extension ToolbarItem.SharingServicePicker {
        class DelegateObject: NSObject, NSSharingServicePickerToolbarItemDelegate {
            weak var pickerItem: ToolbarItem.SharingServicePicker!

            public func items(for _: NSSharingServicePickerToolbarItem) -> [Any] {
                return pickerItem.itemsHandler?() ?? []
            }

            init(_ item: ToolbarItem.SharingServicePicker) {
                pickerItem = item
                super.init()
                pickerItem.servicePickerItem.delegate = self
            }
        }
    }

#endif
