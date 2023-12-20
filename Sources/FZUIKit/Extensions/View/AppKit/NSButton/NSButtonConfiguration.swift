//
//  NSButtonConfiguration.swift
//  
//
//  Created by Florian Zand on 29.06.23.
//

#if os(macOS)
import AppKit

/// A type that provides configuration that specifies the appearance and behavior of a button and its contents.
@available(macOS 13.0, *)
public protocol NSButtonConfiguration {
    var title: String? { get }
    var attributedTitle: NSAttributedString? { get }
    var image: NSImage? { get }
    var imageSymbolConfiguration: ImageSymbolContentConfiguration? { get }
    var size: NSControl.ControlSize { get }
}

@available(macOS 13.0, *)
extension NSButtonConfiguration {
    /// Creates a configuration for a button with a transparent background.
    public static func plain(color: NSColor = .controlAccentColor) -> NSButton.AdvanceConfiguration {
        return .plain(color: color)
    }
    
    /// Creates a configuration for a button with a gray background.
    public static func gray() -> NSButton.AdvanceConfiguration {
        return .gray()
    }
    
    /// Creates a configuration for a button with a tinted background color.
    public static func tinted(color: NSColor = .controlAccentColor) -> NSButton.AdvanceConfiguration {
        return .tinted(color: color)
    }
    
    /// Creates a configuration for a button with a background filled with the button’s tint color.
    public static func filled(color: NSColor = .controlAccentColor) -> NSButton.AdvanceConfiguration {
        return .filled(color: color)
    }
    
    /// Creates a configuration for a button that has a bordered style.
    public static func bordered(color: NSColor = .controlAccentColor) -> NSButton.AdvanceConfiguration {
        return .bordered(color: color)
    }
    
    /// A standard push style button.
    public static func push() -> NSButton.Configuration {
        return NSButton.Configuration(style: .push)
    }
    
    /// A push button with a flexible height to accommodate longer text labels or an image.
    public static func flexiblePush() -> NSButton.Configuration {
        return NSButton.Configuration(style: .flexiblePush)
    }
    
    /// A button style that’s appropriate for a toolbar item.
    public static func toolbar() -> NSButton.Configuration {
        return NSButton.Configuration(style: .toolbar)
    }
    
    /// A button style that’s typically used in the context of an accessory toolbar for buttons that narrow the focus of a search or other operation.
    public static func accessoryBar() -> NSButton.Configuration {
        return NSButton.Configuration(style: .accessoryBar)
    }
    
    /// A button style that you use for extra actions in an accessory toolbar.
    public static func accessoryBarAction() -> NSButton.Configuration {
        return NSButton.Configuration(style: .accessoryBarAction)
    }
    
    /// A button style suitable for displaying additional information.
    public static func badge() -> NSButton.Configuration {
        return NSButton.Configuration(style: .badge)
    }
    
    /// A round button that can contain either a single character or an icon.
    public static func circular() -> NSButton.Configuration {
        return NSButton.Configuration(style: .circular)
    }
    
    /// A simple square bezel style that can scale to any size.
    public static func smallSquare() -> NSButton.Configuration {
        return NSButton.Configuration(style: .smallSquare)
    }
    
    /*
    public static func checkBox() -> NSButton.Configuration {
        return NSButton.Configuration(style: .checkBox)
    }
    
    public static func radio() -> NSButton.Configuration {
        return NSButton.Configuration(style: .radio)
    }
    */
}

#endif
