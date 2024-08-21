//
//  NSButton+ConfigurationState.swift
//  NSButtonConf
//
//  Created by Florian Zand on 29.06.23.
//

#if os(macOS)
    import AppKit

    @available(macOS 13.0, *)
    public extension NSButton {
        /// The state of a `NSButton`.
        struct ConfigurationState {
            /// The state of the button.
            public var state: StateValue = .off

            /// A Boolean value that indicates whether the button is enabked and reacts to mouse events.
            public var isEnabled: Bool = false

            /// A Boolean value that indicates whether the mouse is hovering the button.
            public var isHovered: Bool = false

            /// A Boolean value that indicates whether the button is pressed down.
            public var isPressed: Bool = false

            init(state: StateValue, isEnabled: Bool, isHovered: Bool, isPressed: Bool) {
                self.state = state
                self.isHovered = isHovered
                self.isEnabled = isEnabled
                self.isPressed = isPressed
            }
        }
    }

#endif
