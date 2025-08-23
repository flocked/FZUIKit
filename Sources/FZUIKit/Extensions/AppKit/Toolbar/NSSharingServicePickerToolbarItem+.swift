//
//  NSSharingServicePickerToolbarItem+.swift
//
//
//  Created by Florian Zand on 15.09.22.
//

#if os(macOS)

import AppKit
import FZSwiftUtils

extension NSSharingServicePickerToolbarItem {
    /// Handllers for a sharing service picker toolbar item.
    public struct Handlers {
        /// The handler that determines the items to share.
        public var items: (()->([Any]))?
        
        /// The handler that is called when the sharing service is selected for the current item.
        public var didSelect: ((_ selected: NSSharingService?)->())?
        
        /**
         The handler that provides the sharing services for items.
         
         Use this handler to remove default services, add custom services, or reorder the existing services before the picker appears onscreen.
         */
        public var sharingServices: ((_ items: [Any], _ proposed: [NSSharingService])->([NSSharingService]))?
        
        
        /// The handler that provides the delegate for the selected sharing service.
        public var delegate: ((_ service: NSSharingService) -> (NSSharingServiceDelegate?))?
        
        /// The handler that is called when items are about to share.
        public var willShare: ((_ items: [Any], _ service: NSSharingService) -> ())?
        
        /// The handler that is called when items did share.
        public var didShare: ((_ items: [Any], _ service: NSSharingService) -> ())?
        
        /// The handler that is called when items did fail to share.
        public var didFailToShare: ((_ items: [Any], _ service: NSSharingService, _ error: any Error) -> ())?
        
        var needsDelegate: Bool {
            items != nil || sharingServices != nil || sharingServices != nil || delegate != nil || willShare != nil || didShare != nil || didFailToShare != nil
        }
    }
    
    /// The handlers for the item.
    public var handlers: Handlers {
        get { getAssociatedValue("handlers") ?? Handlers() }
        set {
            setAssociatedValue(newValue, key: "handlers")
            if !handlers.needsDelegate {
                handlerDelegate = nil
            } else if handlerDelegate == nil {
                handlerDelegate = Delegate(for: self)
            }
        }
    }
    
    private var handlerDelegate: Delegate? {
        get { getAssociatedValue("handlerDelegate") }
        set { setAssociatedValue(newValue, key: "handlerDelegate") }
    }
    
    private class Delegate: NSObject, NSSharingServicePickerToolbarItemDelegate, NSSharingServiceDelegate {
        weak var item: NSSharingServicePickerToolbarItem?
        weak var delegate: NSSharingServicePickerToolbarItemDelegate?
        var observation: KeyValueObservation?
        
        init(for item: NSSharingServicePickerToolbarItem) {
            self.item = item
            super.init()
            delegate = item.delegate
            item.delegate = self
            observation = item.observeChanges(for: \.delegate) { [weak self] old, new in
                guard let self = self, new !== self else { return }
                self.delegate = new
                self.item?.delegate = new
            }
        }
        
        public func items(for pickerToolbarItem: NSSharingServicePickerToolbarItem) -> [Any] {
            item?.handlers.items?() ?? delegate?.items(for: pickerToolbarItem) ?? []
        }
        
        public func sharingServicePicker(_ sharingServicePicker: NSSharingServicePicker, didChoose service: NSSharingService?) {
            item?.handlers.didSelect?(service)
            delegate?.sharingServicePicker?(sharingServicePicker, didChoose: service)
        }
        
        public func sharingServicePicker(_ sharingServicePicker: NSSharingServicePicker, sharingServicesForItems items: [Any], proposedSharingServices proposedServices: [NSSharingService]) -> [NSSharingService] {
            item?.handlers.sharingServices?(items, proposedServices) ?? delegate?.sharingServicePicker?(sharingServicePicker, sharingServicesForItems: items, proposedSharingServices: proposedServices) ?? proposedServices
        }
        
        func sharingServicePicker(_ sharingServicePicker: NSSharingServicePicker, delegateFor sharingService: NSSharingService) -> (any NSSharingServiceDelegate)? {
            item?.handlers.delegate?(sharingService) ?? delegate?.sharingServicePicker?(sharingServicePicker, delegateFor: sharingService) ?? self
        }
        
        func sharingService(_ sharingService: NSSharingService, willShareItems items: [Any]) {
            item?.handlers.willShare?(items, sharingService)
        }
        
        func sharingService(_ sharingService: NSSharingService, didShareItems items: [Any]) {
            item?.handlers.didShare?(items, sharingService)
        }
        
        func sharingService(_ sharingService: NSSharingService, didFailToShareItems items: [Any], error: any Error) {
            item?.handlers.didFailToShare?(items, sharingService, error)
        }
        
        deinit {
            observation = nil
            item?.delegate = delegate
        }
    }
}

#endif
