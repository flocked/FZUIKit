//
//  NSView+FirstResponder.swift
//
//
//  Created by Florian Zand on 06.07.23.
//

#if os(macOS)
import AppKit
import FZSwiftUtils

extension NSView {
    /// A handler that gets called whenever the view controller did become or resign first responder.
    public var firstResponderHandler: ((Bool)->())? {
        get { getAssociatedValue(key: "NSView_firstResponderHandler", object: self, initialValue: nil) }
        set {
            set(associatedValue: newValue, key: "NSView_firstResponderHandler", object: self)
            self.setupFirstResponderObserver()
        }
    }
    
    internal func setupFirstResponderObserver() {
        if let firstResponderHandler = self.firstResponderHandler {
            if firstResponderObserver == nil {
                firstResponderObserver = self.observeChanges(for: \.superview?.window?.firstResponder, sendInitalValue: true, handler: { old, new in
                    guard old != new else { return }
                    let isFirstResponder = (new == self)
                    firstResponderHandler(isFirstResponder)
                })
            }
        } else {
            firstResponderObserver = nil
        }
    }
    
    internal var firstResponderObserver: NSKeyValueObservation? {
        get { getAssociatedValue(key: "NSView_firstResponderObserver", object: self, initialValue: nil) }
        set { set(associatedValue: newValue, key: "NSView_firstResponderObserver", object: self) }
    }
}
#endif
