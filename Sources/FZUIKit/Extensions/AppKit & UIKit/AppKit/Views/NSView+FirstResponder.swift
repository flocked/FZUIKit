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
            self.setupSuperviewObserver()
        }
    }
    
    internal var didSendInitalIsFirstResponder: Bool {
        get { getAssociatedValue(key: "NSView_didSendInitalIsFirstResponder", object: self, initialValue: false) }
        set { set(associatedValue: newValue, key: "NSView_didSendInitalIsFirstResponder", object: self) }
    }
    
    internal var previousIsFirstResponder: Bool {
        get { getAssociatedValue(key: "NSView_previousIsFirstResponder", object: self, initialValue: false) }
        set {
            let oldValue = self.previousIsFirstResponder
            set(associatedValue: newValue, key: "NSView_previousIsFirstResponder", object: self)
            if oldValue != newValue || self.didSendInitalIsFirstResponder == false {
                self.didSendInitalIsFirstResponder = true
                self.firstResponderHandler?(newValue)
            }
        }
    }
    
    internal var superviewObserver: NSKeyValueObservation? {
        get { getAssociatedValue(key: "NSView_superviewObserver", object: self, initialValue: nil) }
        set { set(associatedValue: newValue, key: "NSView_superviewObserver", object: self) }
    }
    
    internal var windowObserver: NSKeyValueObservation? {
        get { getAssociatedValue(key: "NSView_windowObserver", object: self, initialValue: nil) }
        set { set(associatedValue: newValue, key: "NSView_windowObserver", object: self) }
    }
    
    var firstResponderObserver: NSKeyValueObservation? {
        get { getAssociatedValue(key: "NSView_firstResponderObserver", object: self, initialValue: nil) }
        set { set(associatedValue: newValue, key: "NSView_firstResponderObserver", object: self) }
    }
    
    internal func setupWindowFirstResponderObserver() {
        self.setupFirstResponderObserver() { firstResponder in
            self.previousIsFirstResponder = (firstResponder == self)
        }
    }
    
    internal func setupWindowObserver() {
        if let superview = self.superview {
            self.windowObserver = superview.observeChanges(for: \.window, sendInitalValue: true, handler: { [weak self] old, new in
                guard let self = self, old != new else { return }
                self.setupWindowFirstResponderObserver()
            })
            self.setupWindowFirstResponderObserver()
        } else {
            self.previousIsFirstResponder = false
            self.windowObserver = nil
        }
    }
        
    internal func setupSuperviewObserver() {
        if firstResponderHandler != nil {
            if superviewObserver == nil {
                self.superviewObserver = self.observeChanges(for: \.superview, sendInitalValue: true, handler: { [weak self] old, new in
                    guard let self = self, old != new else { return }
                    self.setupWindowObserver()
                })
            }
            self.setupWindowObserver()
        } else {
            firstResponderObserver = nil
            superviewObserver = nil
            windowObserver = nil
            didSendInitalIsFirstResponder = false
        }
    }
    
    func setupFirstResponderObserver(window: NSWindow? = nil, handler: ((NSResponder?)->())? = nil) {
        let window = window ?? self.superview?.window
        if let handler, let window = window {
            firstResponderObserver = window.observeChanges(for: \.firstResponder, sendInitalValue: true, handler: { old, new in
                guard old != new else { return }
                handler(new)
            })
        } else {
            firstResponderObserver = nil
            previousIsFirstResponder = false
        }
    }
}
#endif
