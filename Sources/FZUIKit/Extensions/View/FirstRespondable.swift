//
//  FirstRespondable.swift
//
//
//  Created by Florian Zand on 06.07.23.
//

#if os(macOS) || os(iOS) || os(tvOS)
    #if os(macOS)
        import AppKit
    #elseif canImport(UIKit)
        import UIKit
    #endif
    import FZSwiftUtils

    /// A type that accepts first responder status of a window.
    public protocol FirstRespondable: NSUIResponder {
        #if os(macOS)
            /**
             Returns a Boolean value indicating whether this object is the first responder.

             `AppKit` dispatches some types of events, such as mouse and keyboard events, to the first responder initially.

             - Returns: `true` if the responder is the first responder; otherwise, `false`.
             */
            var isFirstResponder: Bool { get }

            /// A Boolean value that indicates whether the responder accepts first responder status.
            var acceptsFirstResponder: Bool { get }
        #elseif canImport(UIKit)
            /**
             Returns a Boolean value indicating whether this object is the first responder.

             `UIKit` dispatches some types of events, such as mouse and keyboard events, to the first responder initially.

             - Returns: `true` if the responder is the first responder; otherwise, `false`.
             */
            var isFirstResponder: Bool { get }

            /// Returns a Boolean value indicating whether this object can become the first responder.
            var canBecomeFirstResponder: Bool { get }
        #endif

        /// Attempts to make a given responder the first responder for the window.
        @discardableResult func becomeFirstResponder() -> Bool

        /// Attempts to resign a given responder the first responder for the window.
        @discardableResult func resignFirstResponder() -> Bool
    }

    extension NSUIView: FirstRespondable {}

    extension NSUIViewController: FirstRespondable {}

    #if os(macOS)

        public extension FirstRespondable where Self: NSView {
            /**
             Returns a Boolean value indicating whether this object is the first responder.

             AppKit dispatches some types of events, such as mouse and keyboard events, to the first responder initially.

             - Returns: `true` if the responder is the first responder; otherwise, `false`.
             */
            var isFirstResponder: Bool { (window?.firstResponder == self) }
        }

        public extension FirstRespondable where Self: NSTextField {
            /**
             Returns a Boolean value indicating whether this textfield is the first responder.

             AppKit dispatches some types of events, such as mouse and keyboard events, to the first responder initially.

             - Returns: `true` if the responder is the first responder; otherwise, `false`.
             */
            var isFirstResponder: Bool { currentEditor() == window?.firstResponder }
        }

        public extension FirstRespondable where Self: NSViewController {
            /**
             Returns a Boolean value indicating whether this object is the first responder.

             AppKit dispatches some types of events, such as mouse and keyboard events, to the first responder initially.

             - Returns: `true` if the responder is the first responder; otherwise, `false`.
             */
            var isFirstResponder: Bool { (view.window?.firstResponder == self) }
        }

        extension NSView {
            /**
             Attempts to make the object the first responder in its window.

             Call this method when you want the object to be the first responder.
             
             - Returns: `true` if this object is now the first responder; otherwise, `false`.
             */
            @discardableResult
            public func makeFirstResponder() -> Bool {
                if !isFirstResponder, acceptsFirstResponder, becomeFirstResponder() {
                    window?.makeFirstResponder(self)
                }
                return isFirstResponder
            }
            
            /**
             Attempts to resign the object as first responder in its window.

             Call this method when you want the object to resign the first responder.
             
             - Returns: `true` if this object isn't the first responder; otherwise, `false`.
             */
            @discardableResult
            public func resignFirstResponding() -> Bool {
                if isFirstResponder, resignFirstResponder() {
                    window?.makeFirstResponder(self)
                }
                return !isFirstResponder
            }
        }

        extension NSViewController {
            /**
             Attempts to make the object the first responder in its window.

             Call this method when you want the object to be the first responder.
             
             - Returns: `true` if this object is now the first responder; otherwise, `false`.
             */
            @discardableResult
            public func makeFirstResponder() -> Bool {
                if !isFirstResponder, acceptsFirstResponder {
                    view.window?.makeFirstResponder(self)
                }
                return isFirstResponder
            }
            
            /**
             Attempts to resign the object as first responder in its window.

             Call this method when you want the object to resign the first responder.
             
             - Returns: `true` if this object isn't the first responder; otherwise, `false`.
             */
            @discardableResult
            public func resignFirstResponding() -> Bool {
                if isFirstResponder {
                    view.window?.makeFirstResponder(self)
                }
                return !isFirstResponder
            }
        }
    #endif
#endif

/**
 var isFirstResponder: Bool {
     get { (window?.firstResponder == self) }
     set {
         guard newValue != isFirstResponder else { return }
         if !newValue {
             window?.makeFirstResponder(nil)
         } else if acceptsFirstResponder {
             window?.makeFirstResponder(self)
         }
     }
 }
 
 */
