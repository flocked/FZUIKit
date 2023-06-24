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
    struct ButtonProperties {
        var title: String
        var atributedTitle: AttributedString? = nil
        var image: NSImage? = nil
        
        var isBordered: Bool = true
        var isTransparent: Bool = false
        
        var bezelStyle: NSButton.BezelStyle = .regularSquare
        var bezelColor: NSColor? = nil
        var contentTintColor: NSColor? = nil
        var symbolConfiguration: SymbolConfiguration? = nil
        var action: NSButton.ActionBlock
        
        var isEnabled: Bool = true
    }
}

@available(macOS 12.0, *)
extension NSContentUnavailableConfiguration.ButtonProperties: Hashable {
    public static func == (lhs: NSContentUnavailableConfiguration.ButtonProperties, rhs: NSContentUnavailableConfiguration.ButtonProperties) -> Bool {
        lhs.hashValue == rhs.hashValue
    }
    public func hash(into hasher: inout Hasher) {
        hasher.combine(title)
        hasher.combine(atributedTitle)
        hasher.combine(image)
        hasher.combine(isBordered)
        hasher.combine(isTransparent)
        hasher.combine(bezelStyle)
        hasher.combine(bezelColor)
        hasher.combine(contentTintColor)
        hasher.combine(symbolConfiguration)
        hasher.combine(isEnabled)
    }
}
#endif
