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
        func test() {
            NSButton.flexiblePush("").state(.on)
        }
        
        /**
         Creates a button with the specified title.
         
         - Parameters:
            - title: The title of the button.
            - style: The bezel style of the button.
            - action: The action of the button.
         */
        convenience init(_ title: String, style: BezelStyle = .push, action: ActionBlock? = nil) {
            self.init(title: title, target: nil, action: nil)
            self.bezelStyle = style
            self.actionBlock = action
        }
        
        /**
         Creates a button with the specified image.
         
         - Parameters:
            - title: The title of the button.
            - image: The image of the button.
            - style: The bezel style of the button.
            - action: The action of the button.
         */
        convenience init(_ title: String? = nil, image: NSImage, style: BezelStyle? = nil, action: ActionBlock? = nil) {
            self.init(title: title ?? "", target: nil, action: nil)
            self.image = image
            if let style = style {
                self.bezelStyle = style
            } else if title == nil {
                self.bezelStyle = .smallSquare
                self.isBordered = false
            }
            self.actionBlock = action
            sizeToFit()
        }
        
        /**
         Creates a button with the specified symbol image.
         
         - Parameters:
            - title: The title of the button.
            - symbolName: The name of the symbol image.
            - style: The bezel style of the button.
            - action: The action of the button.
         */
        @available(macOS 11.0, *)
        convenience init(_ title: String? = nil, symbolName: String, style: BezelStyle? = nil, action: ActionBlock? = nil) {
            self.init(title: title ?? "", target: nil, action: nil)
            self.image = NSImage(systemSymbolName: symbolName)
            if let style = style {
                self.bezelStyle = style
            } else if title == nil {
                self.bezelStyle = .smallSquare
                self.isBordered = false
            }
            actionBlock = action
            sizeToFit()
        }
        
        /**
         Creates a checkbox button.
         
         - Parameters:
            - title: The title of the button.
            - isChecked: A Boolean value that indicates whether the checkbox is checked.
            - action: The action of the button.
         */
        convenience init(checkbox title: String, isChecked: Bool = false, action: ActionBlock? = nil) {
            self.init(checkboxWithTitle: title, target: nil, action: nil)
            self.state = isChecked ? .on : .off
            self.actionBlock = action
        }
        
        /**
         Creates a radio button.
         
         - Parameters:
            - title: The title of the button.
            - isSelected: A Boolean value that indicates whether the radio is selected.
            - action: The action of the button.
         */
        convenience init(radio title: String, isSelected: Bool = false, action: ActionBlock? = nil) {
            self.init(radioButtonWithTitle: title, target: nil, action: nil)
            self.state = isSelected ? .on : .off
            self.actionBlock = action
        }
        
        /**
         Creates a image button.
         
         - Parameter image: The image of the button.
         */
        static func image(_ image: NSUIImage) -> NSButton {
            NSButton(image: image)
        }
        
        /**
         Creates a image button with a symbol image.
         
         - Parameter symbolName: The name of the symbol image.
         */
        @available(macOS 11.0, *)
        static func image(symbolName: String) -> NSButton {
            NSButton(symbolName: symbolName)
        }
        
        /**
         Creates a checkbox button.
         
         - Parameters:
            - title: The title of the button.
            - isChecked: A Boolean value that indicates whether the checkbox is checked.
         */
        static func checkbox(_ title: String, isChecked: Bool = false) -> NSButton {
            NSButton(checkbox: title, isChecked: isChecked)
        }
        
        /**
         Creates a radio button.
         
         - Parameters:
            - title: The title of the button.
            - isSelected: A Boolean value that indicates whether the radio is checked.
         */
        static func radio(_ title: String, isSelected: Bool = false) -> NSButton {
            NSButton(radio: title, isSelected: isSelected)
        }
        
        /**
         Creates a push button.
         
         - Parameter title: The title of the button.
         */
        static func push(_ title: String) -> NSButton {
            NSButton(title).bezelStyle(.rounded)
        }
        
        /**
         Creates a push button.
         
         - Parameters:
            - title: The title of the button.
            - image: The image of the button.
         */
        static func push(_ title: String? = nil, image: NSImage) -> NSButton {
            NSButton(title, image: image, style: .rounded)
        }
        
        /**
         Creates a push button.
         
         - Parameters:
            - title: The title of the button.
            - symbolName: The name of the symbol image.
         */
        @available(macOS 11.0, *)
        static func push(_ title: String? = nil, symbolName: String) -> NSButton {
            NSButton(title ?? "").image(NSImage(systemSymbolName: symbolName)).bezelStyle(.rounded)
        }
        
        /**
         Creates a button with a flexible height to accommodate longer text labels or an image.
         
         - Parameter title: The title of the button.
         */
        static func flexiblePush(_ title: String) -> NSButton {
            NSButton(title).bezelStyle(.regularSquare)
        }
        
        /**
         Creates a push button.
         
         - Parameters:
            - title: The title of the button.
            - image: The image of the button.
         */
        static func flexiblePush(_ title: String? = nil, image: NSImage) -> NSButton {
            NSButton(title, image: image, style: .regularSquare)
        }
        
        /**
         Creates a push button.
         
         - Parameters:
            - title: The title of the button.
            - symbolName: The name of the symbol image.
         */
        @available(macOS 11.0, *)
        static func flexiblePush(_ title: String? = nil, symbolName: String) -> NSButton {
            NSButton(title ?? "").image(NSImage(systemSymbolName: symbolName)).bezelStyle(.regularSquare)
        }
        
        /**
         Creates a button that’s appropriate for a toolbar item.
         
         - Parameter title: The title of the button.
         */
        static func toolbar(_ title: String) -> NSButton {
            NSButton(title).bezelStyle(.texturedRounded)
        }
        
        /**
         Creates a button that’s appropriate for a toolbar item.
         
         - Parameters:
            - title: The title of the button.
            - image: The image of the button.
         */
        static func toolbar(_ title: String? = nil, image: NSImage) -> NSButton {
            NSButton(title ?? "", image: image, style: .texturedRounded)
        }
        
        /**
         Creates a button that’s appropriate for a toolbar item.
         
         - Parameters:
            - title: The title of the button.
            - symbolName: The name of the symbol image.
         */
        @available(macOS 11.0, *)
        static func toolbar(_ title: String? = nil, symbolName: String) -> NSButton {
            NSButton(title ?? "").image(NSImage(systemSymbolName: symbolName)).bezelStyle(.texturedRounded)
        }
        
        /**
         Creates a button that’s typically used in the context of an accessory toolbar for buttons that narrow the focus of a search or other operation.
         
         - Parameter title: The title of the button.
         */
        static func accessoryBar(_ title: String) -> NSButton {
            NSButton(title).bezelStyle(.recessed).buttonType(.pushOnPushOff)
        }
        
        /**
         Creates a button that’s typically used in the context of an accessory toolbar for buttons that narrow the focus of a search or other operation.
         
         - Parameters:
            - title: The title of the button.
            - symbolName: The name of the symbol image.
         */
        static func accessoryBar(_ title: String? = nil, image: NSImage) -> NSButton {
            NSButton(title ?? "", image: image, style: .recessed).buttonType(.pushOnPushOff)
        }
        
        /**
         Creates a button that’s typically used in the context of an accessory toolbar for buttons that narrow the focus of a search or other operation.
         
         - Parameters:
            - title: The title of the button.
            - image: The image of the button.
         */
        @available(macOS 11.0, *)
        static func accessoryBar(_ title: String? = nil, symbolName: String) -> NSButton {
            NSButton(title ?? "").image(NSImage(systemSymbolName: symbolName)).bezelStyle(.recessed).buttonType(.pushOnPushOff)
        }
        
        /**
         Creates a button that you use for extra actions in an accessory toolbar.
         
         - Parameter title: The title of the button.
         */
        static func accessoryBarAction(_ title: String) -> NSButton {
            NSButton(title).bezelStyle(.roundRect)
        }
        
        /**
         Creates a button that you use for extra actions in an accessory toolbar.
         
         - Parameters:
            - title: The title of the button.
            - image: The image of the button.
         */
        static func accessoryBarAction(_ title: String? = nil, image: NSImage) -> NSButton {
            NSButton(title ?? "", image: image, style: .roundRect)
        }
        
        /**
         Creates a button that you use for extra actions in an accessory toolbar.
         
         - Parameters:
            - title: The title of the button.
            - symbolName: The name of the symbol image.
         */
        @available(macOS 11.0, *)
        static func accessoryBarAction(_ title: String? = nil, symbolName: String) -> NSButton {
            NSButton(title ?? "").image(NSImage(systemSymbolName: symbolName)).bezelStyle(.roundRect)
        }
        
        /**
         Creates a round button that displays the specified character.
         
         - Parameter character: The character of the button.
         */
        static func circular(_ character: Character) -> NSButton {
            NSButton(String(character)).bezelStyle(.circular)
        }
        
        /**
         Creates a round button that displays the specified image.
         
         - Parameter image: The image of the button.
         */
        static func circular(_ image: NSUIImage) -> NSButton {
            NSButton(image: image, style: .circular)
        }
        
        /**
         Creates a round button that displays the specified symbol image.
         
         - Parameter symbolName: The name of the symbol image.
         */
        @available(macOS 11.0, *)
        static func circular(symbolName: String) -> NSButton {
            NSButton(symbolName: symbolName, style: .circular)
        }
        
        /**
         Creates a button for displaying additional information.
         
         - Parameter title: The title of the button.
         */
        static func badge(_ title: String) -> NSButton {
            NSButton(title).bezelStyle(.badge)
        }
        
        /**
         Creates a button for displaying additional information.

         - Parameters:
            - title: The title of the button.
            - image: The image of the button.
         */
        static func badge(_ title: String? = nil, image: NSUIImage) -> NSButton {
            NSButton(title, image: image, style: .badge)
        }
        
        /**
         Creates a button for displaying additional information.

         - Parameters:
            - title: The title of the button.
            - symbolName: The name of the symbol image.
         */
        @available(macOS 11.0, *)
        static func badge(_ title: String? = nil, symbolName: String) -> NSButton {
            NSButton(title ?? "").image(NSImage(systemSymbolName: symbolName)).bezelStyle(.badge)
        }
                
        /**
         Creates a square bezeled button that displays the specified character.
         
         - Parameter title: The title of the button.
         */
        static func smallSquare(_ title: String) -> NSButton {
            NSButton(title).bezelStyle(.smallSquare)
        }
        
        /**
         Creates a square bezeled button that displays the specified image.
         
         - Parameters:
            - title: The title of the button.
            - symbolName: The name of the symbol image.
         */
        static func smallSquare(_ title: String? = nil, image: NSUIImage) -> NSButton {
            NSButton(title, image: image, style: .smallSquare)
        }
        
        /**
         Creates a square bezeled button that displays the specified symbol image.
         
         - Parameters:
            - title: The title of the button.
            - image: The image of the button.
         */
        @available(macOS 11.0, *)
        static func smallSquare(_ title: String? = nil, symbolName: String) -> NSButton {
            NSButton(title ?? "").image(NSImage(systemSymbolName: symbolName)).bezelStyle(.smallSquare)
        }
        
        /**
         Creates a button with a  button style based on the button’s contents and position within the window.
         
         - Parameter title: The title of the button.
         */
        @available(macOS 14.0, *)
        static func automatic(_ title: String) -> NSButton {
            NSButton(title).bezelStyle(.automatic)
        }
        
        /**
         Creates a button with a  button style based on the button’s contents and position within the window.
         
         - Parameters:
            - title: The title of the button.
            - image: The image of the button.
         */
        @available(macOS 14.0, *)
        static func automatic(_ title: String? = nil, image: NSImage) -> NSButton {
            NSButton(title, image: image, style: .automatic).image(image)
        }
        
        /**
         Creates a button with a  button style based on the button’s contents and position within the window.
         
         - Parameters:
            - title: The title of the button.
            - symbolName: The name of the symbol image.
         */
        @available(macOS 14.0, *)
        static func automatic(_ title: String? = nil, symbolName: String) -> NSButton {
            NSButton(title ?? "").image(NSImage(systemSymbolName: symbolName)).bezelStyle(.automatic)
        }
        
        /// Creates a button with a disclosure triangle.
        static var disclosure:  NSButton {
            NSButton().buttonType(.onOff).bezelStyle(.disclosure)
        }
        
        /// Creates a button with a bezeled disclosure triangle.
        static var pushDisclosure: NSButton {
            NSButton().buttonType(.onOff).bezelStyle(.roundedDisclosure)
        }
        
        /// Creates a button with a question mark, providing the standard help button look.
        static var help: NSButton {
            NSButton("").bezelStyle(.helpButton)
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
        
        /// Sets the button’s state.
        @discardableResult
        func state(_ isOn: Bool) -> Self {
            self.state = isOn ? .on : .off
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
