//
//  NSContentUnavailableConfiguration+ButtonConfiguration.swift
//
//
//  Created by Florian Zand on 24.06.23.
//

#if os(macOS)
    import AppKit
    import FZSwiftUtils
    import SwiftUI

    @available(macOS 12.0, *)
    public extension NSContentUnavailableConfiguration {
        /// Properties to configure buttons for a content-unavailable view.
        struct ButtonConfiguration {
            
            /// The style of the button.
            public enum Style: Int, Hashable {
                /// A button style that doesn’t style or decorate its content while idle, but may apply a visual effect to indicate the pressed, focused, or enabled state of the button.
                case plain
                /// A button style that doesn’t apply a border.
                case borderless
                /// A button style that applies standard border artwork based on the button’s context.
                case bordered
                /// A button style that doesn’t apply a border.
                case link
            }
            
            /// The size of the button
            public enum Size: Hashable {
                /// A button that is minimally sized.
                case mini
                /// A button that is proportionally smaller size for space-constrained views.
                case small
                /// A button that is the default size.
                case regular
                /// A button that is prominently sized.
                case large
                /// A button with a fixed size (only valid for borderless buttons with an image)
                case fixed(CGSize)
                @available(macOS 14.0, *)
                /// A button that is sized extra large.
                case extraLarge
                var size: CGSize? {
                    switch self {
                    case .fixed(let size): return size
                    default: return nil
                    }
                }
                var swiftUI: SwiftUI.ControlSize {
                    switch self {
                    case .mini: return .mini
                    case .small: return .small
                    case .large: return .large
                    case .extraLarge: if #available(macOS 14.0, *) {
                        return .extraLarge
                    } else {
                        return .regular
                    }
                    default: return .regular
                    }
                }
            }

            /// The title.
            public var title: String?
            
            /// The attributed title.
            public var atributedTitle: AttributedString?
            
            /// The image.
            public var image: NSImage?

            /// The action of the button.
            public var action: (() -> Void)?
            
            /// A Boolean value that indicates whether the button is enabled.
            public var isEnabled: Bool = true

            /// The tint color.
            public var contentTintColor: NSColor?
            
            /// The style.
            public var style: Style = .bordered
            
            /// The size.
            public var size: Size = .regular
            
            /// The symbol configuration of the image.
            public var symbolConfiguration: ImageSymbolConfiguration?

            var hasContent: Bool {
                title != nil || atributedTitle != nil || image != nil
            }
            
            /// Creates a button configuration.
            public init(title: String? = nil, atributedTitle: AttributedString? = nil, image: NSImage? = nil,  isEnabled: Bool = true, contentTintColor: NSColor? = nil, style: Style = .bordered, size: Size = .regular, symbolConfiguration: ImageSymbolConfiguration? = nil, action: (() -> Void)? = nil) {
                self.title = title
                self.atributedTitle = atributedTitle
                self.image = image
                self.action = action
                self.isEnabled = isEnabled
                self.contentTintColor = contentTintColor
                self.style = style
                self.size = size
                self.symbolConfiguration = symbolConfiguration
            }

            /**
             A text button.
             
             - Parameters:
                - text: The text of the button.
                - style: The style of the button.
                - action: The action of the button.
             */
            public static func textButton(_ title: String, image: NSImage? = nil, style: Style = .bordered, action: @escaping (() -> Void)) -> Self {
                Self(title: title, image: image, style: style, action: action)
            }
            
            /**
             A image button.
             
             - Parameters:
                - image: The image of the button.
                - style: The style of the button.
                - action: The action of the button.
             */
            public static func imageButton(_ image: NSImage, style: Style = .bordered, action: @escaping (() -> Void)) -> Self {
                Self(image: image, style: style, action: action)
            }
            
            /**
             A symbol image button.
             
             - Parameters:
                - symbolName: The name of the symbol image.
                - symbolConfiguration: The image symbol configuration.
                - style: The style of the button.
                - action: The action of the button.
             */
            public static func symbolImageButton(_ symbolName: String, symbolConfiguration: ImageSymbolConfiguration? = nil, style: Style = .bordered, action: @escaping (() -> Void)) -> Self {
                Self(image: NSImage(systemSymbolName: symbolName), style: style, symbolConfiguration: symbolConfiguration, action: action)
            }
        }
    }

    @available(macOS 12.0, *)
    extension NSContentUnavailableConfiguration.ButtonConfiguration: Hashable {
        public static func == (lhs: NSContentUnavailableConfiguration.ButtonConfiguration, rhs: NSContentUnavailableConfiguration.ButtonConfiguration) -> Bool {
            lhs.hashValue == rhs.hashValue
        }

        public func hash(into hasher: inout Hasher) {
            hasher.combine(title)
            hasher.combine(atributedTitle)
            hasher.combine(image)
            hasher.combine(style)
            hasher.combine(contentTintColor)
            hasher.combine(symbolConfiguration)
            hasher.combine(isEnabled)
        }
    }

    @available(macOS 12.0, *)
    extension View {
        @ViewBuilder
        func buttonStyling(_ style: NSContentUnavailableConfiguration.ButtonConfiguration.Style) -> some View {
            switch style {
            case .plain: buttonStyle(.plain)
            case .borderless: buttonStyle(.borderless)
            case .bordered: buttonStyle(.bordered)
            case .link: buttonStyle(.link)
            }
        }
    }

    @available(macOS 12.0, *)
    public extension NSContentUnavailableConfiguration.ButtonConfiguration {
        struct ButtonStyle: Hashable {}
    }

#endif
