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
     Creates and returns a new table view row action object.
     
     - Parameters:
        - style: The style characteristics to apply to the button. Use this value to apply default appearance characteristics to the button. These characteristics visually communicate, such as by color, information about what the button does. For example, specify a style of `destructive` to indicate an action is destructive to the underlying data. For a list of possible style values, see `NSTableViewRowAction.Style`.
        - title: The string to display in the button. Specify a string localized for the user’s current language.
        - image: The image to display in the button.
        - handler: The block to execute when the user clicks the button associated with this action. AppKit makes a copy of the block you provide. When the user selects the action represented by this object, AppKit executes your handler block on the app’s main thread. This parameter must not be `nil`. This block has no return value and takes the following parameters:
            - action: The action object representing the action that the user selected.
            - rowIndex: The table row that the user acted on.
     */
    public convenience init(style: NSTableViewRowAction.Style, title: String, image: NSImage, handler: @escaping (NSTableViewRowAction, Int) -> Void) {
        self.init(style: style, title: title, handler: handler)
        self.image = image
    }
    
    /**
     Creates and returns a new table view row action object.
     
     - Parameters:
        - style: The style characteristics to apply to the button. Use this value to apply default appearance characteristics to the button. These characteristics visually communicate, such as by color, information about what the button does. For example, specify a style of `destructive` to indicate an action is destructive to the underlying data. For a list of possible style values, see `NSTableViewRowAction.Style`.
        - title: The string to display in the button. Specify a string localized for the user’s current language.
        - systemSymbol: The system symbol name for a system image.
        - handler: The block to execute when the user clicks the button associated with this action. AppKit makes a copy of the block you provide. When the user selects the action represented by this object, AppKit executes your handler block on the app’s main thread. This parameter must not be `nil`. This block has no return value and takes the following parameters:
            - action: The action object representing the action that the user selected.
            - rowIndex: The table row that the user acted on.
     */
    @available(macOS 11.0, *)
    public convenience init(style: NSTableViewRowAction.Style, title: String, systemSymbol: String, handler: @escaping (NSTableViewRowAction, Int) -> Void) {
        self.init(style: style, title: title, handler: handler)
        self.image = NSImage(systemSymbolName: systemSymbol)
    }
}

#endif
