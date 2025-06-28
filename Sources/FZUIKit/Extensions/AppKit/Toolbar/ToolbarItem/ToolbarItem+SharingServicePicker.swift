//
//  ToolbarItem+SharingServicePicker.swift
//
//
//  Created by Florian Zand on 09.04.23.
//

#if os(macOS)
import AppKit
import SwiftUI

extension Toolbar {
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
        
        fileprivate var _delegate: SharingServiceDelegate!
        
        /// The handlers for the sharing service picker item.
        public struct Handlers {
            /// The handler that provides the items to share.
            public var items: (() -> ([Any]))?
            
            
            /// The handler that gets called when the sharing service is selected for the current item.
            public var didSelect: ((_ service: NSSharingService?) -> Void)?
            
            /**
             The handler that provides the sharing services for items.
             
             Use this handler to remove default services, add custom services, or reorder the existing services before the picker appears onscreen.
             */
            public var sharingServices: ((_ items: [Any], _ proposedServices: [NSSharingService]) -> ([NSSharingService]))?
            
            /// The handler that provides the delegate for the selected sharing service.
            public var delegate: ((_ service: NSSharingService) -> (NSSharingServiceDelegate?))?
            
            /// The handler that gets called when items are about to share.
            public var willShare: ((_ items: [Any], _ service: NSSharingService) -> ())?
            
            /// The handler that gets called when items did share.
            public var didShare: ((_ items: [Any], _ service: NSSharingService) -> ())?
            
            /// The handler that gets called when items did fail to share.
            public var didFailToShare: ((_ items: [Any], _ service: NSSharingService, _ error: any Error) -> ())?
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
        open func didSelect(_ didSelect: ((_ service: NSSharingService?) -> Void)?) -> Self {
            handlers.didSelect = didSelect
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
            _delegate = .init(for: self)
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
            _delegate = .init(for: self)
            _delegate.delegate = delegate
        }
    }
    
    fileprivate class SharingServiceDelegate: NSObject, NSSharingServicePickerToolbarItemDelegate, NSSharingServiceDelegate {
        weak var pickerItem: Toolbar.SharingServicePicker!
        weak var delegate: NSSharingServicePickerToolbarItemDelegate?
        
        public func items(for item: NSSharingServicePickerToolbarItem) -> [Any] {
            pickerItem.handlers.items?() ?? delegate?.items(for: item) ?? []
        }
        
        public func sharingServicePicker(_ sharingServicePicker: NSSharingServicePicker, didChoose service: NSSharingService?) {
            pickerItem.handlers.didSelect?(service)
            delegate?.sharingServicePicker?(sharingServicePicker, didChoose: service)
        }
        
        func sharingServicePicker(_ sharingServicePicker: NSSharingServicePicker, delegateFor sharingService: NSSharingService) -> (any NSSharingServiceDelegate)? {
            pickerItem.handlers.delegate?(sharingService) ?? delegate?.sharingServicePicker?(sharingServicePicker, delegateFor: sharingService) ?? self
        }
        
        public func sharingServicePicker(_ sharingServicePicker: NSSharingServicePicker, sharingServicesForItems items: [Any], proposedSharingServices proposedServices: [NSSharingService]) -> [NSSharingService] {
            pickerItem.handlers.sharingServices?(items, proposedServices) ?? delegate?.sharingServicePicker?(sharingServicePicker, sharingServicesForItems: items, proposedSharingServices: proposedServices) ?? proposedServices
        }
        
        func sharingService(_ sharingService: NSSharingService, willShareItems items: [Any]) {
            pickerItem.handlers.willShare?(items, sharingService)
        }
        
        func sharingService(_ sharingService: NSSharingService, didShareItems items: [Any]) {
            pickerItem.handlers.didShare?(items, sharingService)
        }
        
        func sharingService(_ sharingService: NSSharingService, didFailToShareItems items: [Any], error: any Error) {
            pickerItem.handlers.didFailToShare?(items, sharingService, error)
        }
        
        init(for item: Toolbar.SharingServicePicker) {
            pickerItem = item
            super.init()
            pickerItem.servicePickerItem.delegate = self
        }
    }
}

class ValidateServicePickerToolbarItem: NSSharingServicePickerToolbarItem {
    weak var item: Toolbar.SharingServicePicker?
    
    init(for item: Toolbar.SharingServicePicker) {
        super.init(itemIdentifier: item.identifier)
        self.item = item
    }
    
    override func validate() {
        super.validate()
        guard let item = item else { return }
        item.validate()
        item.validateHandler?(item)
    }
}

#endif
