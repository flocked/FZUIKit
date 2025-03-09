//
//  ControlConfigurationState.swift
//
//
//  Created by Florian Zand on 08.03.25.
//

#if os(macOS)
import Foundation

/// The state of a control.
public struct ControlConfigurationState: NSConfigurationState {
    /// The state of the control.
    public var state: State = .off
    
    /// The state of the control.
    public enum State: Int, CustomStringConvertible {
        /// On
        case on = 1
        /// Off
        case off = 0
        /// Mixed
        case mixed = -1
        
        public var description: String {
            switch self {
            case .on: return "on"
            case .off: return "off"
            case .mixed: return "mixed"
            }
        }
    }
    
    /// A Boolean value that indicates whether the control is enabled and reacts to mouse events.
    public var isEnabled: Bool = false
    
    /// A Boolean value that indicates whether the mouse is hovering the control.
    public var isHovered: Bool = false
    
    /// A Boolean value that indicates whether the control is pressed down.
    public var isPressed: Bool = false
    
    /// A Boolean value that indicates whether the view is in an editing state.
    public var isEditing: Bool = false
    
    /// The active state of an control.
    public var activeState: ActiveState = .inactive {
        didSet { self["activeState"] = activeState.rawValue }
    }
    
    /// The active state of an control.
    public enum ActiveState: Int, Hashable, CustomStringConvertible {
        /**
         Inactive.
         
         The window that displays the control isn't the key window.
         */
        case inactive
        /**
         Active.
         
         The window that displays the control is the key window.
         */
        case active
        /**
         Active and focused.
         
         The control is focused (first responder).
         */
        case focused
        
        public var description: String {
            switch self {
            case .inactive: return "inactive"
            case .active: return "active"
            case .focused: return "focused"
            }
        }
    }
    
    var customStates = [NSConfigurationStateCustomKey: AnyHashable]()
    
    /// Accesses custom states by key.
    public subscript(key: NSConfigurationStateCustomKey) -> AnyHashable? {
        get { customStates[key] }
        set { customStates[key] = newValue }
    }
    
    init(state: State = .off, isEnabled: Bool = true, isHovered: Bool = false, isPressed: Bool = false, isEditing: Bool = false, activeState: ActiveState = .inactive, customStates: [NSConfigurationStateCustomKey: AnyHashable] = [:]) {
        self.state = state
        self.isHovered = isHovered
        self.isEnabled = isEnabled
        self.isPressed = isPressed
        self.isEditing = isEditing
        self.activeState = activeState
        self.customStates = customStates
    }
}

extension ControlConfigurationState: ReferenceConvertible {
    /// The Objective-C type for this state.
    public typealias ReferenceType = __ControlConfigurationState
    
    public var description: String {
        """
        ControlConfigurationState(
            state: \(state.description)
            isEnabled: \(isEnabled)
            isPressed: \(isPressed)
            isEditing: \(isEditing)
            isHovered: \(isHovered)
            activeState: \(activeState.description)
            customStates: \(customStates)
        )
        """
    }
    
    public var debugDescription: String {
        description
    }
    
    public func _bridgeToObjectiveC() -> __ControlConfigurationState {
        return __ControlConfigurationState(state: self)
    }
    
    public static func _forceBridgeFromObjectiveC(_ source: __ControlConfigurationState, result: inout ControlConfigurationState?) {
        result = source.state
    }
    
    public static func _conditionallyBridgeFromObjectiveC(_ source: __ControlConfigurationState, result: inout ControlConfigurationState?) -> Bool {
        _forceBridgeFromObjectiveC(source, result: &result)
        return true
    }
    
    public static func _unconditionallyBridgeFromObjectiveC(_ source: __ControlConfigurationState?) -> ControlConfigurationState {
        if let source = source {
            var result: ControlConfigurationState?
            _forceBridgeFromObjectiveC(source, result: &result)
            return result!
        }
        return ControlConfigurationState()
    }
}

/// The `Objective-C` class for ``ControlConfigurationState``.
public class __ControlConfigurationState: NSObject, NSCopying {
    let state: ControlConfigurationState
    
    init(state: ControlConfigurationState) {
        self.state = state
    }
    
    public func copy(with zone: NSZone? = nil) -> Any {
        __ControlConfigurationState(state: state)
    }
    
    public override func isEqual(_ object: Any?) -> Bool {
        state == (object as? __ControlConfigurationState)?.state
    }
}

#endif
