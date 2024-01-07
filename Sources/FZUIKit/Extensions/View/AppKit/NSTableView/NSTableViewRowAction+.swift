//
//  NSTableViewRowAction+.swift
//
//
//  Created by Florian Zand on 07.01.24.
//

#if os(macOS)
import AppKit

extension NSTableViewRowAction {
    /**
     Creates a regular row action with a text.
     
     - Parameters:
        - title: The string to display in the button. The default value is `nil`.
        - backgroundColor: The background color of the action button. The default value is `systemBlue`.
        - handler: The block to execute when the user clicks the button associated with this action. AppKit makes a copy of the block you provide. When the user selects the action represented by this object, AppKit executes your handler block on the app’s main thread. This parameter must not be `nil`. This block has no return value and takes the following parameters:
            - action: The action object representing the action that the user selected.
            - rowIndex: The table row that the user acted on.
     */
    public static func regular(_ title: String, color: NSColor? = .systemBlue, handler: @escaping (NSTableViewRowAction, Int) -> ()) -> NSTableViewRowAction {
        let action = NSTableViewRowAction(style: .destructive, title: title, handler: handler)
        action.backgroundColor = color
        return action
    }
    
    /**
     Creates a destructive row action with a text.
     
     - Parameters:
        - title: The string to display in the button. The default value is `nil`.
        - backgroundColor: The background color of the action button. The default value is `systemRed`.
        - handler: The block to execute when the user clicks the button associated with this action. AppKit makes a copy of the block you provide. When the user selects the action represented by this object, AppKit executes your handler block on the app’s main thread. This parameter must not be `nil`. This block has no return value and takes the following parameters:
            - action: The action object representing the action that the user selected.
            - rowIndex: The table row that the user acted on.
     */
    public static func destructive(_ title: String, color: NSColor? = .systemRed, handler: @escaping (NSTableViewRowAction, Int) -> ()) -> NSTableViewRowAction {
        let action = NSTableViewRowAction(style: .destructive, title: title, handler: handler)
        action.backgroundColor = color
        return action
    }
    
    /**
     Creates a regular row action with a symbol image.
     
     - Parameters:
        - title: The string to display in the button. The default value is `nil`.
        - symbolName: The system symbol name for a system image.
        - backgroundColor: The background color of the action button. The default value is `systemBlue`.
        - handler: The block to execute when the user clicks the button associated with this action. AppKit makes a copy of the block you provide. When the user selects the action represented by this object, AppKit executes your handler block on the app’s main thread. This parameter must not be `nil`. This block has no return value and takes the following parameters:
            - action: The action object representing the action that the user selected.
            - rowIndex: The table row that the user acted on.
     */
    @available(macOS 11.0, *)
    public static func regular(_ title: String? = nil, symbolName: String, color: NSColor? = .systemBlue, handler: @escaping (NSTableViewRowAction, Int) -> ()) -> NSTableViewRowAction {
        let action = NSTableViewRowAction(style: .destructive, title: title ?? "", handler: handler)
        action.backgroundColor = color
        action.image = NSImage(systemSymbolName: symbolName)
        return action
    }
    
    /**
     Creates a destructive row action with a symbol image.
     
     - Parameters:
        - title: The string to display in the button. The default value is `nil`.
        - symbolName: The system symbol name for a system image.
        - backgroundColor: The background color of the action button. The default value is `systemRed`.
        - handler: The block to execute when the user clicks the button associated with this action. AppKit makes a copy of the block you provide. When the user selects the action represented by this object, AppKit executes your handler block on the app’s main thread. This parameter must not be `nil`. This block has no return value and takes the following parameters:
            - action: The action object representing the action that the user selected.
            - rowIndex: The table row that the user acted on.
     */
    @available(macOS 11.0, *)
    public static func destructive(_ title: String? = nil, symbolName: String, color: NSColor = .systemRed, handler: @escaping (NSTableViewRowAction, Int) -> ()) -> NSTableViewRowAction {
        let action = NSTableViewRowAction(style: .destructive, title: title ?? "", handler: handler)
        action.backgroundColor = color
        action.image = NSImage(systemSymbolName: symbolName)
        return action
    }
    
    /**
     Creates and returns a new table view row action object.
     
     - Parameters:
        - style: The style characteristics to apply to the button. Use this value to apply default appearance characteristics to the button. These characteristics visually communicate, such as by color, information about what the button does. For example, specify a style of `destructive` to indicate an action is destructive to the underlying data. For a list of possible style values, see `NSTableViewRowAction.Style`.
        - title: The string to display in the button. Specify a string localized for the user’s current language.
        - backgroundColor: The background color of the action button.
        - handler: The block to execute when the user clicks the button associated with this action. AppKit makes a copy of the block you provide. When the user selects the action represented by this object, AppKit executes your handler block on the app’s main thread. This parameter must not be `nil`. This block has no return value and takes the following parameters:
            - action: The action object representing the action that the user selected.
            - rowIndex: The table row that the user acted on.
     */
    public convenience init(style: NSTableViewRowAction.Style, title: String, color: NSColor, handler: @escaping (NSTableViewRowAction, Int) -> Void) {
        self.init(style: style, title: title, handler: handler)
        self.image = image
        self.backgroundColor = color
    }
    
    /**
     Creates and returns a new table view row action object.
     
     - Parameters:
        - style: The style characteristics to apply to the button. Use this value to apply default appearance characteristics to the button. These characteristics visually communicate, such as by color, information about what the button does. For example, specify a style of `destructive` to indicate an action is destructive to the underlying data. For a list of possible style values, see `NSTableViewRowAction.Style`.
        - title: The string to display in the button. Specify a string localized for the user’s current language.
        - image: The image to display in the button.
        - backgroundColor: The background color of the action button. The default value is `nil`, which uses a background color for the specified style.
        - handler: The block to execute when the user clicks the button associated with this action. AppKit makes a copy of the block you provide. When the user selects the action represented by this object, AppKit executes your handler block on the app’s main thread. This parameter must not be `nil`. This block has no return value and takes the following parameters:
            - action: The action object representing the action that the user selected.
            - rowIndex: The table row that the user acted on.
     */
    public convenience init(style: NSTableViewRowAction.Style, title: String, image: NSImage, color: NSColor? = nil, handler: @escaping (NSTableViewRowAction, Int) -> Void) {
        self.init(style: style, title: title, handler: handler)
        self.image = image
        self.backgroundColor = color ?? (style == .regular ? .systemBlue : .systemRed)
    }
    
    /**
     Creates and returns a new table view row action object.
     
     - Parameters:
        - style: The style characteristics to apply to the button. Use this value to apply default appearance characteristics to the button. These characteristics visually communicate, such as by color, information about what the button does. For example, specify a style of `destructive` to indicate an action is destructive to the underlying data. For a list of possible style values, see `NSTableViewRowAction.Style`.
        - title: The string to display in the button. Specify a string localized for the user’s current language.
        - symbolName: The system symbol name for a system image.
        - backgroundColor: The background color of the action button. The default value is `nil`, which uses a background color for the specified style.
        - handler: The block to execute when the user clicks the button associated with this action. AppKit makes a copy of the block you provide. When the user selects the action represented by this object, AppKit executes your handler block on the app’s main thread. This parameter must not be `nil`. This block has no return value and takes the following parameters:
            - action: The action object representing the action that the user selected.
            - rowIndex: The table row that the user acted on.
     */
    @available(macOS 11.0, *)
    public convenience init(style: NSTableViewRowAction.Style, title: String, symbolName: String, color: NSColor? = nil, handler: @escaping (NSTableViewRowAction, Int) -> Void) {
        self.init(style: style, title: title, handler: handler)
        self.image = NSImage(systemSymbolName: symbolName)
        self.backgroundColor = color ?? (style == .regular ? .systemBlue : .systemRed)
    }
}

#endif
