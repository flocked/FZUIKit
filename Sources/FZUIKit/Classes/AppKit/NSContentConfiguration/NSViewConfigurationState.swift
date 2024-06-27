//
//  NSViewConfigurationState.swift
//
//
//  Created by Florian Zand on 28.12.23.
//

import AppKit
import FZSwiftUtils

/**
 A structure that encapsulates a state for a view.

 A view configuration state encompasses the common states that affect the appearance of the view — states like enabled, selected, or emphasized. You can use it to update the appearance.

 Typically, you don’t create a configuration state yourself. To obtain a configuration state either use the view's `configurationUpdateHandler` or override its `updateConfiguration(using:)` method in a subclass and use the state parameter. Outside of this method, you can get the configuration state by using its `configurationState` property.

 You can create your own custom states to add to a view configuration state by defining a custom state key using `NSConfigurationStateCustomKey`.
 */
public struct NSViewConfigurationState: NSConfigurationState, Hashable {
    /// A Boolean value that indicates whether the view is selected.
    public var isSelected: Bool = false

    /**
     A Boolean value that indicates whether the view is enabled.

     The value of this property is `true`, if it's table view `isEnabled` is `true`.
     */
    public var isEnabled: Bool = true

    /**
     A Boolean value that indicates whether the view is in a hovered state.

     The value of this property is `true`, if the mouse is hovering the view.
     */
    public var isHovered: Bool = false

    /// A Boolean value that indicates whether the view is in an editing state.
    public var isEditing: Bool = false

    /**
     A Boolean value that indicates whether the view is in an emphasized state.

     The value of this property is `true`, if it's window is key.
     */
    public var isEmphasized: Bool = false

    /// A Boolean value that indicates whether the view is in a focused state.
    var isFocused: Bool = false

    /// A Boolean value that indicates whether the view is in an expanded state.
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
                isEmphasized: Bool = false)
    {
        self.isSelected = isSelected
        self.isEnabled = isEnabled
        self.isHovered = isHovered
        self.isEditing = isEditing
        self.isEmphasized = isEmphasized
    }

    init(isSelected: Bool,
         isEnabled: Bool,
         isHovered: Bool,
         isEditing: Bool,
         isEmphasized: Bool,
         customStates: [NSConfigurationStateCustomKey: AnyHashable])
    {
        self.isSelected = isSelected
        self.isEnabled = isEnabled
        self.isHovered = isHovered
        self.isEditing = isEditing
        self.isEmphasized = isEmphasized
        self.customStates = customStates
    }
}

extension NSViewConfigurationState: ReferenceConvertible {
    /// The Objective-C type for this state.
    public typealias ReferenceType = __NSViewConfigurationStateObjcNew

    public var description: String {
        """
        NSViewConfigurationState(
            isSelected: \(isSelected)
            isEnabled: \(isEnabled)
            isHovered: \(isHovered)
            isEditing: \(isEditing)
            isEmphasized: \(isEmphasized)
            customStates: \(customStates)
        )
        """
    }

    public var debugDescription: String {
        description
    }

    public func _bridgeToObjectiveC() -> __NSViewConfigurationStateObjcNew {
        return __NSViewConfigurationStateObjcNew(isSelected: isSelected, isEnabled: isEnabled, isHovered: isHovered, isEditing: isEditing, isEmphasized: isEmphasized, isFocused: isFocused, isExpanded: isExpanded, customStates: customStates)
    }

    public static func _forceBridgeFromObjectiveC(_ source: __NSViewConfigurationStateObjcNew, result: inout NSViewConfigurationState?) {
        result = NSViewConfigurationState(isSelected: source.isSelected, isEnabled: source.isEnabled, isHovered: source.isHovered, isEditing: source.isEditing, isEmphasized: source.isEmphasized, customStates: source.customStates)
    }

    public static func _conditionallyBridgeFromObjectiveC(_ source: __NSViewConfigurationStateObjcNew, result: inout NSViewConfigurationState?) -> Bool {
        _forceBridgeFromObjectiveC(source, result: &result)
        return true
    }

    public static func _unconditionallyBridgeFromObjectiveC(_ source: __NSViewConfigurationStateObjcNew?) -> NSViewConfigurationState {
        if let source = source {
            var result: NSViewConfigurationState?
            _forceBridgeFromObjectiveC(source, result: &result)
            return result!
        }
        return NSViewConfigurationState()
    }
}

/// The `Objective-C` class for ``NSViewConfigurationState``.
public class __NSViewConfigurationStateObjcNew: NSObject, NSCopying {
    var isSelected: Bool
    var isEnabled: Bool
    var isHovered: Bool
    var isEditing: Bool
    var isEmphasized: Bool
    var isFocused: Bool
    var isExpanded: Bool
    var customStates:[NSConfigurationStateCustomKey: AnyHashable]

    init(isSelected: Bool, isEnabled: Bool, isHovered: Bool, isEditing: Bool, isEmphasized: Bool, isFocused: Bool, isExpanded: Bool, customStates: [NSConfigurationStateCustomKey: AnyHashable]) {
        self.isSelected = isSelected
        self.isEnabled = isEnabled
        self.isHovered = isHovered
        self.isEditing = isEditing
        self.isEmphasized = isEmphasized
        self.isFocused = isFocused
        self.isExpanded = isExpanded
        self.customStates = customStates
        super.init()
    }
    
    public func copy(with zone: NSZone? = nil) -> Any {
        __NSViewConfigurationStateObjcNew(isSelected: isSelected, isEnabled: isEnabled, isHovered: isHovered, isEditing: isEditing, isEmphasized: isEmphasized, isFocused: isFocused, isExpanded: isExpanded, customStates: customStates)
    }
}
