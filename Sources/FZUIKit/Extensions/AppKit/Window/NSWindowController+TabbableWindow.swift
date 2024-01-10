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
 
 The default implementation of ``createNew()-swift.type.method`` tries to create a new window controller from either the main storyboard or a nib named as the window controller and fails if it couldn't be created.
 */
public protocol TabbableWindow: NSWindowController {
    /// Creates a new window controller.
    static func createNew() -> Self
}

extension TabbableWindow {
    static public func createNew() -> Self {
        let windowController = Self.loadFromNib() ?? Self.loadFromStoryboard()
        if let windowController = windowController {
            return windowController
        } else {
            assertionFailure("The window controller couldn't be created from the main storyboard or a nib named as the window controller. Provide your own createNew() implementation.")
            return windowController!
        }
    }

    /**
     Creates a new tab if the `window` is the main window.
     
     - Parameter presentTab:  A Boolean value the tab should be presented.
     */
    public func createTab(presentTab: Bool) {
        TabService.shared.createTab(for: self, presentTab: presentTab)
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
    /// Falls back the first element if no window is main. Note that this would
    /// likely be an internal inconsistency we gracefully handle here.
    var mainWindow: NSWindow? {
        let mainManagedWindow = managedWindows
            .first { $0.window.isMainWindow }

        // In case we run into the inconsistency, let it crash in debug mode so we
        // can fix our window management setup to prevent this from happening.
        // assert(mainManagedWindow != nil || managedWindows.isEmpty)

        return (mainManagedWindow ?? managedWindows.first)
            .map { $0.window }
    }

    /// Creates an tab service object.
    init() {

    }

    /**
     Creates a new tab.
     
     - Parameter presentTab:  A Boolean value the tab should be presented.
     */
    func createTab<WC: TabbableWindow>(for windowController: WC, presentTab: Bool = true) {
        let mainWindow = self.mainWindow
        let newWindowController = WC.createNew()
         guard let newWindow = addManagedWindow(windowController: newWindowController)?.window else { preconditionFailure() }
        if let mainWindow = mainWindow {
            mainWindow.addTabbedWindow(newWindow, ordered: .above)
        }
        if presentTab {
            newWindow.makeKeyAndOrderFront(nil)
        }
    }

    private func addManagedWindow(windowController: NSWindowController) -> ManagedWindow? {

        guard let window = windowController.window else { return nil }

        let subscription = NotificationCenter.default.observe(NSWindow.willCloseNotification, object: window) { [unowned self] notification in
            guard let window = notification.object as? NSWindow else { return }
            self.removeManagedWindow(forWindow: window)
        }
        let management = ManagedWindow(
            windowController: windowController,
            window: window,
            closingSubscription: subscription)
        managedWindows.append(management)

        return management
    }

    private func removeManagedWindow(forWindow window: NSWindow) {
        managedWindows.removeAll(where: { $0.window === window })
    }
}

#endif
