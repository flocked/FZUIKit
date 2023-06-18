//
//  File.swift
//
//
//  Created by Florian Zand on 10.04.23.
//

#if os(macOS)
import AppKit
import FZSwiftUtils

public extension NSStatusItem {
    func onClick(_ onClick: NSButton.ActionBlock?, rightClick: NSButton.ActionBlock?) {
        
    }
    
    var onClick: NSButton.ActionBlock? {
        get { getAssociatedValue(key: "_statusItemActionBlock", object: self, initialValue: nil) }
        set { associatedValue.set(newValue, key: "_statusItemActionBlock")
            updateAction()
        }
    }

    var onRightClick: NSButton.ActionBlock? {
        get { getAssociatedValue(key: "_statusItemActionBlock", object: self, initialValue: nil) }
        set { associatedValue.set(newValue, key: "_statusItemActionBlock")
            updateAction()
        }
    }

    internal func updateAction() {
        var mask: NSEvent.EventTypeMask = []
        if onClick != nil {
            mask.insert(.leftMouseUp)
        }

        if onRightClick != nil {
            mask.insert(.rightMouseUp)
        }

        button?.sendAction(on: mask)
        button?.actionBlock = { [weak self] button in
            guard let self = self else { return }
            let event = NSApp.currentEvent!
            if let onRightClick = self.onRightClick, event.type == .rightMouseUp {
                onRightClick(button)
            } else if event.type == .leftMouseUp, let onClick = self.onClick {
                onClick(button)
            }
        }
    }

    convenience init(title: String, menu: NSMenu) {
        self.init()
        button?.title = title
        self.menu = menu
    }

    convenience init(title: String, @MenuBuilder _ items: () -> [NSMenuItem]) {
        self.init(title: title, menu: NSMenu(items: items()))
    }

    convenience init(title: String, action: @escaping NSButton.ActionBlock) {
        self.init()
        button?.title = title
        onClick = action
    }

    convenience init(image: NSImage, menu: NSMenu) {
        self.init()
        button?.image = image
        self.menu = menu
    }

    convenience init(image: NSImage, @MenuBuilder _ items: () -> [NSMenuItem]) {
        self.init(image: image, menu: NSMenu(items: items()))
    }

    convenience init(image: NSImage, action: @escaping NSButton.ActionBlock) {
        self.init()
        button?.image = image
        onClick = action
    }

    @available(macOS 11.0, *)
    convenience init?(symbolName: String, @MenuBuilder _ items: () -> [NSMenuItem]) {
        guard let image = NSImage(systemSymbolName: symbolName) else { return nil }
        self.init()
        button?.image = image
        menu = NSMenu(items: items())
    }

    @available(macOS 11.0, *)
    convenience init?(symbolName: String, action: @escaping NSButton.ActionBlock) {
        guard let image = NSImage(systemSymbolName: symbolName) else { return nil }
        self.init()
        button?.image = image
        onClick = action
    }
}
#endif
