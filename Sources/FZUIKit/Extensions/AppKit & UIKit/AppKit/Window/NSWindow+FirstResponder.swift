//
//  NSWindow+FirstResponder.swift
//
//
//  Created by Florian Zand on 06.07.23.
//

#if os(macOS)
import AppKit
import FZSwiftUtils

extension NSWindow {
    /// A handler that gets called whenever the first responder of the window changes.
    public var firstResponderHandler: ((NSResponder?)->())? {
        get { getAssociatedValue(key: "NSWindow_firstResponderHandler", object: self, initialValue: nil) }
        set {
            set(associatedValue: newValue, key: "NSWindow_firstResponderHandler", object: self)
            self.setupFirstResponderObserver()
        }
    }
    
    internal var firstResponderObserver: NSKeyValueObservation? {
        get { getAssociatedValue(key: "NSWindow_firstResponderObserver", object: self, initialValue: nil) }
        set { set(associatedValue: newValue, key: "NSWindow_firstResponderObserver", object: self) }
    }
    
    internal func setupFirstResponderObserver() {
        if let firstResponderHandler = self.firstResponderHandler, firstResponderObserver == nil  {
            firstResponderObserver = self.observeChanges(for: \.firstResponder, sendInitalValue: true, handler: { old, new in
                guard old != new else { return }
                firstResponderHandler(new)
            })
            firstResponderHandler(self.firstResponder)
        } else {
            firstResponderObserver = nil
        }
    }
}
#endif
