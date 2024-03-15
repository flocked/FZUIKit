//
//  FirstRespondable.swift
//
//
//  Created by Florian Zand on 06.07.23.
//

#if os(macOS)
import AppKit
import FZSwiftUtils

/// A type that accepts first responder status of a window.
public protocol FirstRespondable: NSUIResponder {
    
    /**
     Returns a Boolean value indicating whether this object is the first responder.
     
     The system dispatches some types of events, such as mouse and keyboard events, to the first responder initially.
     
     - Returns: `true` if the responder is the first responder; otherwise, `false`.
     */
    var isFirstResponder: Bool { get }
    
    /// A Boolean value that indicates whether the responder accepts first responder status.
    var acceptsFirstResponder: Bool { get }
    
    /**
     Attempts to make the object the first responder in its window.
     
     Call this method when you want the object to be the first responder.
     
     - Returns: `true` if this object is now the first responder; otherwise, `false`.
     */
    @discardableResult func makeFirstResponder() -> Bool
    
    /**
     Attempts to resign the object as first responder in its window.
     
     Call this method when you want the object to resign the first responder.
     
     - Returns: `true` if this object isn't the first responder; otherwise, `false`.
     */
    @discardableResult func resignFirstResponding() -> Bool
}

extension NSUIView: FirstRespondable { }
extension NSUIViewController: FirstRespondable { }

public extension FirstRespondable where Self: NSView {
    var isFirstResponder: Bool {
        window?.firstResponder == self
    }
    
    @discardableResult
    func makeFirstResponder() -> Bool {
        if !isFirstResponder, acceptsFirstResponder {
            window?.makeFirstResponder(self)
        }
        return isFirstResponder
    }
    
    @discardableResult
    func resignFirstResponding() -> Bool {
        if isFirstResponder {
            window?.makeFirstResponder(nil)
        }
        return !isFirstResponder
    }
}

public extension FirstRespondable where Self: NSTextView {
    @discardableResult
    func makeFirstResponder() -> Bool {
        if !isFirstResponder, acceptsFirstResponder {
            window?.makeFirstResponder(self)
        }
        selectedRanges = selectedRanges
        return isFirstResponder
    }
}

public extension FirstRespondable where Self: NSTextField {
    var isFirstResponder: Bool { currentEditor() == window?.firstResponder }
    
    @discardableResult
    func makeFirstResponder() -> Bool {
        if !isFirstResponder, acceptsFirstResponder {
            window?.makeFirstResponder(self)
        }
        return isFirstResponder
    }
    
    @discardableResult
    func resignFirstResponding() -> Bool {
        if isFirstResponder {
            window?.makeFirstResponder(nil)
        }
        return !isFirstResponder
    }
}

public extension FirstRespondable where Self: NSViewController {
    var isFirstResponder: Bool { (view.window?.firstResponder == self) }
    
    @discardableResult
    func makeFirstResponder() -> Bool {
        if !isFirstResponder, acceptsFirstResponder {
            view.window?.makeFirstResponder(self)
        }
        return isFirstResponder
    }
    
    @discardableResult
    func resignFirstResponding() -> Bool {
        if isFirstResponder {
            view.window?.makeFirstResponder(nil)
        }
        return !isFirstResponder
    }
}

#endif
