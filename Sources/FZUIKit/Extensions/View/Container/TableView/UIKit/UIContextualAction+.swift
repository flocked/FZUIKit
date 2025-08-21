//
//  UIContextualAction+.swift
//  
//
//  Created by Florian Zand on 08.02.24.
//

#if os(iOS)
import UIKit

extension UIContextualAction {
    /**
     Creates a regular action with a text.

     - Parameters:
        - title: The title displayed on the action button. The default value is `nil`.
        - color: The background color of the action button. The default value is `nil`, which uses the default color for a regular action.
        - handler: The handler to execute when the user selects the action.
     */
    public static func regular(_ title: String, color: UIColor? = nil, handler: @escaping Handler) -> UIContextualAction {
        let action = UIContextualAction(style: .destructive, title: title, handler: handler)
        action.backgroundColor = color ?? action.backgroundColor
        return action
    }
    
    /**
     Creates a destructive action with a text.

     - Parameters:
        - title: The title displayed on the action button. The default value is `nil`.
        - color: The background color of the action button. The default value is `nil`, which uses the default color for a destructive action.
        - handler: The handler to execute when the user selects the action.
     */
    public static func destructive(_ title: String, color: UIColor? = nil, handler: @escaping Handler) -> UIContextualAction {
        let action = UIContextualAction(style: .destructive, title: title, handler: handler)
        action.backgroundColor = color ?? action.backgroundColor
        return action
    }

    /**
     Creates a regular action with a symbol image.

     - Parameters:
        - title: The title displayed on the action button. The default value is `nil`.
        - systemName: The system name for the image to display in the action button.
        - color: The background color of the action button. The default value is `nil`, which uses the default color for a regular action.
        - handler: The handler to execute when the user selects the action.
     */
    public static func regular(_ title: String? = nil, systemName: String, color: UIColor? = nil, handler: @escaping Handler) -> UIContextualAction {
        let action = UIContextualAction(style: .destructive, title: title ?? "", handler: handler)
        action.backgroundColor = color ?? action.backgroundColor
        action.image = UIImage(systemName: systemName)
        return action
    }

    /**
     Creates a destructive action with a symbol image.

     - Parameters:
        - title: The title displayed on the action button. The default value is `nil`.
        - systemName: The system name for the image to display in the action button.
        - color: The background color of the action button. The default value is `nil`, which uses the default color for a destructive action.
        - handler: The handler to execute when the user selects the action.
     */
    public static func destructive(_ title: String? = nil, systemName: String, color: UIColor? = nil, handler: @escaping Handler) -> UIContextualAction {
        let action = UIContextualAction(style: .destructive, title: title ?? "", handler: handler)
        action.backgroundColor = color ?? action.backgroundColor
        action.image = UIImage(systemName: systemName)
        return action
    }
    
    /**
     Creates a regular action with an image.

     - Parameters:
        - title: The title displayed on the action button. The default value is `nil`.
        - image: The image to display in the action button.
        - color: The background color of the action button. The default value is `nil`, which uses the default color for a regular action.
        - handler: The handler to execute when the user selects the action.
     */
    public static func regular(_ title: String? = nil, image: UIImage, color: UIColor? = nil, handler: @escaping Handler) -> UIContextualAction {
        let action = UIContextualAction(style: .destructive, title: title ?? "", handler: handler)
        action.backgroundColor = color ?? action.backgroundColor
        action.image = image
        return action
    }
    
    /**
     Creates a destructive action with an image.

     - Parameters:
        - title: The title displayed on the action button. The default value is `nil`.
        - image: The image to display in the action button.
        - color: The background color of the action button. The default value is `nil`, which uses the default color for a destructive action.
        - handler: The handler to execute when the user selects the action.
     */
    public static func destructive(_ title: String? = nil, image: UIImage, color: UIColor? = nil, handler: @escaping Handler) -> UIContextualAction {
        let action = UIContextualAction(style: .destructive, title: title ?? "", handler: handler)
        action.backgroundColor = color ?? action.backgroundColor
        action.image = image
        return action
    }
}

#endif
