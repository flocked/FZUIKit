//
//  FirstRespondable.swift
//  Example
//
//  Created by Florian Zand on 06.07.23.
//

#if os(macOS)
import AppKit
#elseif canImport(UIKit)
import UIKit
#endif

/// A protocol that indicating whether the conforming object is the first responder.
public protocol FirstRespondable {
    /**
     Returns a Boolean value indicating whether this object is the first responder.

     AppKit and UIKit dispatches some types of events, such as mouse and keyboard events, to the first responder initially.

     - Returns: `true if the responder is the first responder; otherwise, `false`.
     */
    var isFirstResponder: Bool { get }
}

extension NSUIView: FirstRespondable { }
extension NSUIViewController: FirstRespondable { }

public extension FirstRespondable where Self: NSView {
    /**
     Returns a Boolean value indicating whether this object is the first responder.

     AppKit dispatches some types of events, such as mouse and keyboard events, to the first responder initially.

     - Returns: `true if the responder is the first responder; otherwise, `false`.
     */
    var isFirstResponder: Bool {
        (self.window?.firstResponder == self)
    }
}
 

public extension FirstRespondable where Self: NSViewController {
    /**
     Returns a Boolean value indicating whether this object is the first responder.

     AppKit dispatches some types of events, such as mouse and keyboard events, to the first responder initially.

     - Returns: `true if the responder is the first responder; otherwise, `false`.
     */
    var isFirstResponder: Bool {
        (self.view.window?.firstResponder == self)
    }
}
