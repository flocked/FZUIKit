//
//  NSButton+StandardConfiguration.swift
//
//
//  Created by Florian Zand on 29.06.23.
//

#if os(macOS)

    import AppKit
    import FZSwiftUtils
    import SwiftUI

    @available(macOS 13.0, *)
    public extension NSButton {
        /// A configuration that specifies the appearance and behavior of a button and its contents.
        struct Configuration: NSButtonConfiguration, Hashable {
            /// The style of the button.
            public enum ButtonType: Hashable {
                /// A standard push style button.
                case push

                /// A push button with a flexible height to accommodate longer text labels or an image.
                case flexiblePush

                /// A button style that’s appropriate for a toolbar item.
                case toolbar

                /// A button style that’s typically used in the context of an accessory toolbar for buttons that narrow the focus of a search or other operation.
                case accessoryBar

                /// A button style that you use for extra actions in an accessory toolbar.
                case accessoryBarAction

                /// A button style suitable for displaying additional information.
                case badge

                /// A round button that can contain either a single character or an icon.
                case circular

                /// A simple square bezel style that can scale to any size.
                case smallSquare

                /// A checkbox button.
                case checkBox
                
                /// A radio button.
                case radio
                
                /// A button with a question mark, providing the standard help button look.
                case help
                
                /// A button with a disclosure triangle.
                case disclosure
                
                /// A button with a bezeled disclosure triangle.
                case pushDisclosure

                var buttonType: NSButton.ButtonType {
                    switch self {
                    case .accessoryBar: return .pushOnPushOff
                    case .checkBox: return .switch
                    case .radio: return .radio
                    case .disclosure, .pushDisclosure: return .onOff
                    default: return .momentaryPushIn
                    }
                }

                var bezel: NSButton.BezelStyle {
                    switch self {
                    case .push: return .rounded
                    case .flexiblePush: return .regularSquare
                    case .toolbar: return .texturedRounded
                    case .accessoryBar: return .recessed
                    case .accessoryBarAction: return .roundRect
                    case .badge: return .inline
                    case .circular: return .circular
                    case .smallSquare: return .smallSquare
                    case .help: return .helpButton
                    case .disclosure: return .disclosure
                    case .pushDisclosure: return .pushDisclosure
                    default: return .rounded
                    }
                }
            }

            public var type: ButtonType = .push

            /// The text of the title label the button displays.
            public var title: String? {
                didSet {
                    if title != nil {
                        attributedTitle = nil
                    }
                }
            }

            /// The text and style attributes for the button’s title label.
            public var attributedTitle: NSAttributedString? {
                didSet {
                    if attributedTitle != nil {
                        title = nil
                    }
                }
            }

            /// The image the button displays.
            public var image: NSImage?

            /// The position of the image.
            public var imagePosition: NSControl.ImagePosition = .imageLeft
            
            /// The symbol configuration for the image.
            public var imageSymbolConfiguration: ImageSymbolConfiguration?

            ////  The sound that plays when the user clicks the button.
            public var sound: NSSound?

            /// The border color of the button.
            public var borderColor: NSColor?

            /// The color transformer for resolving the border color.
            var borderColorTransformer: ColorTransformer?

            /// Generates the resolved border color, using the border color and color transformer.
            func resolvedBorderColor() -> NSColor? {
                if let borderColor = borderColor {
                    return borderColorTransformer?(borderColor) ?? borderColor
                }
                return nil
            }

            /// A tint color to use for the template image and text content.
            var contentTintColor: NSColor?

            /// The color transformer for resolving the tint color.
            var contentTintColorTransformer: ColorTransformer?

            /// Generates the resolved tint color, using the tint color and color transformer.
            func resolvedContentTintColorColor() -> NSColor? {
                if let contentTintColor = contentTintColor {
                    return contentTintColorTransformer?(contentTintColor) ?? contentTintColor
                }
                return nil
            }

            /// The size of the button.
            public var size: NSControl.ControlSize = .regular

            /// A standard push style button.
            public static func push(_ title: String? = nil, image: NSImage? = nil) -> NSButton.Configuration {
                var configuration = Self(type: .push)
                configuration.title = title
                configuration.image = image
                return configuration
            }

            /// A push button with a flexible height to accommodate longer text labels or an image.
            public static func flexiblePush(_ title: String? = nil, image: NSImage? = nil) -> NSButton.Configuration {
                var configuration = Self(type: .flexiblePush)
                configuration.title = title
                configuration.image = image
                return configuration
            }

            /// A button style that’s appropriate for a toolbar item.
            public static func toolbar(_ title: String? = nil, image: NSImage? = nil) -> NSButton.Configuration {
                var configuration = Self(type: .toolbar)
                configuration.title = title
                configuration.image = image
                return configuration
            }

            /// A button style that’s typically used in the context of an accessory toolbar for buttons that narrow the focus of a search or other operation.
            public static func accessoryBar(_ title: String? = nil, image: NSImage? = nil) -> NSButton.Configuration {
                var configuration = Self(type: .accessoryBar)
                configuration.title = title
                configuration.image = image
                return configuration
            }

            /// A button style that you use for extra actions in an accessory toolbar.
            public static func accessoryBarAction(_ title: String? = nil, image: NSImage? = nil) -> NSButton.Configuration {
                var configuration = Self(type: .accessoryBarAction)
                configuration.title = title
                configuration.image = image
                return configuration
            }

            /// A button style suitable for displaying additional information.
            public static func badge(_ title: String? = nil, image: NSImage? = nil) -> NSButton.Configuration {
                var configuration = Self(type: .badge)
                configuration.title = title
                configuration.image = image
                return configuration
            }
            
            /// A round button that can contain either a single character or an icon.
            public static func circular(_ character: Character? = nil) -> Configuration {
                var configuration = Self(type: .circular)
                if let character = character {
                    configuration.title = String(character)
                }
                return configuration
            }
            
            /// A round button that can contain either a single character or an icon.
            public static func circular(_ image: NSUIImage) -> Configuration {
                var configuration = Self(type: .circular)
                configuration.image = image
                return configuration
            }
            
            /// A round button that can contain either a single character or an icon.
            public static func circular(symbolName: String) ->  Configuration {
                var configuration = Self(type: .circular)
                configuration.image = NSImage(systemSymbolName: symbolName)
                return configuration
            }

            /// A simple square bezel style that can scale to any size.
            public static func smallSquare(_ title: String? = nil, image: NSImage? = nil) -> NSButton.Configuration {
                var configuration = Self(type: .smallSquare)
                configuration.title = title
                configuration.image = image
                return configuration
            }

            /// Creates a configuration with a check box button.
             public static func checkBox(_ title: String? = nil, image: NSImage? = nil) -> NSButton.Configuration {
                 var configuration = Self(type: .checkBox)
                 configuration.title = title
                 configuration.image = image
                 return configuration
             }

            /// Creates a configuration with a radio button.
             public static func radio(_ title: String? = nil, image: NSImage? = nil) -> NSButton.Configuration {
                 var configuration = Self(type: .radio)
                 configuration.title = title
                 configuration.image = image
                 return configuration
             }
            
            /// Creates a button configuration with a question mark, providing the standard help button look.
            public static var help: Configuration {
                Self(type: .help)
            }
            
            /// Creates a button configuration with a disclosure triangle.
            public static var disclosure: Configuration {
                Self(type: .disclosure)
            }
            
            /// Creates a button configuration with a bezeled disclosure triangle.
            public static var pushDisclosure: Configuration {
                Self(type: .pushDisclosure)
            }
        }
    }

#endif
