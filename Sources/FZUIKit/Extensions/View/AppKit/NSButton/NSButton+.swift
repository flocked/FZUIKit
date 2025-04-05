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
     Creates a push button.
     
     - Parameters:
        - title: The title of the button.
        - image: The image of the button.
     */
    static func push(_ title: String, image: NSImage? = nil) -> Self {
        .button(title, image: image, style: .push)
    }
    
    /**
     Creates a push button.
     
     - Parameter image: The image of the button.
     */
    static func push(_ image: NSImage) -> Self {
        .button("", image: image, style: .push)
    }
    
    /**
     Creates a push button.
     
     - Parameters:
        - title: The title of the button.
        - symbolName: The name of the symbol image.
     */
    @available(macOS 11.0, *)
    static func push(_ title: String? = nil, symbolName: String) -> Self {
        .button(title, symbolName: symbolName, style: .push)
    }
    
    /**
     Creates a push button with a flexible height to accommodate longer text labels or an image.

     - Parameters:
        - title: The title of the button.
        - image: The image of the button.
     */
    static func flexiblePush(_ title: String, image: NSImage? = nil) -> Self {
        .button(title, image: image, style: .flexiblePush)
    }
    
    /**
     Creates a push button with a flexible height to accommodate longer text labels or an image.

     - Parameter image: The image of the button.
     */
    static func flexiblePush(image: NSImage) -> Self {
        .button("", image: image, style: .flexiblePush)
    }
    
    /**
     Creates a push button with a flexible height to accommodate longer text labels or an image.
     
     - Parameters:
        - title: The title of the button.
        - symbolName: The name of the symbol image.
     */
    @available(macOS 11.0, *)
    static func flexiblePush(_ title: String? = nil, symbolName: String) -> Self {
        .button(title, symbolName: symbolName, style: .flexiblePush)
    }
    
    /**
     Creates a button that’s appropriate for a toolbar item.
     
     - Parameters:
        - title: The title of the button.
        - image: The image of the button.
     */
    static func toolbar(_ title: String, image: NSImage? = nil) -> Self {
        .button(title, image: image, style: .toolbar)
    }
    
    /**
     Creates a button that’s appropriate for a toolbar item.

     - Parameter image: The image of the button.
     */
    static func toolbar(_ image: NSImage) -> Self {
        .button("", image: image, style: .toolbar)
    }
    
    /**
     Creates a button that’s appropriate for a toolbar item.
     
     - Parameters:
        - title: The title of the button.
        - symbolName: The name of the symbol image.
     */
    @available(macOS 11.0, *)
    static func toolbar(_ title: String? = nil, symbolName: String) -> Self {
        .button(title, symbolName: symbolName, style: .toolbar)
    }
    
    /**
     Creates a button that’s typically used in the context of an accessory toolbar for buttons that narrow the focus of a search or other operation.
     
     - Parameters:
        - title: The title of the button.
        - symbolName: The name of the symbol image.
     */
    static func accessoryBar(_ title: String, image: NSImage? = nil) -> Self {
        .button(title, image: image, style: .accessoryBar)
    }
    
    /**
     Creates a button that’s typically used in the context of an accessory toolbar for buttons that narrow the focus of a search or other operation.

     - Parameter image: The image of the button.
     */
    static func accessoryBar(_ image: NSImage) -> Self {
        .button("", image: image, style: .accessoryBar)
    }
    
    /**
     Creates a button that’s typically used in the context of an accessory toolbar for buttons that narrow the focus of a search or other operation.
     
     - Parameters:
        - title: The title of the button.
        - symbolName: The name of the symbol image.
     */
    @available(macOS 11.0, *)
    static func accessoryBar(_ title: String? = nil, symbolName: String) -> Self {
        .button(title, symbolName: symbolName, style: .accessoryBar)
    }
    
    /**
     Creates a button that you use for extra actions in an accessory toolbar.
     
     - Parameters:
        - title: The title of the button.
        - image: The image of the button.
     */
    static func accessoryBarAction(_ title: String, image: NSImage? = nil) -> Self {
        .button(title, image: image, style: .accessoryBarAction)
    }
    
    /**
     Creates a button that you use for extra actions in an accessory toolbar.

     - Parameter image: The image of the button.
     */
    static func accessoryBarAction(_ image: NSImage) -> Self {
        .button("", image: image, style: .accessoryBarAction)
    }
    
    /**
     Creates a button that you use for extra actions in an accessory toolbar.
     
     - Parameters:
        - title: The title of the button.
        - symbolName: The name of the symbol image.
     */
    @available(macOS 11.0, *)
    static func accessoryBarAction(_ title: String? = nil, symbolName: String) -> Self {
        .button(title, symbolName: symbolName, style: .accessoryBarAction)
    }
    
    /**
     Creates a round button that displays the specified character.
     
     - Parameter character: The character of the button.
     */
    static func circular(_ character: Character) -> Self {
        .button(String(character), style: .circular)
    }
    
    /**
     Creates a round button that displays the specified image.
     
     - Parameter image: The image of the button.
     */
    static func circular(_ image: NSUIImage) -> Self {
        .button(image: image, style: .circular)
    }
    
    /**
     Creates a round button that displays the specified symbol image.
     
     - Parameter symbolName: The name of the symbol image.
     */
    @available(macOS 11.0, *)
    static func circular(symbolName: String) -> Self {
        .button(symbolName: symbolName, style: .circular)
    }
    
    /**
     Creates a button for displaying additional information.
     
     - Parameters:
        - title: The title of the button.
        - image: The image of the button.
     */
    static func badge(_ title: String, image: NSImage? = nil) -> Self {
        .button(title, image: image, style: .badge)
    }
    
    /**
     Creates a button for displaying additional information.

     - Parameter image: The image of the button.
     */
    static func badge(_ image: NSImage) -> Self {
        .button("", image: image, style: .badge)
    }
    
    /**
     Creates a button for displaying additional information.
     
     - Parameters:
        - title: The title of the button.
        - symbolName: The name of the symbol image.
     */
    @available(macOS 11.0, *)
    static func badge(_ title: String? = nil, symbolName: String) -> Self {
        .button(title, symbolName: symbolName, style: .badge)
    }
    
    /**
     Creates a square bezeled button that displays the specified image.
     
     - Parameters:
        - title: The title of the button.
        - image: The image of the button.
     */
    static func smallSquare(_ title: String, image: NSUIImage? = nil) -> Self {
        .button(title, image: image, style: .smallSquare)
    }
    
    /**
     Creates a square bezeled button that displays the specified image.

     - Parameter image: The image of the button.
     */
    static func smallSquare(_ image: NSImage) -> Self {
        .button("", image: image, style: .smallSquare)
    }
    
    /**
     Creates a square bezeled button that displays the specified symbol image.
     
     - Parameters:
        - title: The title of the button.
        - symbolName: The name of the symbol image.
     */
    @available(macOS 11.0, *)
    static func smallSquare(_ title: String? = nil, symbolName: String) -> Self {
        .button(title, symbolName: symbolName, style: .smallSquare)
    }
    
    /**
     Creates a button with a  button style based on the button’s contents and position within the window.
     
     - Parameters:
        - title: The title of the button.
        - image: The image of the button.
     */
    @available(macOS 14.0, *)
    static func automatic(_ title: String, image: NSImage? = nil) -> Self {
        .button(title, image: image, style: .automatic)
    }
    
    /**
     Creates a button with a  button style based on the button’s contents and position within the window.

     - Parameter image: The image of the button.
     */
    @available(macOS 14.0, *)
    static func automatic(_ image: NSImage) -> Self {
        .button("", image: image, style: .automatic)
    }
    
    /**
     Creates a button with a  button style based on the button’s contents and position within the window.
     
     - Parameters:
        - title: The title of the button.
        - symbolName: The name of the symbol image.
     */
    @available(macOS 14.0, *)
    static func automatic(_ title: String? = nil, symbolName: String) -> Self {
        .button(title, symbolName: symbolName, style: .automatic)
    }
    
    /// Creates a button with a disclosure triangle.
    static var disclosure:  Self {
        .button("", style: .disclosure).buttonType(.onOff)
    }
    
    /// Creates a button with a bezeled disclosure triangle.
    static var pushDisclosure: Self {
        .button("", style: .pushDisclosure).buttonType(.onOff)
    }
    
    /// Creates a button with a question mark, providing the standard help button look.
    static var help: Self {
        .button("", style: .helpButton).buttonType(.onOff)
    }
    
    /*
    /// Creates a push button.
    static var push: NSButton {
        .push("")
    }
    
    /// Creates a push button with a flexible height to accommodate longer text labels or an image.
    static var flexiblePush: NSButton {
        .flexiblePush("")
    }
    
    /// Creates a button that’s appropriate for a toolbar item.
    static var toolbar: NSButton {
        .toolbar("")
    }
    
    /// Creates a button that’s typically used in the context of an accessory toolbar for buttons that narrow the focus of a search or other operation.
    static var accessoryBar: NSButton {
        .accessoryBar("")
    }
    
    /// Creates a button that you use for extra actions in an accessory toolbar.
    static var accessoryBarAction: NSButton {
        .accessoryBarAction("")
    }
    
    /// Creates a button for displaying additional information.
    static var badge: NSButton {
        .badge("")
    }
    
    /// Creates a square bezeled button that displays the specified symbol image.
    static var smallSquare: NSButton {
        .smallSquare("")
    }
    
    /// Creates a button with a  button style based on the button’s contents and position within the window.
    @available(macOS 14.0, *)
    static var automatic: NSButton {
        .automatic("")
    }
    */
    
    /**
     Creates a borderless button that displays the specified image.
     
     - Parameter image: The image of the button.
     */
    static func image(_ image: NSUIImage) -> Self {
        .button(image: image)
    }
    
    /**
     Creates a borderless button that displays the specified symbol image.
     
     - Parameter symbolName: The name of the symbol image.
     */
    @available(macOS 11.0, *)
    static func image(symbolName: String) -> Self {
        .button(symbolName: symbolName)
    }
    
    /**
     Creates a borderless button.
     
     - Parameter title: The title of the button.
     */
    static func borderless(_ title: String) -> Self {
        let button = Self.push(title).isBordered(false)
        button.sizeToFit()
        return button
    }
    
    /**
     Creates a borderless button.
     
     - Parameters:
        - title: The title of the button.
        - image: The image of the button.
     */
    static func borderless(_ title: String, image: NSImage) -> Self {
        let button = Self.push(title, image: image).isBordered(false)
        button.sizeToFit()
        return button
    }
    
    /**
     Creates a borderless button.
     
     - Parameter image: The image of the button.
     */
    static func borderless(_ image: NSImage) -> Self {
        let button = Self.push("", image: image).isBordered(false)
        button.sizeToFit()
        return button
    }
    
    /**
     Creates a borderless button.
     
     - Parameters:
        - title: The title of the button.
        - symbolName: The name of the symbol image.
     */
    @available(macOS 11.0, *)
    static func borderless(_ title: String? = nil, symbolName: String) -> Self {
        let button = Self.push(title, symbolName: symbolName).isBordered(false)
        button.sizeToFit()
        return button
    }
    
    /**
     Creates a check box button.
     
     - Parameters:
        - title: The title of the button.
        - image: The image of the button.
        - isChecked: A Boolean value that indicates whether the checkbox is checked.
     */
    static func checkbox(_ title: String, image: NSImage? = nil, isChecked: Bool = false) -> Self {
        let button = Self(checkboxWithTitle: title, target: nil, action: nil)
        button.image = image
        button.state = isChecked ? .on : .off
        button.sizeToFit()
        return button
    }
    
    /**
     Creates a check box button.
     
     - Parameters:
        - image: The image of the button.
        - isChecked: A Boolean value that indicates whether the checkbox is checked.
     */
    static func checkbox(_ image: NSImage, isChecked: Bool = false) -> Self {
        let button = Self(checkboxWithTitle: "", target: nil, action: nil)
        button.image = image
        button.state = isChecked ? .on : .off
        button.sizeToFit()
        return button
    }
    
    /**
     Creates a check box button.
     
     - Parameters:
        - title: The title of the button.
        - symbolName: The name of the symbol image.
        - isChecked: A Boolean value that indicates whether the checkbox is checked.
     */
    @available(macOS 11.0, *)
    static func checkbox(_ title: String? = nil, symbolName: String, isChecked: Bool = false) -> Self {
        checkbox(title ?? "", image: NSImage(systemSymbolName: symbolName), isChecked: isChecked)
    }
    
    /**
     Creates a radio button.
     
     - Parameters:
        - title: The title of the button.
        - image: The image of the button.
        - isSelected: A Boolean value that indicates whether the radio is is selected.
     */
    static func radio(_ title: String, image: NSImage? = nil, isSelected: Bool = false) -> Self {
        let button = Self(radioButtonWithTitle: title, target: nil, action: nil)
        button.image = image
        button.state = isSelected ? .on : .off
        button.sizeToFit()
        return button
    }
    
    /**
     Creates a radio button.
     
     - Parameters:
        - image: The image of the button.
        - isSelected: A Boolean value that indicates whether the radio is is selected.
     */
    static func radio(_ image: NSImage, isSelected: Bool = false) -> Self {
        let button = Self(radioButtonWithTitle: "", target: nil, action: nil)
        button.image = image
        button.state = isSelected ? .on : .off
        button.sizeToFit()
        return button
    }
    
    /**
     Creates a radio button.
     
     - Parameters:
        - title: The title of the button.
        - symbolName: The name of the symbol image.
        - isSelected: A Boolean value that indicates whether the radio is is selected.
     */
    @available(macOS 11.0, *)
    static func radio(_ title: String? = nil, symbolName: String, isSelected: Bool = false) -> Self {
        radio(title ?? "", image: NSImage(systemSymbolName: symbolName), isSelected: isSelected)
    }
    
    /// The button type which affects its user interface and behavior when clicked.
    var buttonType: ButtonType {
        get {
            if let rawValue: UInt = cell?.value(forKey: "_buttonType") as? UInt, let buttonType = ButtonType(rawValue: rawValue) {
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
        - state: The state that uses the specified color.
     */
    @discardableResult
    func setContentTintColor(_ color: NSColor?, for state: StateValue) -> Self {
        stateContentTintColor[state] = color
        stateContentTintColor[state] = color
        updateButtonStateObserver()
        if self.state == state, let color = color {
            contentTintColor = color
        }
        return self
    }
    
    /// A Boolean value that indicates whether the button's state is `on`.
    var isToggled: Bool {
        get { state == .on }
        set { state = newValue ? .on : .off }
    }
    
    /// A Boolean value that indicates if the button’s image and text appear “dim” when the button is disabled.
    var dimsWhenDisabled: Bool {
        get { (cell as? NSButtonCell)?.imageDimsWhenDisabled ?? true }
        set { (cell as? NSButtonCell)?.imageDimsWhenDisabled = newValue }
    }
    
    /// Sets the Boolean value that indicates if the button’s image and text appear “dim” when the button is disabled.
    @discardableResult
    func dimsWhenDisabled(_ dims: Bool) -> Self {
        dimsWhenDisabled = dims
        return self
    }
    
    /**
     Returns the content tint color used for a state.
     
     - Parameter state: The state that uses the specified color. The possible values are described in StateValue.
     - Returns: The color of the content tint for the specified state.
     */
    func contentTintColor(for state: StateValue) -> NSColor? {
        stateContentTintColor[state]
    }
    
    /**
     Sets the symbol configuration for a button state.
     
     If a symbol configuration is not specified for a state, it defaults to the symbolConfiguration value.
     
     - Parameters:
        - configuration: The symbol configuration for the specified state.
        - state: The state that uses the specified symbol configuration.
     */
    @available(macOS 11.0, *)
    @discardableResult
    func setSymbolConfiguration(_ configuration: NSImage.SymbolConfiguration?, for state: StateValue) -> Self {
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
        - state: The state that uses the specified symbol configuration.
     */
    @available(macOS 12.0, *)
    @discardableResult
    func setSymbolConfiguration(_ configuration: ImageSymbolConfiguration, for state: StateValue) -> Self {
        stateSymbolConfiguration[state] = configuration.nsUI()
        updateButtonStateObserver()
        if self.state == state {
            symbolConfiguration = configuration.nsUI()
        }
        return self
    }

    /**
     Returns the symbol configuration used for a state.
     
     - Returns: The symbol configuration for the specified state.
     */
    @available(macOS 11.0, *)
    func symbolConfiguration(for state: StateValue) -> NSImage.SymbolConfiguration? {
        stateSymbolConfiguration[state]
    }
    
    internal var stateContentTintColor: [StateValue: NSColor] {
        get { getAssociatedValue("stateContentTintColor", initialValue: [StateValue: NSColor].init()) }
        set { setAssociatedValue(newValue, key: "stateContentTintColor") }
    }
    
    @available(macOS 11.0, *)
    internal var stateSymbolConfiguration: [StateValue: NSImage.SymbolConfiguration] {
        get { getAssociatedValue("stateSymbolConfiguration", initialValue: [StateValue: NSImage.SymbolConfiguration].init()) }
        set { setAssociatedValue(newValue, key: "stateSymbolConfiguration") }
    }
    
    internal var buttonStateObserver: KeyValueObservation? {
        get { getAssociatedValue("buttonStateObserver") }
        set { setAssociatedValue(newValue, key: "buttonStateObserver") }
    }
    
    internal var buttonObserver: KeyValueObserver<NSButton> {
        get { getAssociatedValue("buttonObserver", initialValue: KeyValueObserver(self)) }
    }
    
    internal func updateButtonStateObserver() {
        var shouldObserveState = !stateContentTintColor.isEmpty
        if #available(macOS 11.0, *) {
            shouldObserveState = !self.stateContentTintColor.isEmpty || !self.stateSymbolConfiguration.isEmpty
        }
        
        if !shouldObserveState {
            buttonStateObserver = nil
        } else if buttonStateObserver == nil {
            buttonStateObserver = observeChanges(for: \.state) { [weak self] _, state in
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
    
    /// Sets the tint color to use for the template image and text content.
    @discardableResult
    func contentTintColor(_ color: NSColor) -> Self {
        self.contentTintColor = color
        return self
    }
    
    /// Sets the title displayed on the button when it’s in an off state.
    @discardableResult
    func title(_ title: String?) -> Self {
        self.title = title ?? ""
        return self
    }
    
    /// Sets the title that the button displays when the button is in an on state.
    @discardableResult
    func alternateTitle(_ title: String?) -> Self {
        self.alternateTitle = title ?? ""
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
    
    /// Sets the value indicating the maximum pressure level for a button of type `accelerator`.
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
        if image != nil, imagePosition == .noImage {
            imagePosition = .imageLeft
        }
        return self
    }
    
    /// Sets the symbol image that appears on the button when it’s in an off state, or nil if there is no such image.
    @available(macOS 11.0, *)
    @discardableResult
    func symbolImage(_ symbolName: String) -> Self {
        image(NSImage(systemSymbolName: symbolName))
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
    func state(_ state: StateValue) -> Self {
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
    
    /// Sizes the button to fit it's content with the specified image to title spacing.
    func sizeToFit(imageToTitleSpacing spacing: CGFloat) {
        sizeToFit()
        guard displayingImage != nil, displayingTitle != "" else { return }
        switch imagePosition {
        case .imageAbove, .imageBelow:
            frame.size.height += spacing
        case .imageLeft, .imageRight, .imageLeading, .imageTrailing:
            frame.size.width += spacing
        default: break
        }
    }
    
    internal var displayingTitle: String {
        state == .on && alternateTitle != "" ? alternateTitle : title
    }
    
    internal var displayingImage: NSImage? {
        state == .on ? alternateImage ?? image : image
    }
    
    internal convenience init(_ title: String? = nil, image: NSImage? = nil, style: BezelStyle? = nil) {
        self.init(title: title ?? "", target: nil, action: nil)
        self.image = image
        if image != nil {
            imagePosition = .imageLeading
        }
        if let style = style {
            bezelStyle = style
        } else if title == nil {
            bezelStyle = .smallSquare
            isBordered = false
        }
        sizeToFit(imageToTitleSpacing: 4.0)
    }
    
    static func button(_ title: String? = nil, image: NSImage? = nil, style: BezelStyle? = nil) -> Self {
        let button = Self.init(title: title ?? "", target: nil, action: nil)
        button.image = image
        if image != nil {
            button.imagePosition = .imageLeading
        }
        if let style = style {
            button.bezelStyle = style
        } else if title == nil {
            button.bezelStyle = .smallSquare
            button.isBordered = false
        }
        button.sizeToFit(imageToTitleSpacing: 4.0)
        return button
    }
    
    @available(macOS 11.0, *)
    static func button(_ title: String? = nil, symbolName: String, style: BezelStyle? = nil) -> Self {
        let button = Self.init(title: title ?? "", target: nil, action: nil)
        button.image = NSImage(systemSymbolName: symbolName)
        if button.image != nil {
            button.imagePosition = .imageLeading
        }
        if let style = style {
            button.bezelStyle = style
        } else if title == nil {
            button.bezelStyle = .smallSquare
            button.isBordered = false
        }
        button.sizeToFit(imageToTitleSpacing: 4.0)
        return button
    }
    
    @available(macOS 11.0, *)
    internal convenience init(_ title: String? = nil, symbolName: String, style: BezelStyle? = nil) {
        self.init(title: title ?? "", target: nil, action: nil)
        image = NSImage(systemSymbolName: symbolName)
        if image != nil {
            imagePosition = .imageLeading
        }
        if let style = style {
            bezelStyle = style
        } else if title == nil {
            bezelStyle = .smallSquare
            isBordered = false
        }
        sizeToFit(imageToTitleSpacing: 4.0)
    }
    
    /*
    var autoSizes: Bool {
        get { buttonObserver.isObserving(\.image) }
        set {
            guard newValue != autoSizes else { return }
            if newValue {
                
            } else {
                buttonObserver.remove(\.title)
                buttonObserver.remove(\.image)
            }
        }
    }
    */
}

#endif
