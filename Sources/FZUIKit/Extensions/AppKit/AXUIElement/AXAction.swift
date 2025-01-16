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

    /// An action that simulates clicking an object, such as a button.
    public static let press = AXAction(kAXPressAction)
    
    /// An action that increments the value of the object.
    public static let increment = AXAction(kAXIncrementAction)
    
    /// An action that decrements the value of the object.
    public static let decrement = AXAction(kAXDecrementAction)
    
    /// An action that simulates pressing Return in the object, such as a text field.
    public static let confirm = AXAction(kAXConfirmAction)
    
    /// An action that cancels the operation.
    public static let cancel = AXAction(kAXCancelAction)
    
    /// An action that opens the element.
    public static let open = AXAction("AXOpen")
    
    /// An action that deletes the value of the object.
    public static let delete = AXAction("AXDelete")
    
    /// An action that shows the original or default UI; for example, during a mouse-hover event.
    public static let showDefaultUI = AXAction(kAXShowDefaultUIAction)
    
    /// An action that shows an alternate UI, for example, during a mouse-hover event.
    public static let showAlternateUI = AXAction(kAXShowAlternateUIAction)
    
    // MARK: - New actions
    /**
     An action that simulates bringing a window forward by clicking on its title bar.
     
     Note that an application’s floating windows (such as inspector windows) might remain above a window that performs the raise action.
     */
    public static let raise = AXAction(kAXRaiseAction)
    /**
     An action that simulates showing a menu by clicking on it.
     
     This action can also be used to simulate the display of a menu that is preassociated with an element, such as the menu that displays when a user clicks Safari’s back button slowly.
     */
    public static let showMenu = AXAction(kAXShowMenuAction)
    
    // MARK: - Obsolete actions
    
    /// An action that selects the object, such as a menu item.
    public static let pick = AXAction(kAXPickAction)
    
    /// An action that scrolls left the object by page.
    public static let scrollLeftByPage = AXAction("AXScrollLeftByPage")
    
    /// An action that scrolls right the object by page.
    public static let scrollRightByPage = AXAction("AXScrollRightByPage")
    
    /// An action that scrolls up the object by page.
    public static let scrollUpByPage = AXAction("AXScrollUpByPage")
    
    /// An action that scrolls down the object by page.
    public static let scrollDownByPage = AXAction("AXScrollDownByPage")
    
    /// An action that scrolls the object to visible.
    public static let scrollToVisible = AXAction("AXScrollToVisible")
}

extension AXAction: CustomStringConvertible {
    public var description: String {
        switch self {
        case .showMenu: return "showMenu"
        case .pick: return "pick"
        case .press: return "press"
        case .increment: return "increment"
        case .decrement: return "decrement"
        case .confirm: return "confirm"
        case .cancel: return "cancel"
        case .delete: return "delete"
        case .showAlternateUI: return "showAlternateUI"
        case .showDefaultUI: return "showDefaultUI"
        case .raise: return "raise"
        case .open: return "open"
        case .scrollUpByPage: return "scrollUpByPage"
        case .scrollDownByPage: return "scrollDownByPage"
        case .scrollLeftByPage: return "scrollLeftByPage"
        case .scrollRightByPage: return "scrollRightByPage"
        case .scrollToVisible: return "scrollToVisible"
        default: return rawValue
        }
        
        var description = rawValue
        if let title = localizedTitle {
            description += "(\"\(title)\")"
         }
        return description
    }
}

#endif
