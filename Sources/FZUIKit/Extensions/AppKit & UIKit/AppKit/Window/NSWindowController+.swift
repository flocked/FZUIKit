//
//  File.swift
//
//
//  Created by Florian Zand on 29.08.22.
//

#if os(macOS)
import AppKit

public extension NSWindowController {
    convenience init(contentViewController: NSViewController) {
        self.init(window: NSWindow(contentViewController: contentViewController))
        window?.title = contentViewController.title ?? "Untitled"
    }
}

#endif
