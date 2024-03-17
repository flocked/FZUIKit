//
//  NSButton+.swift
//
//
//  Created by Florian Zand on 25.05.23.
//

#if os(macOS)

    import AppKit
    import FZSwiftUtils
    public extension NSButton {
        /**
         Creates a button with the specified title.
         
         - Parameters:
            - title: The title of the button.
            - type: The bezel style of the button.
            - action: The action of the button.
         */
        convenience init(_ title: String, type: BezelStyle = .push, action: ActionBlock? = nil) {
            self.init(title: title, target: nil, action: nil)
            self.bezelStyle = type
            self.actionBlock = action
        }
        
        /**
         Creates a button with the specified image.
         
         - Parameters:
            - title: The title of the button.
            - image: The image of the button.
            - type: The bezel style of the button.
            - action: The action of the button.
         */
        convenience init(_ title: String? = nil, image: NSImage, type: BezelStyle? = nil, action: ActionBlock? = nil) {
            self.init(title: title ?? "", target: nil, action: nil)
            self.image = image
            if let type = type {
                self.bezelStyle = type
            } else if title == nil  {
                self.bezelStyle = .smallSquare
                self.isBordered = false
                self.isTransparent = true
            }
            self.actionBlock = action
        }
        
        /**
         Creates a checkbox button with the specified title.
         
         - Parameters:
            - title: The title of the button.
            - action: The action of the button.
         */
        convenience init(checkbox title: String, action: ActionBlock? = nil) {
            self.init(checkboxWithTitle: title, target: nil, action: nil)
            self.actionBlock = action
        }
        
        /**
         Creates a radio button with the specified title.
         
         - Parameters:
            - title: The title of the button.
            - action: The action of the button.
         */
        convenience init(radio title: String, action: ActionBlock? = nil) {
            self.init(radioButtonWithTitle: title, target: nil, action: nil)
            self.actionBlock = action
        }
        
        /// The button type which affects its user interface and behavior when clicked.
        var buttonType: ButtonType {
            get {
                if let rawValue: UInt = cell?.value(forKey: "_buttonType") as? UInt, let buttonType = NSButton.ButtonType(rawValue: rawValue) {
                    return buttonType
                }
                return .momentaryPushIn
            }
            set { setButtonType(newValue) }
        }
        
        /// The button type which affects its user interface and behavior when clicked.
        @discardableResult
        func buttonType(_ type: ButtonType) -> Self {
            self.buttonType = type
            return self
        }

        /**
         Sets the content tint color to use for the specified state.

         If a color is not specified for a state, it defaults to the contentTintColor value.

         - Parameters:
            - color: The content tint color to use for the specified state.
            - state: The state that uses the specified color. The possible values are described in NSControl.StateValue.
         */
        @discardableResult
        func setContentTintColor(_ color: NSColor?, for state: NSControl.StateValue) -> Self {
            stateContentTintColor[state] = color
            stateContentTintColor[state] = color
            updateButtonStateObserver()
            if self.state == state, let color = color {
                contentTintColor = color
            }
            return self
        }

        /**
         Returns the content tint color used for a state.
         - Parameter state: The state that uses the specified color. The possible values are described in NSControl.StateValue.
         - Returns: The color of the content tint for the specified state.
         */
        func contentTintColor(for state: NSControl.StateValue) -> NSColor? {
            stateContentTintColor[state]
        }

        /**
         Sets the symbol configuration for a button state.

         If a symbol configuration is not specified for a state, it defaults to the symbolConfiguration value.

         - Parameters:
            - configuration: The symbol configuration for the specified state.
            - state: The state that uses the specified symbol configuration. The possible values are described in NSControl.StateValue.
         */
        @available(macOS 11.0, *)
        @discardableResult
        func setSymbolConfiguration(_ configuration: NSImage.SymbolConfiguration?, for state: NSControl.StateValue) -> Self {
            stateSymbolConfiguration[state] = configuration
            stateSymbolConfiguration[state] = configuration
            updateButtonStateObserver()
            if self.state == state, let configuration = configuration {
                symbolConfiguration = configuration
            }
            return self
        }
        
        /**
         Sets the symbol configuration for a button state.

         If a symbol configuration is not specified for a state, it defaults to the symbolConfiguration value.

         - Parameters:
            - configuration: The symbol configuration for the specified state.
            - state: The state that uses the specified symbol configuration. The possible values are described in NSControl.StateValue.
         */
        @available(macOS 12.0, *)
        @discardableResult
        func setSymbolConfiguration(_ configuration: ImageSymbolConfiguration?, for state: NSControl.StateValue) -> Self {
            stateSymbolConfiguration[state] = configuration?.nsUI()
            updateButtonStateObserver()
            if self.state == state, let configuration = configuration?.nsUI() {
                symbolConfiguration = configuration
            }
            return self
        }

        /**
         Returns the symbol configuration used for a state.
         
         - Returns: The symbol configuration for the specified state.
         */
        @available(macOS 11.0, *)
        func symbolConfiguration(for state: NSControl.StateValue) -> NSImage.SymbolConfiguration? {
            stateSymbolConfiguration[state]
        }

        internal var stateContentTintColor: [NSControl.StateValue: NSColor] {
            get { getAssociatedValue("stateContentTintColor", initialValue: [NSControl.StateValue: NSColor].init()) }
            set { setAssociatedValue(newValue, key: "stateContentTintColor") }
        }

        @available(macOS 11.0, *)
        internal var stateSymbolConfiguration: [NSControl.StateValue: NSImage.SymbolConfiguration] {
            get { getAssociatedValue("stateSymbolConfiguration", initialValue: [NSControl.StateValue: NSImage.SymbolConfiguration].init()) }
            set { setAssociatedValue(newValue, key: "stateSymbolConfiguration") }
        }

        internal var buttonStateObserver: KeyValueObservation? {
            get { getAssociatedValue("buttonStateObserver", initialValue: nil) }
            set { setAssociatedValue(newValue, key: "buttonStateObserver") }
        }

        internal func updateButtonStateObserver() {
            let shouldObserveState: Bool
            if #available(macOS 11.0, *) {
                shouldObserveState = !self.stateContentTintColor.isEmpty || !self.stateSymbolConfiguration.isEmpty
            } else {
                shouldObserveState = !stateContentTintColor.isEmpty
            }

            if shouldObserveState == false {
                if let stateObserver = buttonStateObserver {
                    removeObserver(stateObserver, forKeyPath: "state")
                    buttonStateObserver = nil
                }
            } else {
                if buttonStateObserver == nil {
                    buttonStateObserver = observeChanges(for: \.cell?.state) { [weak self] _, _ in
                        guard let self = self else { return }
                        if let contentTintColor = self.contentTintColor(for: state) {
                            self.contentTintColor = contentTintColor
                        }
                        if #available(macOS 11.0, *) {
                            if let symbolConfiguration = self.symbolConfiguration(for: state) {
                                self.symbolConfiguration = symbolConfiguration
                            }
                        }
                    }
                }
            }
        }
        
        /// Sets the tint color to use for the template image and text content.
        @discardableResult
        func contentTintColor(_ color: NSColor) -> Self {
            self.contentTintColor = color
            return self
        }
        
        /// Sets the title displayed on the button when it’s in an off state.
        @discardableResult
        func title(_ title: String) -> Self {
            self.title = title
            return self
        }
        
        /// Sets the title that the button displays when the button is in an on state.
        @discardableResult
        func alternateTitle(_ title: String) -> Self {
            self.alternateTitle = title
            return self
        }
        
        /// Sets the title that the button displays in an off state, as an attributed string.
        @discardableResult
        func attributedTitle(_ title: NSAttributedString) -> Self {
            self.attributedTitle = title
            return self
        }
        
        /// Sets the title that the button displays as an attributed string when the button is in an on state.
        @discardableResult
        func attributedAlternateTitle(_ title: NSAttributedString) -> Self {
            self.attributedAlternateTitle = title
            return self
        }
        
        /// Sets the symbol configuration for the image.
        @available(macOS 11.0, *)
        @discardableResult
        func symbolConfiguration(_ symbolConfiguration: NSImage.SymbolConfiguration?) -> Self {
            self.symbolConfiguration = symbolConfiguration
            return self
        }
        
        /// Sets the symbol configuration for the image.
        @available(macOS 12.0, *)
        @discardableResult
        func symbolConfiguration(_ symbolConfiguration: ImageSymbolConfiguration?) -> Self {
            self.symbolConfiguration = symbolConfiguration?.nsUI()
            return self
        }
        
        /// Sets the Boolean value that indicates whether spring loading is enabled for the button.
        @discardableResult
        func isSpringLoaded(_ isSpringLoaded: Bool) -> Self {
            self.isSpringLoaded = isSpringLoaded
            return self
        }
        
        /// Sets the value indicating the maximum pressure level for a button of type NSMultiLevelAcceleratorButton`.
        @discardableResult
        func maxAcceleratorLevel(_ level: Int) -> Self {
            maxAcceleratorLevel = level
            return self
        }
        
        /// Sets the sound that plays when the user clicks the button.
        @discardableResult
        func sound(_ sound: NSSound?) -> Self {
            self.sound = sound
            return self
        }
        
        /// Sets the image that appears on the button when it’s in an off state, or nil if there is no such image.
        @discardableResult
        func image(_ image: NSImage?) -> Self {
            self.image = image
            return self
        }
        
        /// Sets the symbol image that appears on the button when it’s in an off state, or nil if there is no such image.
        @available(macOS 11.0, *)
        @discardableResult
        func symbolImage(_ symbolName: String) -> Self {
            self.image = NSImage(systemSymbolName: symbolName)
            return self
        }
        
        /// Sets the alternate image that appears on the button when the button is in an on state.
        @discardableResult
        func alternateImage(_ image: NSImage?) -> Self {
            self.alternateImage = image
            return self
        }
        
        /// Sets the alternate symbol image that appears on the button when the button is in an on state.
        @available(macOS 11.0, *)
        @discardableResult
        func alternateSymbolImage(_ symbolName: String) -> Self {
            self.alternateImage = NSImage(systemSymbolName: symbolName)
            return self
        }
        
        /// Sets the position of the button’s image relative to its title.
        @discardableResult
        func imagePosition(_ position: NSControl.ImagePosition) -> Self {
            imagePosition = position
            return self
        }
        
        /// Sets the color of the button's bezel, in appearances that support it.
        @discardableResult
        func bezelColor(_ color: NSColor?) -> Self {
            bezelColor = color
            return self
        }
        
        /// Sets the appearance of the button’s border.
        @discardableResult
        func bezelStyle(_ style: NSButton.BezelStyle) -> Self {
            bezelStyle = style
            return self
        }
        
        /// Sets the Boolean value that determines whether the button has a border.
        @discardableResult
        func isBordered(_ isBordered: Bool) -> Self {
            self.isBordered = isBordered
            return self
        }
        
        /// Sets the Boolean value that indicates whether the button is transparent.
        @discardableResult
        func isTransparent(_ isTransparent: Bool) -> Self {
            self.isTransparent = isTransparent
            return self
        }
        
        /// Sets the Boolean value that determines whether the button displays its border only when the pointer is over it.
        @discardableResult
        func showsBorderOnlyWhileMouseInside(_ showsBorder: Bool) -> Self {
            self.showsBorderOnlyWhileMouseInside = showsBorder
            return self
        }
        
        /// Sets the Boolean value that determines how the button’s image and title are positioned together within the button bezel.
        @discardableResult
        func imageHugsTitle(_ imageHugsTitle: Bool) -> Self {
            self.imageHugsTitle = imageHugsTitle
            return self
        }
        
        /// Sets the scaling mode applied to make the cell’s image fit the frame of the image view.
        @discardableResult
        func imageScaling(_ imageScaling: NSImageScaling) -> Self {
            self.imageScaling = imageScaling
            return self
        }
        
        /// Sets the Boolean value that indicates whether the button allows a mixed state.
        @discardableResult
        func allowsMixedState(_ allowsMixedState: Bool) -> Self {
            self.allowsMixedState = allowsMixedState
            return self
        }
        
        /// Sets the button’s state.
        @discardableResult
        func state(_ state: NSControl.StateValue) -> Self {
            self.state = state
            return self
        }
        
        /// Sets the key-equivalent character of the button.
        @discardableResult
        func keyEquivalent(_ keyEquivalent: String) -> Self {
            self.keyEquivalent = keyEquivalent
            return self
        }
        
        /// Sets the mask specifying the modifier keys for the button’s key equivalent.
        @discardableResult
        func keyEquivalentModifierMask(_ modifierMask: NSEvent.ModifierFlags) -> Self {
            keyEquivalentModifierMask = modifierMask
            return self
        }
    }

#endif
