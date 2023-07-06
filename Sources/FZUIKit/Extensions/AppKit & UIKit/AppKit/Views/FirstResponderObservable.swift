//
//  File.swift
//  
//
//  Created by Florian Zand on 06.07.23.
//

#if os(macOS)
import AppKit
import FZSwiftUtils

/// A protocol `NSResponder` objects that adds a handler which called whenever it became or resign first responder.
public protocol FirstResponderObservable: NSResponder {
    /// A handler that gets called whenever the responder did become or resign first responder.
    var firstResponderHandler: ((Bool)->())? { get }
}

extension NSView: FirstResponderObservable {
    internal func setupFirstResponderObserver() {
        Swift.print("setupFirstResponderObserver view")
        if let firstResponderHandler = self.firstResponderHandler {
            if firstResponderObserver == nil {
                firstResponderObserver = self.observeChanges(for: \.superview?.window?.firstResponder, sendInitalValue: true, handler: { old, new in
                    guard old != new else { return }
                    let isFirstResponder = (new == self)
                    guard isFirstResponder != self.previousIsFirstRespondder else { return }
                    self.previousIsFirstRespondder = isFirstResponder
                    firstResponderHandler(isFirstResponder)
                })
            }
        } else {
            previousIsFirstRespondder = nil
            firstResponderObserver = nil
        }
    }
}

extension NSViewController: FirstResponderObservable {
    internal func setupFirstResponderObserver() {
        Swift.print("setupFirstResponderObserver viewController")
        if let firstResponderHandler = self.firstResponderHandler {
            if firstResponderObserver == nil {
                firstResponderObserver = self.observeChanges(for: \.view.superview?.window?.firstResponder, sendInitalValue: true, handler: { old, new in
                    guard old != new else { return }
                    let isFirstResponder = (new == self)
                    guard isFirstResponder != self.previousIsFirstRespondder else { return }
                    self.previousIsFirstRespondder = isFirstResponder
                    firstResponderHandler(isFirstResponder)
                })
            }
        } else {
            previousIsFirstRespondder = nil
            firstResponderObserver = nil
        }
    }
}

public extension FirstResponderObservable {
    /// A handler that gets called whenever the responder did become or resign first responder.
    var firstResponderHandler: ((Bool)->())? {
        get { getAssociatedValue(key: "NSResponder_firstResponderHandler", object: self, initialValue: nil) }
        set {
            set(associatedValue: newValue, key: "NSResponder_firstResponderHandler", object: self)
            self.setupFirstResponderObserver()
        }
    }
    
    internal var firstResponderObserver: NSKeyValueObservation? {
        get { getAssociatedValue(key: "NSResponder_firstResponderObserver", object: self, initialValue: nil) }
        set { set(associatedValue: newValue, key: "NSResponder_firstResponderObserver", object: self) }
    }
    
    internal var previousIsFirstRespondder: Bool? {
        get { getAssociatedValue(key: "NSResponder_previousIsFirstRespondderr", object: self, initialValue: nil) }
        set {
            set(associatedValue: newValue, key: "NSResponder_previousIsFirstRespondderr", object: self)
        }
    }
    
    internal func setupFirstResponderObserver() {
        Swift.print("setupFirstResponderObserver")
    }
}

public extension FirstResponderObservable where Self: NSView {

}

public extension FirstResponderObservable where Self: NSViewController {

}

#endif
