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
        
        /// The handler that determines which services to make available from the sharing service picker.
        public var sharingServices: ((_ items: [Any], _ proposed: [NSSharingService])->([NSSharingService]))?
        
        /// The handler that gets called when the sharig service is selected.
        public var selected: ((_ selected: NSSharingService?)->())?
        
        var needsDelegate: Bool {
            items != nil || sharingServices != nil || sharingServices != nil
        }
    }
    
    /// The handlers for the item.
    public var handlers: Handlers {
        get { getAssociatedValue("handlers") ?? Handlers() }
        set {
            setAssociatedValue(newValue, key: "handlers")
            if !handlers.needsDelegate, delegate is Delegate {
                delegate = nil
                handlerDelegate = nil
            } else if handlers.needsDelegate, !(delegate is Delegate) {
                handlerDelegate = Delegate(for: self)
                delegate = handlerDelegate
            }
        }
    }
    
    private var handlerDelegate: Delegate? {
        get { getAssociatedValue("handlerDelegate") }
        set { setAssociatedValue(newValue, key: "handlerDelegate") }
    }
    
    private class Delegate: NSObject, NSSharingServicePickerToolbarItemDelegate {
        weak var item: NSSharingServicePickerToolbarItem?
        
        init(for item: NSSharingServicePickerToolbarItem) {
            self.item = item
            super.init()
            item.delegate = self
        }
        
        public func items(for pickerToolbarItem: NSSharingServicePickerToolbarItem) -> [Any] {
            item?.handlers.items?() ?? []
        }
        
        public func sharingServicePicker(_ sharingServicePicker: NSSharingServicePicker, sharingServicesForItems items: [Any], proposedSharingServices proposedServices: [NSSharingService]) -> [NSSharingService] {
            item?.handlers.sharingServices?(items, proposedServices) ?? proposedServices
        }
        
        public func sharingServicePicker(_ sharingServicePicker: NSSharingServicePicker, didChoose service: NSSharingService?) {
            item?.handlers.selected?(service)
        }
    }
}

#endif
