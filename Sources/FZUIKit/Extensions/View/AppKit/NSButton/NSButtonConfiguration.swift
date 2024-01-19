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
        var imageSymbolConfiguration: ImageSymbolConfiguration? { get }
        var size: NSControl.ControlSize { get }
    }

    @available(macOS 13.0, *)
    public extension NSButtonConfiguration {
        /// Creates a configuration for a button with a transparent background.
        static func plain(color: NSColor = .controlAccentColor) -> NSButton.AdvanceButtonConfiguration {
            .plain(color: color)
        }

        /// Creates a configuration for a button with a gray background.
        static func gray() -> NSButton.AdvanceButtonConfiguration {
            .gray()
        }

        /// Creates a configuration for a button with a tinted background color.
        static func tinted(color: NSColor = .controlAccentColor) -> NSButton.AdvanceButtonConfiguration {
            .tinted(color: color)
        }

        /// Creates a configuration for a button with a background filled with the button’s tint color.
        static func filled(color: NSColor = .controlAccentColor) -> NSButton.AdvanceButtonConfiguration {
            .filled(color: color)
        }

        /// Creates a configuration for a button that has a bordered style.
        static func bordered(color: NSColor = .controlAccentColor) -> NSButton.AdvanceButtonConfiguration {
            .bordered(color: color)
        }

        /// A standard push style button.
        static func push() -> NSButton.Configuration {
            NSButton.Configuration(style: .push)
        }

        /// A push button with a flexible height to accommodate longer text labels or an image.
        static func flexiblePush() -> NSButton.Configuration {
            NSButton.Configuration(style: .flexiblePush)
        }

        /// A button style that’s appropriate for a toolbar item.
        static func toolbar() -> NSButton.Configuration {
            NSButton.Configuration(style: .toolbar)
        }

        /// A button style that’s typically used in the context of an accessory toolbar for buttons that narrow the focus of a search or other operation.
        static func accessoryBar() -> NSButton.Configuration {
            NSButton.Configuration(style: .accessoryBar)
        }

        /// A button style that you use for extra actions in an accessory toolbar.
        static func accessoryBarAction() -> NSButton.Configuration {
            NSButton.Configuration(style: .accessoryBarAction)
        }

        /// A button style suitable for displaying additional information.
        static func badge() -> NSButton.Configuration {
            NSButton.Configuration(style: .badge)
        }

        /// A round button that can contain either a single character or an icon.
        static func circular() -> NSButton.Configuration {
            NSButton.Configuration(style: .circular)
        }

        /// A simple square bezel style that can scale to any size.
        static func smallSquare() -> NSButton.Configuration {
            NSButton.Configuration(style: .smallSquare)
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
