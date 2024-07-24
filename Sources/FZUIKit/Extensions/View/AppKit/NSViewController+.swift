//
//  NSViewController+.swift
//
//
//  Created by Florian Zand on 20.07.24.
//

#if os(macOS)
import AppKit

public extension NSViewController {
    /**
     A Boolean value that indicates whether the window of the view controller is the first responder.
     
     The system dispatches some types of events, such as mouse and keyboard events, to the first responder initially.     
     */
    var isFirstResponder: Bool {
        view.window?.firstResponder == self
    }
    
    /**
     Attempts to make the window of the view controller the first responder in its window.
     
     Call this method when you want the object to be the first responder.
     
     - Returns: `true` if the window of the view controller is now the first responder; otherwise, `false`.
     */
    @discardableResult
    func makeFirstResponder() -> Bool {
        if !isFirstResponder, acceptsFirstResponder {
            view.window?.makeFirstResponder(self)
        }
        return isFirstResponder
    }
    
    /**
     Attempts to resign the window of the view controller as first responder in its window.
     
     Call this method when you want the view controller's window to resign the first responder.
     
     - Returns: `true` if the view controller's window isn't the first responder; otherwise, `false`.
     */
    @discardableResult
    func resignFirstResponding() -> Bool {
        if isFirstResponder {
            view.window?.makeFirstResponder(nil)
        }
        return !isFirstResponder
    }
}

#endif
