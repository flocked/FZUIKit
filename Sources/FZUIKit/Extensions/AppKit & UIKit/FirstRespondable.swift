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
import FZSwiftUtils

/// A protocol that indicating whether the conforming object is the first responder.
@objc public protocol FirstRespondable {
    /**
     Returns a Boolean value indicating whether this object is the first responder.

     AppKit and UIKit dispatches some types of events, such as mouse and keyboard events, to the first responder initially.

     - Returns: `true if the responder is the first responder; otherwise, `false`.
     */
    @objc dynamic var isFirstResponder: Bool { get }
    #if os(macOS)
    var acceptsFirstResponder: Bool { get }
    #elseif canImport(UIKit)
    var canBecomeFirstResponder: Bool { get }
    #endif
    @discardableResult func resignFirstResponder() -> Bool
    @discardableResult func becomeFirstResponder() -> Bool
}

extension NSUIView: FirstRespondable {
    /**
     Returns a Boolean value indicating whether this object is the first responder.

     AppKit dispatches some types of events, such as mouse and keyboard events, to the first responder initially.

     - Returns: `true if the responder is the first responder; otherwise, `false`.
     */
    @objc dynamic public var isFirstResponder: Bool {
        get { (self.window?.firstResponder == self) }
        set { }
    }
}
extension NSUIViewController: FirstRespondable {
    /**
     Returns a Boolean value indicating whether this object is the first responder.

     AppKit dispatches some types of events, such as mouse and keyboard events, to the first responder initially.

     - Returns: `true if the responder is the first responder; otherwise, `false`.
     */
    @objc dynamic public var isFirstResponder: Bool {
        get { (self.view.window?.firstResponder == self) }
        set { }
    }
}

#if os(macOS)
public extension FirstRespondable where Self: NSView {

}

public extension FirstRespondable where Self: NSViewController {

}

extension NSView {
    /**
     Attempts to make a given responder the first responder for the window.
     
     The default implementation returns 'true', accepting first responder status. Subclasses can override this method to update state or perform some action such as highlighting the selection, or to return 'false', refusing first responder status.
     */
   @discardableResult override open func becomeFirstResponder() -> Bool {
       if self.acceptsFirstResponder, let window = self.window {
           if window.firstResponder != self, isChangingFirstResponder == false {
               isChangingFirstResponder = true
               window.makeFirstResponder(self)
               return super.becomeFirstResponder()
           }
       }
       isChangingFirstResponder = false
       return super.becomeFirstResponder()
   }
   
    /**
     Notifies the receiver that it’s been asked to relinquish its status as first responder in its window.
     
     The default implementation returns 'true', resigning first responder status. Subclasses can override this method to update state or perform some action such as unhighlighting the selection, or to return 'false', refusing to relinquish first responder status.
     */
    @discardableResult override open func resignFirstResponder() -> Bool {
        if let window = self.window {
            if window.firstResponder == self, isChangingFirstResponder == false {
                isChangingFirstResponder = true
                window.makeFirstResponder(nil)
                return super.resignFirstResponder()
            }
        }
        isChangingFirstResponder = false
        return super.resignFirstResponder()
   }
   
   internal var isChangingFirstResponder: Bool {
       get { getAssociatedValue(key: "NSView_isChangingFirstResponder", object: self, initialValue: false) }
       set { set(associatedValue: newValue, key: "NSView_isChangingFirstResponder", object: self) }
   }
}

extension NSViewController {
    /**
     Attempts to make a given responder the first responder for the window.
     
     The default implementation returns 'true', accepting first responder status. Subclasses can override this method to update state or perform some action such as highlighting the selection, or to return 'false', refusing first responder status.
     */
    @discardableResult override open func becomeFirstResponder() -> Bool {
       if self.acceptsFirstResponder, let window = self.view.window {
           if window.firstResponder != self, isChangingFirstResponder == false {
               isChangingFirstResponder = true
               window.makeFirstResponder(self)
               return super.becomeFirstResponder()
           }
       }
       isChangingFirstResponder = false
       return super.becomeFirstResponder()
   }
   
    /**
     Notifies the receiver that it’s been asked to relinquish its status as first responder in its window.
     
     The default implementation returns 'true', resigning first responder status. Subclasses can override this method to update state or perform some action such as unhighlighting the selection, or to return 'false', refusing to relinquish first responder status.
     */
    @discardableResult override open func resignFirstResponder() -> Bool {
        if let window = self.view.window {
            if window.firstResponder == self, isChangingFirstResponder == false {
                isChangingFirstResponder = true
                window.makeFirstResponder(nil)
                return super.resignFirstResponder()
            }
        }
        isChangingFirstResponder = false
        return super.resignFirstResponder()
   }
   
   internal var isChangingFirstResponder: Bool {
       get { getAssociatedValue(key: "NSViewController_isChangingFirstResponder", object: self, initialValue: false) }
       set { set(associatedValue: newValue, key: "NSViewController_isChangingFirstResponder", object: self) }
   }
}
#endif
