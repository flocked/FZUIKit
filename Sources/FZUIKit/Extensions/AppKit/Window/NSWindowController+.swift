//
//  NSWindowController+.swift
//
//
//  Created by Florian Zand on 29.08.22.
//

#if os(macOS)
import AppKit
import FZSwiftUtils

public extension NSWindowController {
    /**
     Returns a window controller initialized with a given content view controller.

     - Parameter contentViewController: The content view controller.
     - Returns: A newly initialized window controller.
     */
    convenience init(contentViewController: NSViewController) {
        self.init(window: NSWindow(contentViewController: contentViewController))
        window?.title = contentViewController.title ?? "Untitled"
    }
    
    /**
     A Boolean value that indicates whether the window controller is retained until its window closes.
     
     Setting this property to `true`, disables the window's [isReleasedWhenClosed](https://developer.apple.com/documentation/appkit/nswindow/isreleasedwhenclosed), so the window remains owned by its controller instead of being released by `AppKit` during close.

     The retained controller is released automatically after the window closes.
     */
    var isRetainedUntilWindowCloses: Bool {
        get {
            Self.retainedWindowControllers[objectID] != nil
        }
        set {
            guard newValue != isRetainedUntilWindowCloses else { return }
            if newValue {
                guard let window = window, Self.retainedWindowControllers[objectID] == nil else { return }
                window.isReleasedWhenClosed = false
                let token = NotificationCenter.default.observe(NSWindow.willCloseNotification, postedBy: window) { [weak self] _ in
                    DispatchQueue.main.async { [weak self] in
                        guard let self = self else { return }
                        Self.retainedWindowControllers[self.objectID] = nil
                    }
                }
                Self.retainedWindowControllers[objectID] = (self, token)
            } else {
                Self.retainedWindowControllers[objectID] = nil
            }
        }
    }
    
    private static var retainedWindowControllers: [ObjectIdentifier: (windowController: NSWindowController, token: NotificationToken)]  {
        get { getAssociatedValue("retainedWindowControllers") ?? [:] }
        set { setAssociatedValue(newValue, key: "retainedWindowControllers") }
    }
}

#endif
