//
//  TabService.swift
//
//
//  Created by Florian Zand on 17.06.23.
//

#if os(macOS)

import AppKit
import FZSwiftUtils

/// A window controller that can create tabs.
public protocol TabbableWindowController: NSWindowController {
    /// The object that manages the tabs.
    var tabService: TabService<Self>? { get set }
    /// Creates a new window controller.
    static func createNew() -> Self
}

/// TabService manages the tabs of an window controller.
public class TabService<WindowController: TabbableWindowController> {
    public struct ManagedWindow {
        /// Keep the controller around to store a strong reference to it
        public let windowController: WindowController
        
        /// Keep the window around to identify instances of this type
        public let window: NSWindow
        
        /// React to window closing, auto-unsubscribing on dealloc
        public let closingSubscription: NotificationToken
    }
    
    public fileprivate(set) var managedWindows: [ManagedWindow] = []
    
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
    
    /**
     Creates an tab service object for the specified window controller.
     - Parameter initialWindowController: The window controller for managing the tabs.
     - Returns: The tab service object.
     */
    public init(initialWindowController: WindowController) {
        precondition(addManagedWindow(windowController: initialWindowController) != nil)
        initialWindowController.tabService = self
    }
    
    /**
     Creates a new tab.
     
     - Parameter presentTab:  A Boolean value the tab should be presented.
     */
    public func createTab(presentTab: Bool = true) {
        guard let window = self.mainWindow else { return }
        let newWindowController = WindowController.createNew()
         guard let newWindow = addManagedWindow(windowController: newWindowController)?.window else { preconditionFailure() }
        window.addTabbedWindow(newWindow, ordered: .above)
        if presentTab {
            newWindow.makeKeyAndOrderFront(nil)
        }
    }

    private func addManagedWindow(windowController: WindowController) -> ManagedWindow? {

        guard let window = windowController.window else { return nil }
        
        let subscription = NotificationCenter.default.observe(name: NSWindow.willCloseNotification, object: window) { [unowned self] notification in
            guard let window = notification.object as? NSWindow else { return }
            guard window != self.mainWindow else { return }
            self.removeManagedWindow(forWindow: window)
        }
        let management = ManagedWindow(
            windowController: windowController,
            window: window,
            closingSubscription: subscription)
        managedWindows.append(management)

        windowController.tabService = self

        return management
    }

    private func removeManagedWindow(forWindow window: NSWindow) {
        managedWindows.removeAll(where: { $0.window === window })
    }
}

#endif
