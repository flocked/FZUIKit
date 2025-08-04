//
//  NSViewConfigurationState.swift
//
//
//  Created by Florian Zand on 28.12.23.
//

#if os(macOS)
import AppKit
import FZSwiftUtils

/**
 A structure that encapsulates a state for a view.

 A view configuration state encompasses the common states that affect the appearance of the view — states like enabled, selected, or emphasized. You can use it to update the appearance.

 Typically, you don’t create a configuration state yourself. To obtain a configuration state either use the view's `configurationUpdateHandler` or override its `updateConfiguration(using:)` method in a subclass and use the state parameter. Outside of this method, you can get the configuration state by using its `configurationState` property.

 You can create your own custom states to add to a view configuration state by defining a custom state key using `NSConfigurationStateCustomKey`.
 */
public struct NSViewConfigurationState: NSConfigurationState, Hashable {
   
    /// A Boolean value indicating whether the view is selected.
    public var isSelected: Bool = false

    /**
     A Boolean value indicating whether the view is enabled.

     The value of this property is `true`, if it's table view `isEnabled` is `true`.
     */
    public var isEnabled: Bool = true

    /**
     A Boolean value indicating whether the view is in a hovered state.

     The value of this property is `true`, if the mouse is hovering the view.
     */
    public var isHovered: Bool = false

    /// A Boolean value indicating whether the view is in an editing state.
    public var isEditing: Bool = false
    
    /// The active state of the view.
    public var activeState: ActiveState = .inactive
    
    /// The active state of an view.
    public enum ActiveState: Int, Hashable, CustomStringConvertible {
        /// Inactive. The window that displays the view isn't the key window.
        case inactive
        /// Active. The window that displays the view is the key window.
        case active
        /// Active and focused. The view or any of its subviews is focused (first responder).
        case focused
        
        public var description: String {
            switch self {
            case .inactive: return "inactive"
            case .active: return "active"
            case .focused: return "focused"
            }
        }
    }
    
    /// The appearance of the view.
    public var appearance: NSAppearance?
    
    /**
     A Boolean value indicating whether the view is in an emphasized state.

     The value of this property is `true`, if it's window is key.
     */
    var isActive: Bool = false

    /// A Boolean value indicating whether the view is in a focused state.
    var isFocused: Bool = false

    /// A Boolean value indicating whether the view is in an expanded state.
    var isExpanded: Bool = false

    var customStates = [NSConfigurationStateCustomKey: AnyHashable]()

    /// Accesses custom states by key.
    public subscript(key: NSConfigurationStateCustomKey) -> AnyHashable? {
        get { customStates[key] }
        set { customStates[key] = newValue }
    }

    public init(isSelected: Bool = false,
                isEnabled: Bool = true,
                isHovered: Bool = false,
                isEditing: Bool = false,
                activeState: ActiveState = .inactive,
                appearance: NSAppearance? = nil)
    {
        self.isSelected = isSelected
        self.isEnabled = isEnabled
        self.isHovered = isHovered
        self.isEditing = isEditing
        self.activeState = activeState
        self.appearance = appearance
    }

    init(isSelected: Bool,
         isEnabled: Bool,
         isHovered: Bool,
         isEditing: Bool,
         activeState: ActiveState,
         appearance: NSAppearance?,
         customStates: [NSConfigurationStateCustomKey: AnyHashable])
    {
        self.isSelected = isSelected
        self.isEnabled = isEnabled
        self.isHovered = isHovered
        self.isEditing = isEditing
        self.activeState = activeState
        self.appearance = appearance
        self.customStates = customStates
    }
}

extension NSViewConfigurationState: ReferenceConvertible {
    /// The Objective-C type for this state.
    public typealias ReferenceType = __NSViewConfigurationState

    public var description: String {
        """
        NSViewConfigurationState(
            isSelected: \(isSelected)
            isEnabled: \(isEnabled)
            isHovered: \(isHovered)
            isEditing: \(isEditing)
            activeState: \(activeState)
            appearance: \(appearance?.name.rawValue ?? "-")
            customStates: \(customStates)
        )
        """
    }

    public var debugDescription: String {
        description
    }

    public func _bridgeToObjectiveC() -> __NSViewConfigurationState {
        return __NSViewConfigurationState(state: self)
    }

    public static func _forceBridgeFromObjectiveC(_ source: __NSViewConfigurationState, result: inout NSViewConfigurationState?) {
        result = source.state
    }

    public static func _conditionallyBridgeFromObjectiveC(_ source: __NSViewConfigurationState, result: inout NSViewConfigurationState?) -> Bool {
        _forceBridgeFromObjectiveC(source, result: &result)
        return true
    }

    public static func _unconditionallyBridgeFromObjectiveC(_ source: __NSViewConfigurationState?) -> NSViewConfigurationState {
        if let source = source {
            var result: NSViewConfigurationState?
            _forceBridgeFromObjectiveC(source, result: &result)
            return result!
        }
        return NSViewConfigurationState()
    }
}

/// The `Objective-C` class for ``NSViewConfigurationState``.
public class __NSViewConfigurationState: NSObject, NSCopying {
    let state: NSViewConfigurationState

    init(state: NSViewConfigurationState) {
        self.state = state
    }
    
    public func copy(with zone: NSZone? = nil) -> Any {
        __NSViewConfigurationState(state: state)
    }
    
    public override func isEqual(_ object: Any?) -> Bool {
        state == (object as? __NSViewConfigurationState)?.state
    }
}
#endif
