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
        
        
        /// Asks to provide an object that the selected sharing service can use as its delegate.
        public var delegate: ((_ service: NSSharingService) -> (NSSharingServiceDelegate?))?
        
        /// The handler that gets called when the sharig service is selected.
        public var selected: ((_ selected: NSSharingService?)->())?
        
        var needsDelegate: Bool {
            items != nil || sharingServices != nil || sharingServices != nil || delegate != nil
        }
    }
    
    /// The handlers for the item.
    public var handlers: Handlers {
        get { getAssociatedValue("handlers") ?? Handlers() }
        set {
            setAssociatedValue(newValue, key: "handlers")
            if !handlers.needsDelegate {
                handlerDelegate = nil
            } else {
                var delegate: NSSharingServicePickerToolbarItemDelegate?
                if let _delegate = delegate as? Delegate {
                    delegate = _delegate.delegate
                } else {
                    delegate = self.delegate
                }
                handlerDelegate = nil
                self.delegate = delegate
                if delegate?.responds(to: #selector(NSSharingServicePickerToolbarItemDelegate.sharingServicePicker(_:sharingServicesForItems:proposedSharingServices:))) == true || handlers.sharingServices != nil {
                    handlerDelegate = Delegate(for: self)
                } else {
                    handlerDelegate = DelegateAlt(for: self)
                }
            }
            
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
        weak var delegate: NSSharingServicePickerToolbarItemDelegate?
        var delegateObservation: KeyValueObservation?
        
        init(for item: NSSharingServicePickerToolbarItem) {
            self.item = item
            super.init()
            delegate = item.delegate
            item.delegate = self
            delegateObservation = item.observeChanges(for: \.delegate) { [weak self] old, new in
                guard let self = self, new !== self else { return }
                self.delegate = new
                self.item?.delegate = new
            }
        }
        
        public func items(for pickerToolbarItem: NSSharingServicePickerToolbarItem) -> [Any] {
            item?.handlers.items?() ?? []
        }
        
        func sharingServicePicker(_ sharingServicePicker: NSSharingServicePicker, delegateFor sharingService: NSSharingService) -> (any NSSharingServiceDelegate)? {
            item?.handlers.delegate?(sharingService)
        }
        
        public func sharingServicePicker(_ sharingServicePicker: NSSharingServicePicker, didChoose service: NSSharingService?) {
            item?.handlers.selected?(service)
        }
        
        deinit {
            item?.delegate = delegate
        }
    }
    
    private class DelegateAlt: Delegate {
        public func sharingServicePicker(_ sharingServicePicker: NSSharingServicePicker, sharingServicesForItems items: [Any], proposedSharingServices proposedServices: [NSSharingService]) -> [NSSharingService] {
            item?.handlers.sharingServices?(items, proposedServices) ?? proposedServices
        }
    }
}

#endif
