//
//  ToolbarItem+SharingServicePicker.swift
//
//
//  Created by Florian Zand on 09.04.23.
//

#if os(macOS)
import AppKit
import SwiftUI

public extension ToolbarItem {
    /**
     A toolbar item that displays the macOS share sheet.
     
     It can be used as an item of a ``Toolbar``.
     */
    class SharingServicePicker: ToolbarItem {
        internal lazy var servicePickerItem = NSSharingServicePickerToolbarItem(identifier)
        override internal var item: NSToolbarItem {
            return servicePickerItem
        }

        internal var itemsHandler: (() -> ([Any]))? = nil
        internal var delegateObject: DelegateObject!
        
        /// The handlers for the sharing service picker of a ``ToolbarItem/SharingServicePicker`` toolbar item.
        public struct Handlers {
            /// Asks the items to share.
            public var items: (() -> ([Any]))? = nil
            
            /// Returns the selected sharing service for the current item, or `nil` if none is selected.
            public var didChoose: ((_ service: NSSharingService?) -> ())? = nil
            
            /// Asks to provide an object that the selected sharing service can use as its delegate.
            public var delegate: ((_ service: NSSharingService) -> (NSSharingServiceDelegate?))? = nil
            
            /// Asks to specify which services to make available from the sharing service picker.
            public var sharingServices: ((_ items: [Any], _ proposedServices: [NSSharingService]) -> ([NSSharingService]))? = nil
        }
        
        /// The handlers for the sharing service picker.
        public var handlers: Handlers = Handlers()

        @discardableResult
        /// Asks the items to share.
        public func items(_ items: (() -> ([Any]))?) -> Self {
            handlers.items = items
            return self
        }
        
        @discardableResult
        /// Returns the selected sharing service for the current item, or `nil` if none is selected.
        public func didChoose(_ didChoose: ((_ service: NSSharingService?) -> ())?) -> Self {
            handlers.didChoose = didChoose
            return self
        }
        
        @discardableResult
        /// Asks to specify which services to make available from the sharing service picker.
        public func sharingServices(_ sharingServices: ((_ items: [Any], _ proposedServices: [NSSharingService]) -> ([NSSharingService]))?) -> Self {
            handlers.sharingServices = sharingServices
            return self
        }
        
        @discardableResult
        /// Asks to provide an object that the selected sharing service can use as its delegate.
        public func delegate(_ delegate: ((_ service: NSSharingService) -> (NSSharingServiceDelegate?))?) -> Self {
            handlers.delegate = delegate
            return self
        }

        override public init(_ identifier: NSToolbarItem.Identifier? = nil) {
            super.init(identifier)
            delegateObject = DelegateObject(self)
        }
    }
}

internal extension ToolbarItem.SharingServicePicker {
    class DelegateObject: NSObject, NSSharingServicePickerToolbarItemDelegate {
        weak var pickerItem: ToolbarItem.SharingServicePicker!

        public func items(for _: NSSharingServicePickerToolbarItem) -> [Any] {
            return pickerItem.handlers.items?() ?? []
        }
        
        public func sharingServicePicker(_ sharingServicePicker: NSSharingServicePicker, didChoose service: NSSharingService?) {
            pickerItem.handlers.didChoose?(service)
        }
        
        public func sharingServicePicker(_ sharingServicePicker: NSSharingServicePicker, delegateFor sharingService: NSSharingService) -> NSSharingServiceDelegate? {
            return pickerItem.handlers.delegate?(sharingService) ?? nil
        }
        
        public func sharingServicePicker(_ sharingServicePicker: NSSharingServicePicker, sharingServicesForItems items: [Any], proposedSharingServices proposedServices: [NSSharingService]) -> [NSSharingService] {
            return pickerItem.handlers.sharingServices?(items, proposedServices) ?? []
        }

        init(_ item: ToolbarItem.SharingServicePicker) {
            pickerItem = item
            super.init()
            pickerItem.servicePickerItem.delegate = self
        }
    }
}

#endif
