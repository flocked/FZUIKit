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
            get { getAssociatedValue(key: "NSButton_Configuration", object: self, initialValue: nil) }
            set {
                let oldValue = self.configuration
                set(associatedValue: newValue, key: "NSButton_Configuration", object: self)
                if newValue is NSButton.AdvanceButtonConfiguration == false {
                    contentView?.removeFromSuperview()
                    contentView = nil
                }
                guard newValue != nil else { return }

                if let oldValue = oldValue as? NSButton.AdvanceButtonConfiguration, let newValue = newValue as? NSButton.AdvanceButtonConfiguration, newValue == oldValue {
                    return
                } else if let oldValue = oldValue as? NSButton.Configuration, let newValue = newValue as? NSButton.Configuration, newValue == oldValue {
                    return
                }

                updateConfiguration()
                if automaticallyUpdatesConfiguration == true, newValue != nil {
                    setupConfigurationStateObserver()
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
                setupConfigurationStateObserver()
            }
        }

        var keyValueObserver: KeyValueObserver<NSButton>? {
            get { getAssociatedValue(key: "keyValueObserver", object: self, initialValue: nil) }
            set { set(associatedValue: newValue, key: "keyValueObserver", object: self) }
        }

        func setupConfigurationStateObserver() {
            if automaticallyUpdatesConfiguration == true || configurationUpdateHandler != nil {
                if keyValueObserver == nil {
                    keyValueObserver = KeyValueObserver(self)
                    keyValueObserver?.add(\.state) { [weak self] old, new in
                        guard let self = self, old != new else { return }
                        if self.automaticallyUpdatesConfiguration {
                            self.updateConfiguration()
                        }
                        self.configurationUpdateHandler?(self.configurationState)
                    }
                    keyValueObserver?.add(\.isEnabled) { [weak self] old, new in
                        guard let self = self, old != new else { return }
                        if self.automaticallyUpdatesConfiguration {
                            self.updateConfiguration()
                        }
                        self.configurationUpdateHandler?(self.configurationState)
                    }
                    /*
                     keyValueObserver?.add([\.title, \.alternateTitle, \.attributedTitle, \.attributedAlternateTitle, \.image, \.alternateImage], handler: <#T##((PartialKeyPath<NSButton>) -> ())##((PartialKeyPath<NSButton>) -> ())##(_ keyPath: PartialKeyPath<NSButton>) -> ()#>)
                     */
                }
                if mouseHandlers.exited == nil {
                    mouseHandlers.exited = { [weak self] _ in
                        guard let self = self else { return }
                        self.isHovered = false
                    }
                    mouseHandlers.moved = { [weak self] _ in
                        guard let self = self else { return }
                        self.isHovered = true
                    }
                    mouseHandlers.dragged = { [weak self] _ in
                        guard let self = self else { return }
                        self.isHovered = true
                    }
                    mouseHandlers.entered = { [weak self] _ in
                        guard let self = self else { return }
                        self.isHovered = true
                    }
                }
            } else {
                keyValueObserver = nil
                mouseHandlers = .init()
            }
        }

        var isHovered: Bool {
            get { getAssociatedValue(key: "isHovered", object: self, initialValue: false) }
            set {
                guard newValue != self.isHovered else { return }
                set(associatedValue: newValue, key: "isHovered", object: self)
                if automaticallyUpdatesConfiguration {
                    updateConfiguration()
                }
            }
        }

        var configurationState: ConfigurationState {
            ConfigurationState(state: state, isEnabled: isEnabled, isHovered: isHovered, isPressed: isPressed)
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
            if let configuration = configuration as? NSButton.Configuration {
                isBordered = true
                bezelStyle = configuration.style.bezelStyle
                setButtonType(configuration.style.buttonStyle)
                if let attributedTitle = configuration.attributedTitle {
                    self.attributedTitle = attributedTitle
                    attributedAlternateTitle = attributedTitle
                } else {
                    title = configuration.title ?? ""
                    alternateTitle = configuration.title ?? ""
                }
                image = configuration.image
                alternateImage = configuration.image
                imagePosition = configuration.imagePosition
                symbolConfiguration = configuration.imageSymbolConfiguration?.nsSymbolConfiguration()
                bezelColor = configuration._resolvedBorderColor
                contentTintColor = configuration._resolvedContentTintColor
                sound = configuration.sound
                sizeToFit()
            } else if var configuration = configuration as? NSButton.AdvanceButtonConfiguration {
                bezelStyle = .rounded
                isBordered = false
                title = ""
                alternateTitle = ""
                image = nil
                alternateImage = nil
                sound = configuration.sound

                if automaticallyUpdatesConfiguration {
                    configuration = configuration.updated(for: configurationState)
                }

                if let contentView = contentView {
                    contentView.configuration = configuration
                } else {
                    let buttonView = NSButton.AdvanceButtonView(configuration: configuration)
                    contentView = buttonView
                    addSubview(withConstraint: buttonView)
                }
                frame.size = contentView?.fittingSize ?? .zero
            }
            configurationUpdateHandler?(configurationState)
        }

        /**
         A closure that executes when the button state changes.

         Use this property as an alternative to overriding ``updateConfiguration()``. Set a closure to respond to button state changes by updating the button configuration.
         */
        public var configurationUpdateHandler: ConfigurationUpdateHandler? {
            get { getAssociatedValue(key: "NSButton_configurationUpdateHandler", object: self, initialValue: nil) }
            set {
                set(associatedValue: newValue, key: "NSButton_configurationUpdateHandler", object: self)
                setupConfigurationStateObserver()
                setNeedsUpdateConfiguration()
            }
        }

        /**
         A closure to update the configuration of a button.

         - Parameter state: The current state of the button.
         */
        public typealias ConfigurationUpdateHandler = (_ state: ConfigurationState) -> Void

        var contentView: NSButton.AdvanceButtonView? {
            get { getAssociatedValue(key: "NSButton_contentView", object: self, initialValue: nil) }
            set { set(associatedValue: newValue, key: "NSButton_contentView", object: self) }
        }

        var isPressed: Bool {
            contentView?.isPressed ?? false
        }

        func sendAction() {
            guard let action = action, let target = target else { return }
            sendAction(action, to: target)
            sound?.play()
        }
    }

#endif
