//
//  File.swift
//
//
//  Created by Florian Zand on 24.10.22.
//

#if os(macOS)
import AppKit

@available(macOS 11.0, *)
public extension NSTintConfiguration {
    var tintColor: NSColor? { value(forKey: "tintColor") as? NSColor }

    var sidebarRowTintColor: NSColor? { value(forKey: "_sidebarRowTintColor") as? NSColor }
}
#endif
