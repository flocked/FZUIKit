//
//  ToolbarItem+SharingServicePicker.swift
//
//
//  Created by Florian Zand on 09.04.23.
//

#if os(macOS)
    import AppKit
    import SwiftUI

    extension ToolbarItem {
        /**
         A toolbar item that displays the macOS share sheet.
         
         When someone clicks the item, it displays the macOS share sheet. Use this item to share the selected or focal content from the current window. For example, you might share the photo someone is viewing, the currently selected text, or the window’s associated document.
         
         Provide the items to share using either provide them using ``handlers-swift.property`` or the ``delegate``.
         */
        open class SharingServicePicker: ToolbarItem {
            lazy var servicePickerItem = ValidateServicePickerToolbarItem(for: self)
            override var item: NSToolbarItem {
                servicePickerItem
            }

            var itemsHandler: (() -> ([Any]))?
            var _delegate: Delegate!

            /// The handlers for the sharing service picker item.
            public struct Handlers {
                /// The handler that provides the items to share.
                public var items: (() -> ([Any]))?

                /// Returns the selected sharing service for the current item, or `nil` if none is selected.
                public var didChoose: ((_ service: NSSharingService?) -> Void)?

                /// Asks to provide an object that the selected sharing service can use as its delegate.
                public var delegate: ((_ service: NSSharingService) -> (NSSharingServiceDelegate?))?

                /// Asks to specify which services to make available from the sharing service picker.
                public var sharingServices: ((_ items: [Any], _ proposedServices: [NSSharingService]) -> ([NSSharingService]))?
            }

            /// The handlers for the sharing service picker item.
            open var handlers: Handlers = .init()

            /// Sets the handler that provides the items to share.
            @discardableResult
            open func itemsProvider(_ items: (() -> ([Any]))?) -> Self {
                handlers.items = items
                return self
            }

            /// Returns the selected sharing service for the current item, or `nil` if none is selected.
            @discardableResult
            open func didChoose(_ didChoose: ((_ service: NSSharingService?) -> Void)?) -> Self {
                handlers.didChoose = didChoose
                return self
            }
            
            /**
             The delegate that provides the items to share.
             
             Either provide a delegate or use the item's ``handlers-swift.property`` to provide items.
             */
            open var delegate: NSSharingServicePickerToolbarItemDelegate? {
                get { _delegate?.delegate }
                set { _delegate?.delegate = newValue }
            }
            
            /**
             Sets the delegate that provides the items to share.
             
             Either provide a delegate or use the item's ``handlers-swift.property`` to provide items.
             */
            @discardableResult
            open func delegate(_ delegate: NSSharingServicePickerToolbarItemDelegate?) -> Self {
                _delegate?.delegate = delegate
                return self
            }

            /**
             Creates a toolbar item that displays the macOS share sheet.
             
             - Note: The identifier is used for autosaving the item. When you don't specifiy an identifier an automatic identifier is used. It is recommended to specifiy an identifier, if you have multiple `SharingServicePicker` toolbar items.
             
             - Parameters;
                - identifier: The item identifier.
                - itemsProvider: The handler that provides the items to share.
            */
            public init(_ identifier: NSToolbarItem.Identifier? = nil, itemsProvider: (() -> ([Any]))? = nil) {
                super.init(identifier)
                _delegate = Delegate(for: self)
                handlers.items = itemsProvider
            }
            
            /**
             Creates a toolbar item that displays the macOS share sheet.
             
             - Note: The identifier is used for autosaving the item. When you don't specifiy an identifier an automatic identifier is used. It is recommended to specifiy an identifier, if you have multiple `SharingServicePicker` toolbar items.
             
             - Parameters;
                - identifier: The item identifier.
                - delegate: The delegate that provides the items to share.
            */
            public init(_ identifier: NSToolbarItem.Identifier? = nil, delegate: NSSharingServicePickerToolbarItemDelegate) {
                super.init(identifier)
                _delegate = Delegate(for: self)
                _delegate.delegate = delegate
            }
        }
    }

    extension ToolbarItem.SharingServicePicker {
        class Delegate: NSObject, NSSharingServicePickerToolbarItemDelegate {
            weak var pickerItem: ToolbarItem.SharingServicePicker!
            weak var delegate: NSSharingServicePickerToolbarItemDelegate?

            public func items(for item: NSSharingServicePickerToolbarItem) -> [Any] {
                pickerItem.handlers.items?() ?? delegate?.items(for: item) ?? []
            }

            public func sharingServicePicker(_ sharingServicePicker: NSSharingServicePicker, didChoose service: NSSharingService?) {
                pickerItem.handlers.didChoose?(service)
                delegate?.sharingServicePicker?(sharingServicePicker, didChoose: service)
            }

            public func sharingServicePicker(_ sharingServicePicker: NSSharingServicePicker, delegateFor sharingService: NSSharingService) -> NSSharingServiceDelegate? {
                pickerItem.handlers.delegate?(sharingService) ?? delegate?.sharingServicePicker?(sharingServicePicker, delegateFor: sharingService) ?? nil
            }

            public func sharingServicePicker(_ sharingServicePicker: NSSharingServicePicker, sharingServicesForItems items: [Any], proposedSharingServices proposedServices: [NSSharingService]) -> [NSSharingService] {
                pickerItem.handlers.sharingServices?(items, proposedServices) ?? delegate?.sharingServicePicker?(sharingServicePicker, sharingServicesForItems: items, proposedSharingServices: proposedServices) ?? []
            }

            init(for item: ToolbarItem.SharingServicePicker) {
                pickerItem = item
                super.init()
                pickerItem.servicePickerItem.delegate = self
            }
        }
    }

class ValidateServicePickerToolbarItem: NSSharingServicePickerToolbarItem {
    weak var item: ToolbarItem?
    
    init(for item: ToolbarItem) {
        super.init(itemIdentifier: item.identifier)
        self.item = item
    }
    
    override func validate() {
        super.validate()
        item?.validate()
    }
}

#endif
