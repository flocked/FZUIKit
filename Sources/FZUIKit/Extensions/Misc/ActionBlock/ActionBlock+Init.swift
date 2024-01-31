//
//  ActionBlock+Init.swift
//
//
//  Created by Florian Zand on 30.05.22.
//

#if os(macOS)

    import AppKit

    public extension NSMenuItem {
        /// Initializes the menu item with the specified title and action handler.
        convenience init(_ title: String, action: @escaping ActionBlock) {
            self.init(title: title, action: action)
        }

        /// Initializes the menu item with the specified title and action handler.
        convenience init(title: String, action: @escaping ActionBlock) {
            self.init(title: title, keyEquivalent: "", action: action)
        }

        /// Initializes the menu item with the specified title, key equivalent and action handler.
        convenience init(title: String, keyEquivalent: String, action: @escaping ActionBlock) {
            self.init(title: title, action: nil, keyEquivalent: keyEquivalent)
            actionBlock = action
        }
    }

    public extension NSPanGestureRecognizer {
        /// Initializes the gesture recognizer with the specified action handler.
        convenience init(action: @escaping ActionBlock) {
            self.init()
            actionBlock = action
        }
    }

    public extension NSMagnificationGestureRecognizer {
        /// Initializes the gesture recognizer with the specified action handler.
        convenience init(action: @escaping ActionBlock) {
            self.init()
            actionBlock = action
        }
    }

    public extension NSClickGestureRecognizer {
        /// Initializes the gesture recognizer with the specified action handler.
        convenience init(action: @escaping ActionBlock) {
            self.init()
            actionBlock = action
        }
    }

    public extension NSPressGestureRecognizer {
        /// Initializes the gesture recognizer with the specified action handler.
        convenience init(action: @escaping ActionBlock) {
            self.init()
            actionBlock = action
        }
    }

    public extension NSRotationGestureRecognizer {
        /// Initializes the gesture recognizer with the specified action handler.
        convenience init(action: @escaping ActionBlock) {
            self.init()
            actionBlock = action
        }
    }

#elseif os(iOS) || os(tvOS)
    import UIKit

    public extension UISwipeGestureRecognizer {
        /// Initializes the gesture recognizer with the specified action handler.
        convenience init(action: @escaping ActionBlock) {
            self.init()
            actionBlock = action
        }
    }

    public extension UIPanGestureRecognizer {
        /// Initializes the gesture recognizer with the specified action handler.
        convenience init(action: @escaping ActionBlock) {
            self.init()
            actionBlock = action
        }
    }

    public extension UILongPressGestureRecognizer {
        /// Initializes the gesture recognizer with the specified action handler.
        convenience init(action: @escaping ActionBlock) {
            self.init()
            actionBlock = action
        }
    }

    public extension UITapGestureRecognizer {
        /// Initializes the gesture recognizer with the specified action handler.
        convenience init(action: @escaping ActionBlock) {
            self.init()
            actionBlock = action
        }
    }

    #if os(iOS)
        public extension UIPinchGestureRecognizer {
            /// Initializes the gesture recognizer with the specified action handler.
            convenience init(action: @escaping ActionBlock) {
                self.init()
                actionBlock = action
            }
        }

        public extension UIRotationGestureRecognizer {
            /// Initializes the gesture recognizer with the specified action handler.
            convenience init(action: @escaping ActionBlock) {
                self.init()
                actionBlock = action
            }
        }

        public extension UIHoverGestureRecognizer {
            /// Initializes the gesture recognizer with the specified action handler.
            convenience init(action: @escaping ActionBlock) {
                self.init()
                actionBlock = action
            }
        } 
    #endif

#endif
