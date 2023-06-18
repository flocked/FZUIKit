//
//  File.swift
//  
//
//  Created by Florian Zand on 18.06.23.
//

import AppKit
import FZSwiftUtils

public enum MouseClickType: Int {
    case left
    case right
}

internal class MouseClickActionTrampoline<T: NSControl>: NSObject {
    var action: (T, MouseClickType) -> Void

    init(action: @escaping (T, MouseClickType) -> Void) {
        self.action = action
    }

    @objc func performAction(sender: NSObject) {
        var clickType: MouseClickType = .left
        if let event = NSApp.currentEvent {
            if event.type == .rightMouseUp || event.type == .rightMouseDown {
                clickType = .right
            }
        }
        
        if let sender = sender as? T {
            action(sender, clickType)
        }
    }
}

public extension NSControl {
    typealias MouseClickActionBlock = (NSButton, MouseClickType) -> ()
    
    var mouseClickActionBlock: MouseClickActionBlock? {
        get { getAssociatedValue(key: "_mouseClickActionBlock", object: self, initialValue: nil) }
        set {
            guard let newValue = newValue else {
                set(associatedValue: newValue, key: "_mouseClickActionBlock", object: self)
                return
            }
                let trampoline = MouseClickActionTrampoline<NSButton>(action: newValue)
                self.target = trampoline
                self.action = #selector(trampoline.performAction(sender:))
                set(associatedValue: newValue, key: "_mouseClickActionBlock", object: self)
            }
        }
    }
