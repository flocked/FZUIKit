//
//  ContentConfigurationView.swift
//
//
//  Created by Florian Zand on 03.04.24.
//

#if os(macOS)

import AppKit
import FZSwiftUtils

/// A view that displays a content configuration.
open class ContentConfigurationView: NSView {
    
    private var contentView: (NSView & NSContentView)?
    private var trackingArea: TrackingArea?
    private var firstResponderObservation: KeyValueObservation?
    private var appearanceObservation: KeyValueObservation?
    private var _isDescendantFirstResponder = false

    /**
     Creates a content configuration view with the specified configuration.
     
     - Parameter configuration: The content configuration.
     */
    public init(configuration: NSContentConfiguration) {
        super.init(frame: .zero)
        self.contentConfiguration = configuration
        setupConfiguration()
    }
    
    /// Creates a content configuration view.
    public init() {
        super.init(frame: .zero)
    }
    
    /// The current content configuration of the view.
    open var contentConfiguration: NSContentConfiguration? {
        didSet { setupConfiguration() }
    }
    
    /**
     A Boolean value that determines whether the view automatically updates its content configuration when its state changes.

     When this value is `true`, the view automatically calls `updated(for:)` on its ``contentConfiguration`` when the view’s ``configurationState`` changes, and applies the updated configuration back to the view. The default value is `true`.

     If you override ``updateConfiguration(using:)`` to manually update and customize the content configuration, disable automatic updates by setting this property to `false`.
     */
    open var automaticallyUpdatesContentConfiguration: Bool = false {
        didSet { setupObservation() }
    }
    
    /**
     The current configuration state of the view.

     To add your own custom state, see `NSConfigurationStateCustomKey`.
     */
    open var configurationState: NSViewConfigurationState {
        .init(isSelected: isSelected, isEnabled: isEnabled, isHovered: isHovered, isEditing: isEditing, activeState: activeState, appearance: effectiveAppearance)
    }
    
    /**
     Informs the view to update its configuration for its current state.

     You call this method when you need the view to update its configuration according to the current configuration state. The system calls this method automatically when the view’s ``configurationState`` changes, as well as in other circumstances that may require an update. The system might combine multiple requests into a single update.

     If you add custom states to the view’s configuration state, make sure to call this method every time those custom states change.
     */
    @objc open func setNeedsUpdateConfiguration() {
        updateConfiguration(using: configurationState)
    }
    
    /**
     Updates the view’s configuration using the current state.

     Avoid calling this method directly. Instead, use ``setNeedsUpdateConfiguration()`` to request an update.

     Override this method in a subclass to update the view’s configuration using the provided state.
     */
    @objc open func updateConfiguration(using state: NSViewConfigurationState) {
        if let contentView = contentView, let configuration = contentConfiguration {
            contentView.configuration = configuration.updated(for: state)
        }
        configurationUpdateHandler?(self, state)
    }
    
    /**
     The type of block for handling updates to the view’s configuration using the current state.

     - Parameters:
        - view: The view to configure.
        - state: The new state to use for updating the view’s configuration.
     */
    public typealias ConfigurationUpdateHandler = (_ view: NSView, _ state: NSViewConfigurationState) -> Void
    
    /**
     A block for handling updates to the view’s configuration using the current state.

     A configuration update handler provides an alternative approach to overriding ``updateConfiguration(using:)`` in a subclass. Set a configuration update handler to update the view’s configuration using the new state in response to a configuration state change:

     ```swift
     view.configurationUpdateHandler = { view, state in
     var content = NSListContentConfiguration.sidebar().updated(for: state)
     content.text = "Hello world!"
     if state.isDisabled {
     content.textProperties.color = .systemGray
     }
     view.contentConfiguration = content
     }
     ```

     Setting the value of this property calls ``setNeedsUpdateConfiguration()``.
     */
    @objc open var configurationUpdateHandler: ConfigurationUpdateHandler? = nil {
        didSet {
            setupObservation()
            setNeedsUpdateConfiguration()
        }
    }
    
    /// The selection state of the view.
    open var isSelected: Bool = true {
        didSet {
            guard oldValue != isSelected else { return }
            setNeedsAutomaticUpdateConfiguration()
        }
    }
    
    /// The enable state of the view.
    open var isEnabled: Bool = true {
        didSet {
            guard oldValue != isEnabled else { return }
            setNeedsAutomaticUpdateConfiguration()
        }
    }
    
    /// The editing state of the view.
    open var isEditing: Bool = false {
        didSet {
            guard oldValue != isEditing else { return }
            setNeedsAutomaticUpdateConfiguration()
        }
    }
    
    /// The active state of the view.
    private var activeState: NSViewConfigurationState.ActiveState {
        if isObserving {
            return window?.isKeyWindow == true ? _isDescendantFirstResponder ? .focused : .active : .inactive
        }
        return window?.isKeyWindow == true ? isDescendantFirstResponder ? .focused : .active : .inactive
    }

    /**
     The hovering state of the view.

     The value of this property is `true`, if the mouse is hovering the view.
     */
    private var isHovered: Bool {
        get { isObserving ? _isHovered : NSApp.isActive && bounds.contains(mouseLocationOutsideOfEventStream) }
        set {
            guard newValue != isHovered else { return }
            _isHovered = newValue
            setNeedsAutomaticUpdateConfiguration()
        }
    }
    
    private var _isHovered = false
    
    private func setupConfiguration() {
        if var configuration = contentConfiguration {
            if automaticallyUpdatesContentConfiguration {
                configuration = configuration.updated(for: configurationState)
            }
            if let contentView = contentView, contentView.supports(configuration) {
                contentView.configuration = configuration
            } else {
                contentView?.removeFromSuperview()
                contentView = configuration.makeContentView()
                addSubview(withConstraint: contentView!)
            }
        } else {
            contentView?.removeFromSuperview()
            contentView = nil
        }
    }

    private func setNeedsAutomaticUpdateConfiguration() {
        if automaticallyUpdatesContentConfiguration {
            setNeedsUpdateConfiguration()
        } else {
            configurationUpdateHandler?(self, configurationState)
        }
    }
    
    private var isObserving: Bool {
        automaticallyUpdatesContentConfiguration == true || configurationUpdateHandler != nil
    }
    
    private func setupObservation() {
        if !isObserving {
            trackingArea = nil
            windowHandlers.isKey = nil
            firstResponderObservation = nil
            appearanceObservation = nil
        } else if trackingArea == nil {
            _isDescendantFirstResponder = isDescendantFirstResponder
            _isHovered = NSApp.isActive && bounds.contains(mouseLocationOutsideOfEventStream)
            trackingArea = TrackingArea(for: self, options: [.mouseEnteredAndExited, .activeInActiveApp])
            trackingArea?.update()
            windowHandlers.isKey = { [weak self] isKey in
                guard let self = self else { return }
                setNeedsAutomaticUpdateConfiguration()
            }
            firstResponderObservation = observeChanges(for: \.window?.firstResponder) { [weak self] oldValue, newValue in
                guard let self = self else { return }
                let isFirstResponder = self.isDescendantFirstResponder
                guard self._isDescendantFirstResponder != isFirstResponder else { return }
                self._isDescendantFirstResponder = isFirstResponder
                guard self.window?.isKeyWindow == true else { return }
                setNeedsAutomaticUpdateConfiguration()
            }
            appearanceObservation = observeChanges(for: \.effectiveAppearance) { [weak self] _, _ in
                self?.setNeedsAutomaticUpdateConfiguration()
            }
        }
    }
    
    open override func updateTrackingAreas() {
        super.updateTrackingAreas()
        trackingArea?.update()
    }
    
    open override func mouseEntered(with event: NSEvent) {
        super.mouseEntered(with: event)
        isHovered = true
    }
    
    open override func mouseExited(with event: NSEvent) {
        super.mouseExited(with: event)
        isHovered = false
    }
        
    required public init?(coder: NSCoder) {
        super.init(coder: coder)
    }
}

#endif
