//
//  ContentConfigurationView.swift
//
//
//  Created by Florian Zand on 03.04.24.
//

#if os(macOS)

import AppKit

/// A view that displays a content configuration.
open class ContentConfigurationView: NSView {
    
    /**
     Creates a content configuration view with the specified configuration.
     
     - Parameter configuration: The content configuration.
     */
    public init(configuration: NSContentConfiguration) {
        super.init(frame: .zero)
        sharedInit()
        self.contentConfiguration = configuration
        setupConfiguration()
    }
    
    /// Creates a content configuration view.
    public init() {
        super.init(frame: .zero)
        sharedInit()
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
    open var automaticallyUpdatesContentConfiguration: Bool = true
    
    /**
     The current configuration state of the view.

     To add your own custom state, see `NSConfigurationStateCustomKey`.
     */
    open var configurationState: NSViewConfigurationState {
        NSViewConfigurationState.init(isSelected: isSelected, isEnabled: isEnabled, isHovered: isHovered, isEditing: isEditing, isEmphasized: isEmphasized, customStates: [:])
        // NSViewConfigurationState.init(isSelected: false, isEnabled: true, isHovered: isHovered, isEditing: false, isEmphasized: isEmphasized, customStates: [:])
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
            setNeedsUpdateConfiguration()

        }
    }
    
    /**
     The emphasized state of the view.

     The value of this property is `true`, if it's window is key.
     */
    open var isEmphasized: Bool {
        window?.isKeyWindow ?? false
    }
    
    /**
     The hovering state of the view.

     The value of this property is `true`, if the mouse is hovering the view.
     */
    open internal(set) var isHovered: Bool = false {
        didSet {
            guard oldValue != isHovered else { return }
            setNeedsAutomaticUpdateConfiguration()
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
    
    /// The focusing state of the view.
    open var isFocused: Bool = false {
        didSet {
            guard oldValue != isFocused else { return }
            setNeedsAutomaticUpdateConfiguration()
        }
    }

    /// The expanding state of the view.
    open var isExpanded: Bool = false {
        didSet {
            guard oldValue != isExpanded else { return }
            setNeedsAutomaticUpdateConfiguration()
        }
    }
    
    func setupConfiguration() {
        if let configuration = contentConfiguration {
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
    
    var contentView: (NSView & NSContentView)?
    
    func setNeedsAutomaticUpdateConfiguration() {
        if automaticallyUpdatesContentConfiguration {
            setNeedsUpdateConfiguration()
        } else {
            configurationUpdateHandler?(self, configurationState)
        }
    }
    
    func sharedInit() {
        trackingArea = TrackingArea(for: self, options: [.mouseEnteredAndExited, .activeInActiveApp])
        trackingArea?.update()
        windowHandlers.isKey = { [weak self] isKey in
            guard let self = self else { return }
            self.setNeedsAutomaticUpdateConfiguration()
        }
    }
    
    public override func updateTrackingAreas() {
        super.updateTrackingAreas()
        trackingArea?.update()
    }
    
    public override func mouseEntered(with event: NSEvent) {
        super.mouseEntered(with: event)
        isHovered = true
    }
    
    public override func mouseExited(with event: NSEvent) {
        super.mouseExited(with: event)
        isHovered = false
    }
    
    var trackingArea: TrackingArea?
    
    required public init?(coder: NSCoder) {
        super.init(coder: coder)
    }
}

#endif
