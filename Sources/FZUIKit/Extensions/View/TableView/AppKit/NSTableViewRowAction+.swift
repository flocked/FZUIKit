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
            - color: The background color of the action button. The default value is `nil`, which uses the default color for a regular row action.
            - handler: The block to execute when the user clicks the button associated with this action. AppKit makes a copy of the block you provide. When the user selects the action represented by this object, AppKit executes your handler block on the app’s main thread.
                - action: The action object representing the action that the user selected.
                - rowIndex: The table row that the user acted on.
         */
        public static func regular(_ title: String, color: NSColor? = nil, handler: @escaping (NSTableViewRowAction, Int) -> Void) -> NSTableViewRowAction {
            let action = NSTableViewRowAction(style: .destructive, title: title, handler: handler)
            action.backgroundColor = color ?? action.backgroundColor
            return action
        }

        /**
         Creates a destructive row action with a text.

         - Parameters:
            - title: The string to display in the button. The default value is `nil`.
            - color: The background color of the action button. The default value is `nil`, which uses the default color for a destructive row action.
            - handler: The block to execute when the user clicks the button associated with this action. AppKit makes a copy of the block you provide. When the user selects the action represented by this object, AppKit executes your handler block on the app’s main thread.
                - action: The action object representing the action that the user selected.
                - rowIndex: The table row that the user acted on.
         */
        public static func destructive(_ title: String, color: NSColor? = nil, handler: @escaping (NSTableViewRowAction, Int) -> Void) -> NSTableViewRowAction {
            let action = NSTableViewRowAction(style: .destructive, title: title, handler: handler)
            action.backgroundColor = color ?? action.backgroundColor
            return action
        }

        /**
         Creates a regular row action with a symbol image.

         - Parameters:
            - title: The string to display in the button. The default value is `nil`.
            - symbolName: The system symbol name for a system image.
            - color: The background color of the action button. The default value is `nil`, which uses the default color for a regular row action.
            - handler: The block to execute when the user clicks the button associated with this action. AppKit makes a copy of the block you provide. When the user selects the action represented by this object, AppKit executes your handler block on the app’s main thread.
                - action: The action object representing the action that the user selected.
                - rowIndex: The table row that the user acted on.
         */
        @available(macOS 11.0, *)
        public static func regular(_ title: String? = nil, symbolName: String, color: NSColor? = nil, handler: @escaping (NSTableViewRowAction, Int) -> Void) -> NSTableViewRowAction {
            let action = NSTableViewRowAction(style: .destructive, title: title ?? "", handler: handler)
            action.backgroundColor = color ?? action.backgroundColor
            action.image = NSImage(systemSymbolName: symbolName)
            return action
        }

        /**
         Creates a destructive row action with a symbol image.

         - Parameters:
            - title: The string to display in the button. The default value is `nil`.
            - symbolName: The system symbol name for a system image.
            - color: The background color of the action button. The default value is `nil`, which uses the default color for a destructive row action.
            - handler: The block to execute when the user clicks the button associated with this action. AppKit makes a copy of the block you provide. When the user selects the action represented by this object, AppKit executes your handler block on the app’s main thread.
                - action: The action object representing the action that the user selected.
                - rowIndex: The table row that the user acted on.
         */
        @available(macOS 11.0, *)
        public static func destructive(_ title: String? = nil, symbolName: String, color: NSColor? = nil, handler: @escaping (NSTableViewRowAction, Int) -> Void) -> NSTableViewRowAction {
            let action = NSTableViewRowAction(style: .destructive, title: title ?? "", handler: handler)
            action.backgroundColor = color ?? action.backgroundColor
            action.image = NSImage(systemSymbolName: symbolName)
            return action
        }
        
        /**
         Creates a regular row action with an image.

         - Parameters:
            - title: The string to display in the button. The default value is `nil`.
            - image: The image of the row action.
            - color: The background color of the action button. The default value is `nil`, which uses the default color for a regular row action.
            - handler: The block to execute when the user clicks the button associated with this action. AppKit makes a copy of the block you provide. When the user selects the action represented by this object, AppKit executes your handler block on the app’s main thread.
                - action: The action object representing the action that the user selected.
                - rowIndex: The table row that the user acted on.
         */
        public static func regular(_ title: String? = nil, image: NSImage, color: NSColor? = nil, handler: @escaping (NSTableViewRowAction, Int) -> Void) -> NSTableViewRowAction {
            let action = NSTableViewRowAction(style: .destructive, title: title ?? "", handler: handler)
            action.backgroundColor = color ?? action.backgroundColor
            action.image = image
            return action
        }
        
        /**
         Creates a destructive row action with an image.

         - Parameters:
            - title: The string to display in the button. The default value is `nil`.
            - image: The image of the row action.
            - color: The background color of the action button. The default value is `nil`, which uses the default color for a destructive row action.
            - handler: The block to execute when the user clicks the button associated with this action. AppKit makes a copy of the block you provide. When the user selects the action represented by this object, AppKit executes your handler block on the app’s main thread.
                - action: The action object representing the action that the user selected.
                - rowIndex: The table row that the user acted on.
         */
        public static func destructive(_ title: String? = nil, image: NSImage, color: NSColor? = nil, handler: @escaping (NSTableViewRowAction, Int) -> Void) -> NSTableViewRowAction {
            let action = NSTableViewRowAction(style: .destructive, title: title ?? "", handler: handler)
            action.backgroundColor = color ?? action.backgroundColor
            action.image = image
            return action
        }
    }

#endif
