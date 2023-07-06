//
//  File.swift
//  
//
//  Created by Florian Zand on 06.07.23.
//

#if os(macOS)
import AppKit

public extension NSViewController {
    static func windowController() -> NSWindowController {
        let viewController = Self()
        let window = NSWindow(contentViewController: viewController)
        window.center()
        let windowController = NSWindowController(window: window)
        return windowController
    }
}

#endif
