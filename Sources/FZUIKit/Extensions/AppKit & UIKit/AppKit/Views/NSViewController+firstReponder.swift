//
//  NSViewController+firstReponder.swift
//
//
//  Created by Florian Zand on 06.07.23.
//

#if os(macOS)
import AppKit
import FZSwiftUtils

extension NSViewController {
    /// A handler that gets called whenever the view controller did become or resign first responder.
    public var firstResponderHandler: ((Bool)->())? {
        get { getAssociatedValue(key: "NSViewController_firstResponderHandler", object: self, initialValue: nil) }
        set {
            set(associatedValue: newValue, key: "NSViewController_firstResponderHandler", object: self)
            self.setupSuperviewObserver()
        }
    }
    
    internal var didSendInitalIsFirstResponder: Bool {
        get { getAssociatedValue(key: "NSViewController_didSendInitalIsFirstResponder", object: self, initialValue: false) }
        set { set(associatedValue: newValue, key: "NSViewController_didSendInitalIsFirstResponder", object: self) }
    }
    
    internal var previousIsFirstResponder: Bool {
        get { getAssociatedValue(key: "NSViewController_previousIsFirstResponder", object: self, initialValue: false) }
        set {
            let oldValue = self.previousIsFirstResponder
            set(associatedValue: newValue, key: "NSViewController_previousIsFirstResponder", object: self)
            if oldValue != newValue || self.didSendInitalIsFirstResponder == false {
                self.didSendInitalIsFirstResponder = true
                self.firstResponderHandler?(newValue)
            }
        }
    }
    
    internal var superviewObserver: NSKeyValueObservation? {
        get { getAssociatedValue(key: "NSViewController_superviewObserver", object: self, initialValue: nil) }
        set { set(associatedValue: newValue, key: "NSViewController_superviewObserver", object: self) }
    }
    
    internal var windowObserver: NSKeyValueObservation? {
        get { getAssociatedValue(key: "NSViewController_windowObserver", object: self, initialValue: nil) }
        set { set(associatedValue: newValue, key: "NSViewController_windowObserver", object: self) }
    }
    
    var firstResponderObserver: NSKeyValueObservation? {
        get { getAssociatedValue(key: "NSViewController_firstResponderObserver", object: self, initialValue: nil) }
        set { set(associatedValue: newValue, key: "NSViewController_firstResponderObserver", object: self) }
    }
    
    internal func setupWindowFirstResponderObserver() {
        self.setupFirstResponderObserver() { firstResponder in
            self.previousIsFirstResponder = (firstResponder == self)
        }
    }
    
    internal func setupWindowObserver() {
        if let superview = self.view.superview {
            self.windowObserver = superview.observeChanges(for: \.window, sendInitalValue: true, handler: { [weak self] old, new in
                guard let self = self, old != new else { return }
                self.setupWindowFirstResponderObserver()
            })
            self.setupWindowFirstResponderObserver()
        } else {
            self.previousIsFirstResponder = false
            self.windowObserver = nil
            previousIsFirstResponder = false
        }
    }
        
    internal func setupSuperviewObserver() {
        if firstResponderHandler != nil {
            if self.superviewObserver == nil {
                self.superviewObserver = view.observeChanges(for: \.superview, sendInitalValue: true, handler: { [weak self] old, new in
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
        let window = window ?? self.view.superview?.window
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
