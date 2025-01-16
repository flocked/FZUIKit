//
//  AXAction.swift
//  
//
//  Created by Florian Zand on 15.01.25.
//

#if canImport(ApplicationServices)
import Foundation
import ApplicationServices

/// The action of an accessibility object.
public struct AXAction: Hashable, RawRepresentable, ExpressibleByStringLiteral {
    /// The raw value of the action.
    public let rawValue: String
    /// The localized title of the action.
    public let localizedTitle: String?
    
    public init(rawValue: String) {
        self.rawValue = rawValue
        localizedTitle = nil
    }
    
    public init(stringLiteral value: String) {
        self.rawValue = value
        localizedTitle = nil
    }
    
    init(_ key: String, _ title: String? = nil) {
        rawValue = key
        localizedTitle = title
    }
    
    // MARK: - Standard actions

    /// Simulates clicking the UIElement, such as a button.
    public static let press = AXAction(kAXPressAction)
    
    /// Increments the value of the UIElement.
    public static let increment = AXAction(kAXIncrementAction)
    
    /// Decrements the value of the UIElement.
    public static let decrement = AXAction(kAXDecrementAction)
    
    /// Simulates pressing `Return` in the UIElement, such as a text field.
    public static let confirm = AXAction(kAXConfirmAction)
    
    /// Simulates a `Cancel` action, such as hitting the Cancel button.
    public static let cancel = AXAction(kAXCancelAction)
    
    /// Shows an alternate or hidden UI. This is often used to trigger the same change that would occur on a mouse hover.
    public static let showAlternateUI = AXAction(kAXShowAlternateUIAction)
    
    /// Shows the default UI. This is often used to trigger the same change that would occur when a mouse hover ends.
    public static let showDefaultUI = AXAction(kAXShowDefaultUIAction)
    
    // MARK: - New actions
    /**
     Causes a window to become as frontmost as is allowed by the containing application’s circumstances.
     
     Note that an application’s floating windows (such as inspector windows) might remain above a window that performs the raise action.
     */
    public static let raise = AXAction(kAXRaiseAction)
    /**
     Simulates the opening of a contextual menu in the element represented by this accessibility object.
     
     This action can also be used to simulate the display of a menu that is preassociated with an element, such as the menu that displays when a user clicks Safari’s back button slowly.
     */
    public static let showMenu = AXAction(kAXShowMenuAction)
    
    // MARK: - Obsolete actions
    /// Selects the UIElement, such as a menu item.
    public static let pick = AXAction(kAXPickAction)
}

extension AXAction: CustomStringConvertible {
    public var description: String {
        var description = rawValue
        if let title = localizedTitle {
            description += "(\"\(title)\")"
         }
        return description
    }
}

#endif
