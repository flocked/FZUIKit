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
    /// A handler that gets called whenever the view did become or resign first responder.
    public var firstResponderHandler: ((Bool)->())? {
        get { getAssociatedValue(key: "NSView_firstResponderHandler", object: self, initialValue: nil) }
        set {
            set(associatedValue: newValue, key: "NSView_firstResponderHandler", object: self)
            self.setupFirstResponderObserver()
        }
    }
    
    internal var previousIsFirstRespondder: Bool? {
        get { getAssociatedValue(key: "NSView_previousIsFirstRespondderr", object: self, initialValue: nil) }
        set {
            set(associatedValue: newValue, key: "NSView_previousIsFirstRespondderr", object: self)
        }
    }
    
    internal var firstResponderObserver: NSKeyValueObservation? {
        get { getAssociatedValue(key: "NSView_firstResponderObserver", object: self, initialValue: nil) }
        set { set(associatedValue: newValue, key: "NSView_firstResponderObserver", object: self) }
    }
    
    internal func setupFirstResponderObserver() {
        if let firstResponderHandler = self.firstResponderHandler {
            guard firstResponderObserver == nil else { return }
            firstResponderObserver = self.observeChanges(for: \.superview?.window?.firstResponder, sendInitalValue: true, handler: { old, new in
                guard old != new else { return }
                let isFirstResponder = (new == self)
                guard isFirstResponder != self.previousIsFirstRespondder else { return }
                self.previousIsFirstRespondder = isFirstResponder
                self.isFirstResponder = isFirstResponder
                firstResponderHandler(isFirstResponder)
            })
        } else {
            previousIsFirstRespondder = nil
            firstResponderObserver = nil
        }
    }
}
#endif

