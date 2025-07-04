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
     A Boolean value indicating whether view controller is the first responder of the view's window.
     
     The system dispatches some types of events, such as mouse and keyboard events, to the first responder initially.     
     */
    var isFirstResponder: Bool {
        view.window?.firstResponder == self
    }
    
    /**
     Attempts to make the window of the view controller the first responder of the view's window.
          
     - Returns: `true` if the window is the first responder of the view's window; otherwise, `false`.
     */
    @discardableResult
    func makeFirstResponder() -> Bool {
        if !isFirstResponder, acceptsFirstResponder {
            view.window?.makeFirstResponder(self)
        }
        return isFirstResponder
    }
    
    /**
     Attempts to resign the window of the view controller as first responder of the view's window.
          
     - Returns: `true` if the view controller isn't the first responder of the view's window; otherwise, `false`.
     */
    @discardableResult
    func resignAsFirstResponder() -> Bool {
        if isFirstResponder {
            view.window?.makeFirstResponder(nil)
        }
        return !isFirstResponder
    }
}

#endif
