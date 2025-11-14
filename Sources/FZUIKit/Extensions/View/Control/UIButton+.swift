//
//  UIButton+.swift
//
//
//  Created by Florian Zand on 10.07.25.
//

#if canImport(UIKit)
import UIKit

import UIKit

extension UIButton {
    
    
    /**
     Creates a custom button.
     
     - Parameters:
        - title: The title to display on the button.
        - image: The image to display on the button.
        - primaryAction: The action to perform when the button is selected.
     */
    public static func custom(title: String? = nil, image: UIImage? = nil, primaryAction: UIAction? = nil) -> UIButton {
        let button = UIButton(type: .custom, primaryAction: primaryAction)
        button.setTitle(title, for: .normal)
        button.setImage(image, for: .normal)
        return button
    }
    
    /**
     Creates a custom button.
     
     - Parameters:
        - title: The title to display on the button.
        - symbolName: The name of the system symbol image.
        - primaryAction: The action to perform when the button is selected.
     */
    public static func custom(title: String? = nil, symbolName: String, primaryAction: UIAction? = nil) -> UIButton {
        let button = UIButton(type: .custom, primaryAction: primaryAction)
        button.setTitle(title, for: .normal)
        button.setImage(UIImage(systemName: symbolName), for: .normal)
        return button
    }
    
    
    /**
     Creates a system style button, such as those shown in navigation bars and toolbars.
     
     - Parameters:
        - title: The title to display on the button.
        - image: The image to display on the button.
        - primaryAction: The action to perform when the button is selected.
     */
    public static func system(title: String? = nil, image: UIImage? = nil, primaryAction: UIAction? = nil) -> UIButton {
        let button = UIButton(type: .system, primaryAction: primaryAction)
        button.setTitle(title, for: .normal)
        button.setImage(image, for: .normal)
        return button
    }
    
    /**
     Creates a system style button, such as those shown in navigation bars and toolbars.
     
     - Parameters:
        - title: The title to display on the button.
        - symbolName: The name of the system symbol image.
        - primaryAction: The action to perform when the button is selected.
     */
    public static func system(title: String? = nil, symbolName: String, primaryAction: UIAction? = nil) -> UIButton {
        let button = UIButton(type: .system, primaryAction: primaryAction)
        button.setTitle(title, for: .normal)
        button.setImage(UIImage(systemName: symbolName), for: .normal)
        return button
    }

    /// Creates a detail disclosure button.
    public static var detailDisclosure: UIButton {
        .init(type: .detailDisclosure, primaryAction: nil)
    }

    /**
     Creates a detail disclosure button.
     
     - Parameter primaryAction: The action to perform when the button is selected.
     */
    public static func detailDisclosure(primaryAction: UIAction) -> UIButton {
        .init(type: .detailDisclosure, primaryAction: primaryAction)
    }

    /// Creates an information button that has a light background.
    public static var infoLight: UIButton {
        .init(type: .infoLight, primaryAction: nil)
    }

    /**
     Creates an information button that has a light background.
     
     - Parameter primaryAction: The action to perform when the button is selected.
     */
    public static func infoLight(primaryAction: UIAction) -> UIButton {
        .init(type: .infoLight, primaryAction: primaryAction)
    }

    /// Creates an information button that has a dark background.
    public static var infoDark: UIButton {
        .init(type: .infoDark, primaryAction: nil)
    }

    /**
     Creates an information button that has a dark background.
     
     - Parameter primaryAction: The action to perform when the button is selected.
     */
    public static func infoDark(primaryAction: UIAction) -> UIButton {
        .init(type: .infoDark, primaryAction: primaryAction)
    }

    /// Creates a contact add (+) button.
    public static var contactAdd: UIButton {
        .init(type: .contactAdd, primaryAction: nil)
    }

    /**
     Creates a contact add (+) button.
     
     - Parameter primaryAction: The action to perform when the button is selected.
     */
    public static func contactAdd(primaryAction: UIAction) -> UIButton {
        .init(type: .contactAdd, primaryAction: primaryAction)
    }

    #if os(iOS)
    /// Creates a close button to dismiss panels and views.
    public static var close: UIButton {
        .init(type: .close, primaryAction: nil)
    }

    /**
     Creates a close button to dismiss panels and views.
     
     - Parameter primaryAction: The action to perform when the button is selected.
     */
    public static func close(primaryAction: UIAction) -> UIButton {
        .init(type: .close, primaryAction: primaryAction)
    }
    #endif
    
    /**
     Sets the specified title.
     
     - Parameters:
        -  title: The title to use for the specified state.
        - state: The state that uses the specified title.
     */
    @discardableResult
    public func title(_ title: String?, for state: UIControl.State = .normal) -> Self {
        setTitle(title, for: state)
        return self
    }
    
    /// Sets the attributed title to use for the specified state.
    @discardableResult
    public func attributedTitle(_ title: NSAttributedString?, for state: UIControl.State = .normal) -> Self {
        setAttributedTitle(title, for: state)
        return self
    }
    
    /**
     Sets the specified image.
     
     - Parameters:
        -  image: The image to use for the specified state.
        - state: The state that uses the specified image.
     */
    @discardableResult
    public func image(_ image: UIImage?, for state: UIControl.State = .normal) -> Self {
        setImage(image, for: state)
        return self
    }
    
    /**
     Sets the symbol image for the specified name.
     
     - Parameters:
        -  symbolName: The name of the symbol image.
        - state: The state that uses the specified image.
     */
    @discardableResult
    public func image(symbolName: String, for state: UIControl.State = .normal) -> Self {
        setImage(UIImage(systemName: symbolName), for: state)
        return self
    }
    
    /**
     Sets the background image to use for the specified button state.
     
     - Parameters:
        -  image: The image to use for the specified state.
        - state: The state that uses the specified image.
     */
    @discardableResult
    public func backgroundImage(_ image: UIImage?, for state: UIControl.State = .normal) -> Self {
        setBackgroundImage(image, for: state)
        return self
    }
    
    /**
     Sets the background image to use for the specified button state.
     
     - Parameters:
        -  symbolName: The name of the symbol image.
        - state: The state that uses the specified image.
     */
    @discardableResult
    public func backgroundImage(symbolName: String, for state: UIControl.State = .normal) -> Self {
        setBackgroundImage(UIImage(systemName: symbolName), for: state)
        return self
    }
}
#endif
