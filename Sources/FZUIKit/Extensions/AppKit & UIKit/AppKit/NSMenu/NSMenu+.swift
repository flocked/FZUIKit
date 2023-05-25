//
//  NSMenu+.swift
//  FZExtensions
//
//  Created by Florian Zand on 06.06.22.
//

#if os(macOS)

import AppKit
import Foundation

public extension NSMenu {
    convenience init(items: [NSMenuItem]) {
        self.init(title: "", items: items)
    }

    convenience init(title: String, items: [NSMenuItem]) {
        self.init(title: title)
        self.items = items
    }

    convenience init(titles: [String]) {
        self.init()
        for title in titles {
            addItem(NSMenuItem(title))
        }
    }
}

#endif
