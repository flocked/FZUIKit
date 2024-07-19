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
            public enum Style: Hashable {
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

                //     case checkBox
                //      case radio

                var buttonStyle: NSButton.ButtonType {
                    switch self {
                    /*
                     case .checkBox:
                     return .switch
                     case .radio:
                     return .radio
                     */
                    case .accessoryBar:
                        return .pushOnPushOff
                    default:
                        return .momentaryPushIn
                    }
                }

                var bezelStyle: NSButton.BezelStyle {
                    switch self {
                    case .push: return .rounded
                    case .flexiblePush: return .regularSquare
                    case .toolbar: return .texturedRounded
                    case .accessoryBar: return .recessed
                    case .accessoryBarAction: return .roundRect
                    case .badge: return .inline
                    case .circular: return .circular
                    case .smallSquare: return .smallSquare
                    }
                }
            }

            public var style: Style = .push

            /// The text of the title label the button displays.
            public var title: String?

            /// The text and style attributes for the button’s title label.
            public var attributedTitle: NSAttributedString?

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
            public static func push() -> NSButton.Configuration {
                NSButton.Configuration(style: .push)
            }

            /// A push button with a flexible height to accommodate longer text labels or an image.
            public static func flexiblePush() -> NSButton.Configuration {
                NSButton.Configuration(style: .flexiblePush)
            }

            /// A button style that’s appropriate for a toolbar item.
            public static func toolbar() -> NSButton.Configuration {
                NSButton.Configuration(style: .toolbar)
            }

            /// A button style that’s typically used in the context of an accessory toolbar for buttons that narrow the focus of a search or other operation.
            public static func accessoryBar() -> NSButton.Configuration {
                NSButton.Configuration(style: .accessoryBar)
            }

            /// A button style that you use for extra actions in an accessory toolbar.
            public static func accessoryBarAction() -> NSButton.Configuration {
                NSButton.Configuration(style: .accessoryBarAction)
            }

            /// A button style suitable for displaying additional information.
            public static func badge() -> NSButton.Configuration {
                NSButton.Configuration(style: .badge)
            }

            /// A round button that can contain either a single character or an icon.
            public static func circular() -> NSButton.Configuration {
                NSButton.Configuration(style: .circular)
            }

            /// A simple square bezel style that can scale to any size.
            public static func smallSquare() -> NSButton.Configuration {
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
    }

#endif

/*
 public enum ButtonStyle: Hashable {
 case push
 case texturedRounded
 case gradient
 case checkbox
 case radio
 case recessed
 case inline
 case square
 case bevel
 case help
 case disclosure
 case disclosureTriangle

 var buttonStyle: NSButton.ButtonType {
 switch self {
 case .push:
 return .momentaryPushIn
 case .texturedRounded:
 return .momentaryPushIn
 case .gradient:
 return .momentaryPushIn
 case .checkbox:
 return .switch
 case .radio:
 return .radio
 case .recessed:
 return .pushOnPushOff
 case .inline:
 return .momentaryPushIn
 case .square:
 return .momentaryPushIn
 case .bevel:
 return .momentaryPushIn
 case .help:
 return .momentaryPushIn
 case .disclosure:
 return .onOff
 case .disclosureTriangle:
 return .onOff
 }
 }
 var bezelStyle: NSButton.BezelStyle {
 switch self {
 case .push:
 return .rounded
 case .texturedRounded:
 return .texturedRounded
 case .gradient:
 return .smallSquare
 case .checkbox:
 return .push
 case .radio:
 return .push
 case .recessed:
 return .recessed
 case .inline:
 return .inline
 case .square:
 return .shadowlessSquare
 case .bevel:
 return .regularSquare
 case .help:
 return .helpButton
 case .disclosure:
 return .roundedDisclosure
 case .disclosureTriangle:
 return .disclosure
 }
 }
 }
 */
