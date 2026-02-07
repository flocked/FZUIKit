//
//  NSWindowController+TabbableWindow.swift
//
//
//  Created by Florian Zand on 17.06.23.
//

#if os(macOS)

import AppKit
import FZSwiftUtils

/**
 A window controller that can create window tabs.

 The default implementation of ``create()-13q4p`` tries to create a new window controller from either the main storyboard or a nib named as the window controller and fails if it couldn't be created.
 */
public protocol TabbableWindow: NSWindowController {
    /// Creates a new window controller.
    static func create() -> Self
}

public extension TabbableWindow {
    static func create() -> Self {
        let windowController = Self.loadFromNib() ?? Self.loadFromStoryboard()
        if let windowController = windowController {
            return windowController
        } else {
            assertionFailure("The window controller couldn't be created from the main storyboard or a nib named as the window controller. Provide your own createNew() implementation.")
            return windowController!
        }
    }

    /**
     Creates a new tab.

     - Parameter select:  A Boolean value the tab should be presented.
     */
    func createTab(select: Bool) {
        guard let window = window else { return }
        let windowController = Self.create()
        guard let newWindow = windowController.window else { return }
        TabService.shared.addManagedWindow(windowController: windowController)
        window.addTabbedWindow(newWindow, ordered: .above)
        if select {
            newWindow.makeKeyAndOrderFront(nil)
        }
    }
}

/// TabService manages the tabs of an window controller.
class TabService {
    struct ManagedWindow {
        /// Keep the controller around to store a strong reference to it
        public let windowController: NSWindowController

        /// Keep the window around to identify instances of this type
        public let window: NSWindow

        /// React to window closing, auto-unsubscribing on dealloc
        public let closingSubscription: NotificationToken
    }

    static let shared = TabService()

    fileprivate(set) var managedWindows: [ManagedWindow] = []

    /// Returns the main window of the managed window stack.
    var mainWindow: NSWindow? {
        (managedWindows.first { $0.window.isMainWindow } ?? managedWindows.first)?.window
    }

    func addManagedWindow(windowController: NSWindowController) {
        guard let window = windowController.window else { return }

        let subscription = NotificationCenter.default.observe(NSWindow.willCloseNotification, postedBy: window) { [weak self] notification in
            guard let self = self else { return }
            self.managedWindows.removeAll(where: { $0.window === window })
        }

        managedWindows += ManagedWindow(windowController: windowController, window: window, closingSubscription: subscription
        )
    }
}

#endif
