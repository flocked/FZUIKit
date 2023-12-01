//
//  NSButton+Configuration.swift
//  NobraControl
//
//  Created by Florian Zand on 29.06.23.
//

#if os(macOS)

import AppKit
import SwiftUI
import FZSwiftUtils

@available(macOS 13.0, *)
extension NSButton {
    /**
     The configuration for the button’s appearance.
     
     Setting a configuration opts the button into a configuration system based on ``NSButtonConfiguration``.
     
     There are two types of configurations you can assign:
     - ``Configuration-swift.struct`` which provides standard macOS styling (like the default push button).
     - ``ModernConfiguration`` which supports several options and behaviors unavailable with other configuration methods. Features include subtitle labels, extended control over shape, color and more.
     
     When using a configuration, the button ignores other methods and properties of `NSButton`.
     
     If the configuration is `nil`, other supported properties and methods of `NSButton`, such as `title`,  `alternateTitle` and `image` control the apearance of the button.
     */
    public var configuration: NSButtonConfiguration? {
        get { getAssociatedValue(key: "NSButton_Configuration", object: self, initialValue: nil) }
        set {
            let oldValue = self.configuration
            set(associatedValue: newValue, key: "NSButton_Configuration", object: self)
            var needsConfigurationUpdate = true
            if let oldValue = oldValue as? NSButton.ModernConfiguration, let newValue = newValue as? NSButton.ModernConfiguration, newValue == oldValue {
                needsConfigurationUpdate = false
            } else if let oldValue = oldValue as? NSButton.Configuration, let newValue = newValue as? NSButton.Configuration, newValue == oldValue {
                needsConfigurationUpdate = false
            }
            
            if needsConfigurationUpdate {
                self.updateConfiguration()
                
                if self.automaticallyUpdatesConfiguration == true, newValue != nil {
                    setupConfigurationStateObserver()
                }
            }
        }
    }
    
    /**
     A Boolean value that determines whether the button configuration changes when button’s state changes.
     
     Set this property to true to have the button call `updated(for:)` when the button state changes and apply the changes to the button. The default value is true.
     */
    public var automaticallyUpdatesConfiguration: Bool {
        get { getAssociatedValue(key: "NSButton_automaticallyUpdatesConfiguration", object: self, initialValue: true) }
        set {
            set(associatedValue: newValue, key: "NSButton_automaticallyUpdatesConfiguration", object: self)
            self.setupConfigurationStateObserver()
        }
    }
    
    internal var keyValueObserver: KeyValueObserver<NSButton>? {
        get { getAssociatedValue(key: "keyValueObserver", object: self, initialValue: nil) }
        set { set(associatedValue: newValue, key: "keyValueObserver", object: self) }
    }
    
    internal func setupConfigurationStateObserver() {
        if self.automaticallyUpdatesConfiguration == true || configurationUpdateHandler != nil {
            if keyValueObserver == nil {
                keyValueObserver = KeyValueObserver(self)
                keyValueObserver?.add(\.state) { [weak self] old, new in
                    guard let self = self, old != new else { return }
                    self.updateConfiguration()
                    self.configurationUpdateHandler?(self.configurationState)
                }
                keyValueObserver?.add(\.isEnabled) { [weak self] old, new in
                    guard let self = self, old != new else { return }
                    self.updateConfiguration()
                    self.configurationUpdateHandler?(self.configurationState)
                }
                /*
                keyValueObserver?.add([\.title, \.alternateTitle, \.attributedTitle, \.attributedAlternateTitle, \.image, \.alternateImage], handler: <#T##((PartialKeyPath<NSButton>) -> ())##((PartialKeyPath<NSButton>) -> ())##(_ keyPath: PartialKeyPath<NSButton>) -> ()#>)
                 */
            }
            
            if observerView == nil {
                let observerView = ObservingView(frame: .zero)
                observerView.mouseHandlers.exited = { [weak self] event in
                    guard let self = self else { return true }
                    self.isHovered = false
                    return true
                }

                observerView.mouseHandlers.setup([.moved, .dragged, .entered]) { [weak self] event in
                    guard let self = self else { return true }
                    self.isHovered = true
                    return true }
                self.observerView = observerView
                self.addSubview(withConstraint: observerView)
                observerView.sendToBack()
            }
        } else {
            keyValueObserver = nil
            observerView?.removeFromSuperview()
            observerView = nil
        }
    }
    
    internal var isHovered: Bool {
        get { getAssociatedValue(key: "isHovered", object: self, initialValue: false) }
        set {
            guard newValue != self.isHovered else { return }
            set(associatedValue: newValue, key: "isHovered", object: self)
            if (self.automaticallyUpdatesConfiguration) {
                self.updateConfiguration()
            }
        }
    }
    
    internal var configurationState: ConfigurationState {
        ConfigurationState(state: self.state, isEnabled: self.isEnabled, isHovered: self.isHovered)
    }
    
    /**
     Requests the system update the button configuration.
     
     Call this method to make the system call ``updateConfiguration()``. The system calls this method automatically when the button’s state changes. If you call this method multiple times before the system calls `updateConfiguration()`, the system calls `updateConfiguration() once.
     */
    public func setNeedsUpdateConfiguration() {
        self.updateConfiguration()
    }
    
    /**
     Updates button configuration in response to button state change.
     
     Override this method in your subclass to respond changes to the button’s state. Make any necessary changes and update the button’s configuration.
     
     Don’t call this method directly. Call ``setNeedsUpdateConfiguration()`` to request an update to your button.
     */
    @objc open func updateConfiguration() {
        if let configuration = configuration as? NSButton.Configuration {
            self.isBordered = true
            self.bezelStyle = configuration.style.bezelStyle
            self.setButtonType(configuration.style.buttonStyle)
            if let attributedTitle = configuration.attributedTitle {
                self.attributedTitle = attributedTitle
                self.attributedAlternateTitle = attributedTitle
            } else {
                self.title = configuration.title ?? ""
                self.alternateTitle = configuration.title ?? ""
            }
            self.image = configuration.image
            self.alternateImage = configuration.image
            self.imagePosition = configuration.imagePosition
            self.symbolConfiguration = configuration.imageSymbolConfiguration?.nsSymbolConfiguration()
            self.bezelColor = configuration._resolvedBorderColor
            self.contentTintColor = configuration._resolvedContentTintColor
            self.sound = configuration.sound
            self.sizeToFit()
        } else if var configuration = configuration as? NSButton.ModernConfiguration {
            self.bezelStyle = .rounded
            self.isBordered = false
            self.title = ""
            self.alternateTitle = ""
            self.image = nil
            self.alternateImage = nil
            self.sound = configuration.sound
            
            if isEnabled == false {
                configuration.foregroundColorTransformer = .systemEffect(.disabled)
                configuration.backgroundColorTransformer = .systemEffect(.disabled)
            }

            if let modernConfigurationButtonView = self.modernConfigurationButtonView {
                modernConfigurationButtonView.configuration = configuration
            } else {
                let buttonView = NSButton.ModernConfiguration.ButtonView(configuration: configuration)
                self.modernConfigurationButtonView = buttonView
                self.addSubview(withConstraint: buttonView)
            }
            self.frame.size = self.modernConfigurationButtonView?.fittingSize ?? .zero
        }
        self.configurationUpdateHandler?(self.configurationState)
    }
    
    /**
     A closure that executes when the button state changes.
     
     Use this property as an alternative to overriding ``updateConfiguration()``. Set a closure to respond to button state changes by updating the button configuration.
     */
    public var configurationUpdateHandler: ConfigurationUpdateHandler? {
        get { getAssociatedValue(key: "NSButton_configurationUpdateHandler", object: self, initialValue: nil) }
        set {
            set(associatedValue: newValue, key: "NSButton_configurationUpdateHandler", object: self)
            self.setupConfigurationStateObserver()
            self.setNeedsUpdateConfiguration()
        }
    }
    
    /**
     A closure to update the configuration of a button.
     
    - Parameter state: The current state of the button.
     */
    public typealias ConfigurationUpdateHandler  = (_ state: ConfigurationState) -> Void

    
    internal var modernConfigurationButtonView: NSButton.ModernConfiguration.ButtonView? {
        get { getAssociatedValue(key: "NSButton_modernConfigurationButtonView", object: self, initialValue: nil) }
        set {
            set(associatedValue: newValue, key: "NSButton_modernConfigurationButtonView", object: self)
        }
    }
    
    internal var observerView: ObservingView? {
        get { getAssociatedValue(key: "NSButton_observerView", object: self, initialValue: nil) }
        set {
            set(associatedValue: newValue, key: "NSButton_observerView", object: self)
        }
    }
}

#endif
