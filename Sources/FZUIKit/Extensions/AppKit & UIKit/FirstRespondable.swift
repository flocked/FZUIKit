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
public protocol FirstRespondable {
    /**
     Returns a Boolean value indicating whether this object is the first responder.

     AppKit and UIKit dispatches some types of events, such as mouse and keyboard events, to the first responder initially.

     - Returns: `true if the responder is the first responder; otherwise, `false`.
     */
    var isFirstResponder: Bool { get }
    @discardableResult func resignFirstResponder() -> Bool
    @discardableResult func becomeFirstResponder() -> Bool
}

extension NSUIView: FirstRespondable { }
extension NSUIViewController: FirstRespondable { }
#if os(macOS)
public extension FirstRespondable where Self: NSView {
    /**
     Returns a Boolean value indicating whether this object is the first responder.

     AppKit dispatches some types of events, such as mouse and keyboard events, to the first responder initially.

     - Returns: `true if the responder is the first responder; otherwise, `false`.
     */
    var isFirstResponder: Bool {
        (self.window?.firstResponder == self)
    }
    
    /*
    @discardableResult func makeFirstResponder() -> Bool {
        self.window?.makeFirstResponder(self) ?? false
    }
     */
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
    
    /*
    @discardableResult func makeFirstResponder() -> Bool {
        self.view.window?.makeFirstResponder(self) ?? false
    }
     */
}

extension NSView {
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
/*
#if canImport(UIKit)
public extension FirstRespondable where Self: UIView {
    @discardableResult func makeFirstResponder() -> Bool {
        self.becomeFirstResponder()
    }
}

public extension FirstRespondable where Self: UIViewController {
    @discardableResult func makeFirstResponder() -> Bool {
        self.becomeFirstResponder()
    }
}
#endif
*/
