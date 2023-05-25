//
//  NSPopupButton.swift
//  FZCollection
//
//  Created by Florian Zand on 29.05.22.
//

#if os(macOS)
import AppKit
import Foundation

public extension NSPopUpButton {
    convenience init(items: [NSMenuItem], action: ActionBlock? = nil) {
        self.init()
        self.items = items
        actionBlock = action
    }

    convenience init(titles: [String], action: ActionBlock? = nil) {
        self.init()
        items = titles.compactMap { NSMenuItem($0) }
        actionBlock = action
    }

    convenience init(pullsDown: Bool = true, @MenuBuilder _ items: () -> [NSMenuItem]) {
        self.init()
        self.items = items()
    }

    var items: [NSMenuItem] {
        get {
            return menu?.items ?? []
        }
        set {
            if let menu = menu {
                let selectedItemTitle = titleOfSelectedItem
                menu.items = newValue
                if let selectedItemTitle = selectedItemTitle, let item = newValue.first(where: { $0.title == selectedItemTitle }) {
                    select(item)
                }
            } else {
                menu = NSMenu(items: newValue)
            }
        }
    }
}
#endif
