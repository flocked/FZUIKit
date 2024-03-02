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

/*
        extension NSView {
            /**
             Attempts to make a given responder the first responder for the window.

             The default implementation returns 'true', accepting first responder status. Subclasses can override this method to update state or perform some action such as highlighting the selection, or to return 'false', refusing first responder status.
             */
            @discardableResult override open func becomeFirstResponder() -> Bool {
                if acceptsFirstResponder, let window = window, window.firstResponder != self, !isChangingFirstResponder {
                    isChangingFirstResponder = true
                    window.makeFirstResponder(self)
                    return true
                }
                isChangingFirstResponder = false
                return true
            }

            /**
             Notifies the receiver that it’s been asked to relinquish its status as first responder in its window.

             The default implementation returns 'true', resigning first responder status. Subclasses can override this method to update state or perform some action such as unhighlighting the selection, or to return 'false', refusing to relinquish first responder status.
             */
            @discardableResult override open func resignFirstResponder() -> Bool {
                if let window = window, window.firstResponder == self, isChangingFirstResponder == false {
                    isChangingFirstResponder = true
                    window.makeFirstResponder(nil)
                    return super.resignFirstResponder()
                }
                isChangingFirstResponder = false
                return super.resignFirstResponder()
            }

            var isChangingFirstResponder: Bool {
                get { getAssociatedValue(key: "isChangingFirstResponder", object: self, initialValue: false) }
                set { set(associatedValue: newValue, key: "isChangingFirstResponder", object: self) }
            }
        }
*/

        extension NSViewController {
            /**
             Attempts to make a given responder the first responder for the window.

             The default implementation returns 'true', accepting first responder status. Subclasses can override this method to update state or perform some action such as highlighting the selection, or to return 'false', refusing first responder status.
             */
            @discardableResult override open func becomeFirstResponder() -> Bool {
                if acceptsFirstResponder, let window = view.window, window.firstResponder != self, isChangingFirstResponder == false {
                    isChangingFirstResponder = true
                    window.makeFirstResponder(self)
                    return super.becomeFirstResponder()
                }
                isChangingFirstResponder = false
                return super.becomeFirstResponder()
            }

            /**
             Notifies the receiver that it’s been asked to relinquish its status as first responder in its window.

             The default implementation returns 'true', resigning first responder status. Subclasses can override this method to update state or perform some action such as unhighlighting the selection, or to return 'false', refusing to relinquish first responder status.
             */
            @discardableResult override open func resignFirstResponder() -> Bool {
                if let window = view.window, window.firstResponder == self, isChangingFirstResponder == false {
                    isChangingFirstResponder = true
                    window.makeFirstResponder(nil)
                    return super.resignFirstResponder()
                }
                isChangingFirstResponder = false
                return super.resignFirstResponder()
            }

            var isChangingFirstResponder: Bool {
                get { getAssociatedValue(key: "isChangingFirstResponder", object: self, initialValue: false) }
                set { set(associatedValue: newValue, key: "isChangingFirstResponder", object: self) }
            }
        }
    #endif
#endif
