//
//  ButtonProperties.swift
//  NSContentUnavailableConfiguration
//
//  Created by Florian Zand on 24.06.23.
//

#if os(macOS)
import AppKit
import SwiftUI
import FZSwiftUtils

@available(macOS 12.0, *)
public extension NSContentUnavailableConfiguration {
    struct ButtonConfiguration {
        internal enum Style: Hashable {
            case plain
            case borderless
            case bordered
            case link
        }
        
        var title: String?
        var atributedTitle: AttributedString? = nil
        var image: NSImage? = nil
        
        var action: (()->())
        var isEnabled: Bool = true
        
        var contentTintColor: NSColor? = nil
        var style: Style = .bordered
        var symbolConfiguration: SymbolConfiguration? = nil
        
        internal var hasContent: Bool {
            (self.title != nil || self.atributedTitle != nil || self.image != nil)
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
internal extension View {
    @ViewBuilder
    func buttonStyling(_ style: NSContentUnavailableConfiguration.ButtonConfiguration.Style) -> some View {
        switch style {
        case .plain: self.buttonStyle(.plain)
        case .borderless: self.buttonStyle(.borderless)
        case .bordered: self.buttonStyle(.bordered)
        case .link: self.buttonStyle(.link)
        }
    }
}

@available(macOS 12.0, *)
public extension NSContentUnavailableConfiguration.ButtonConfiguration {
    struct ButtonStyle: Hashable {
        
    }
}

#endif
