//
//  NSButton+Configuration.swift
//  NobraControl
//
//  Created by Florian Zand on 29.06.23.
//

#if os(macOS)

import AppKit
import FZSwiftUtils
import SwiftUI

/// A type that provides configuration that specifies the appearance and behavior of a button and its contents.
@available(macOS 13.0, *)
public protocol NSButtonConfiguration { }

@available(macOS 13.0, *)
extension NSButton {
    /**
     The configuration for the button’s appearance.
     
     Setting a configuration opts the button into a configuration system based on ``NSButtonConfiguration``.
     
     There are two types of configurations you can assign:
     - ``Configuration`` which provides standard macOS styling (like the default push button).
     - ``AdvanceConfiguration`` which supports several options and behaviors unavailable with other configuration methods. Features include subtitle labels, extended control over shape, color and more.
     
     ```swift
     var configuration: NSButton.Configuration = .tinted(color: .systemBlue)
     configuration.title = "The Title"
     configuration.subtitle = "Subtitle"
     configuration.image = NSImage(systemSymbolName: "photo")
     
     button.configuration = configuration
     ```
     */
    public var configuration: NSButtonConfiguration? {
        get { getAssociatedValue("configuration") }
        set {
            setAssociatedValue(newValue, key: "configuration")
            updateConfiguration()
            setupConfigurationStateObserver()
        }
    }
    
    /**
     A Boolean value that determines whether the button configuration changes when button’s state changes.
     
     Set this property to true to have the button call `updated(for:)` when the button state changes and apply the changes to the button. The default value is true.
     */
    public var automaticallyUpdatesConfiguration: Bool {
        get { getAssociatedValue("automaticallyUpdatesConfiguration", initialValue: true) }
        set {
            setAssociatedValue(newValue, key: "automaticallyUpdatesConfiguration")
            setupConfigurationStateObserver()
        }
    }
    
    func setupConfigurationStateObserver() {
        if (automaticallyUpdatesConfiguration && configuration is AdvanceConfiguration) || configurationUpdateHandler != nil {
            buttonObserver.add(\.state) { [weak self] old, new in
                guard let self = self else { return }
                self.updateConfigurationAutomatically()
            }
            buttonObserver.add(\.isEnabled) { [weak self] old, new in
                guard let self = self else { return }
                self.updateConfigurationAutomatically()
            }
            mouseHandlers.isHovering = { [weak self] isHovering in
                guard let self = self else { return }
                self.isHovered = isHovering
            }
            windowHandlers.isKey = { [weak self] isKey in
                guard let self = self else { return }
                self.updateConfigurationAutomatically()
            }
            updateConfigurationAutomatically()
        } else {
            buttonObserver.removeAll()
            mouseHandlers.isHovering = nil
            windowHandlers.isKey = nil
        }
    }
    
    var isHovered: Bool {
        get { getAssociatedValue("isHovered", initialValue: false) }
        set {
            guard newValue != isHovered else { return }
            setAssociatedValue(newValue, key: "isHovered")
            if automaticallyUpdatesConfiguration {
                updateConfiguration()
            }
            configurationUpdateHandler?(self, configurationState)
        }
    }
    
    func updateConfigurationAutomatically() {
        if automaticallyUpdatesConfiguration {
            updateConfiguration()
        }
        configurationUpdateHandler?(self, configurationState)
    }
    
    var configurationState: ControlConfigurationState {
        ControlConfigurationState(state: .init(rawValue: state.rawValue)!, isEnabled: isEnabled, isHovered: isHovered, isPressed: isPressed, activeState: window?.isKeyWindow == true ? .active : .inactive)
    }
    
    /**
     Requests the system update the button configuration.
     
     Call this method to make the system call ``updateConfiguration()``. The system calls this method automatically when the button’s state changes. If you call this method multiple times before the system calls `updateConfiguration()`, the system calls `updateConfiguration() once.
     */
    public func setNeedsUpdateConfiguration() {
        updateConfiguration()
    }
    
    /**
     Updates button configuration in response to button state change.
     
     Override this method in your subclass to respond changes to the button’s state. Make any necessary changes and update the button’s configuration.
     
     Don’t call this method directly. Call ``setNeedsUpdateConfiguration()`` to request an update to your button.
     */
    @objc open func updateConfiguration() {
        if let configuration = configuration as? Configuration {
            contentView = nil
            isBordered = true
            bezelStyle = configuration.type.bezel
            setButtonType(configuration.type.buttonType)
            if let attributedTitle = configuration.attributedTitle {
                self.attributedTitle = attributedTitle
                attributedAlternateTitle = attributedTitle
            } else {
                title = configuration.title ?? ""
                alternateTitle = configuration.title ?? ""
            }
            image = configuration.image
            alternateImage = nil
            imagePosition = configuration.imagePosition
            symbolConfiguration = configuration.imageSymbolConfiguration?.nsSymbolConfiguration()
            bezelColor = configuration.resolvedBorderColor()
            contentTintColor = configuration.resolvedContentTintColorColor()
            sound = configuration.sound
            sizeToFit()
        } else if var configuration = configuration as? AdvanceConfiguration {
            if automaticallyUpdatesConfiguration {
                configuration = configuration.updated(for: configurationState)
            }
            bezelStyle = .rounded
            isBordered = false
            alternateTitle = ""
            title = ""
            alternateImage = nil
            symbolConfiguration = nil
            bezelColor = nil
            contentTintColor = nil
            image = nil
            sound = configuration.sound
            if let contentView = contentView, contentView.supports(configuration) {
                contentView.configuration = configuration
            } else {
                contentView = configuration.makeContentView()
                addSubview(withConstraint: contentView!)
            }
            frame.size = contentView!.fittingSize
        } else {
            contentView = nil
        }
    }
    
    /**
     A closure that executes when the button state changes.
     
     Use this property as an alternative to overriding ``updateConfiguration()``. Set a closure to respond to button state changes by updating the button configuration.
     */
    public var configurationUpdateHandler: ConfigurationUpdateHandler? {
        get { getAssociatedValue("NSButton_configurationUpdateHandler") }
        set {
            setAssociatedValue(newValue, key: "NSButton_configurationUpdateHandler")
            setupConfigurationStateObserver()
            setNeedsUpdateConfiguration()
        }
    }
    
    /**
     A closure to update the configuration of a button.
     
     - Parameter state: The current state of the button.
     */
    public typealias ConfigurationUpdateHandler = (_ button: NSButton, _ state: ControlConfigurationState) -> Void
    
    var isPressed: Bool {
        (contentView as? NSButton.AdvanceButtonView)?.isPressed ?? false
    }
    
    var contentView: (NSView & NSContentView)? {
        get { getAssociatedValue("NSButton_contentView") }
        set {
            contentView?.removeFromSuperview()
            setAssociatedValue(newValue, key: "NSButton_contentView")
        }
    }
}

#endif
