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
        struct ButtonConfiguration {
            public enum Style: Hashable {
                case plain
                case borderless
                case bordered
                case link
            }

            public var title: String?
            public var atributedTitle: AttributedString?
            public var image: NSImage?

            public var action: () -> Void
            public var isEnabled: Bool = true

            public var contentTintColor: NSColor?
            public var style: Style = .bordered
            public var symbolConfiguration: SymbolConfiguration?

            public typealias SymbolConfiguration = ImageSymbolConfiguration

            var hasContent: Bool {
                title != nil || atributedTitle != nil || image != nil
            }

            public static func titleButton(_ title: String, font _: SymbolConfiguration.FontConfiguration = .body, action: @escaping (() -> Void)) -> Self {
                Self(title: title, action: action)
            }

            public static func imageButton(_ image: NSImage, action: @escaping (() -> Void)) -> Self {
                Self(image: image, action: action)
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
