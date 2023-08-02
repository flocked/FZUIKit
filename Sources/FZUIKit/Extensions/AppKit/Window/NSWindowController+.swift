//
//  NSWindowController+.swift
//
//
//  Created by Florian Zand on 29.08.22.
//

#if os(macOS)
import AppKit

public extension NSWindowController {
    /**
     Returns a window controller initialized with a given content view controller.

     - Parameters contentViewController: The content view controller.
     - Returns: A newly initialized window controller.
     */
    convenience init(contentViewController: NSViewController) {
        self.init(window: NSWindow(contentViewController: contentViewController))
        window?.title = contentViewController.title ?? "Untitled"
    }
}

#endif
