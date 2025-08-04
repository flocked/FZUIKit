//
//  NSWindowTabGroup+.swift
//
//
//  Created by Florian Zand on 02.09.22.
//

#if os(macOS)

import AppKit

public extension NSWindowTabGroup {
    /// The position to insert a window to the tab group.
    enum TabPosition {
        /// Before the selected tab.
        case beforeSelected
        /// After the selected tab.
        case afterSelected
        /// Before the specified window.
        case before(NSWindow)
        /// After the specified window.
        case after(NSWindow)
        /// At the beginning of the tab group.
        case atStart
        /// At the end of the tab group.
        case atEnd
        /// At the specified index.
        case atIndex(Int)
    }

    /**
     Inserts the specified window as tab.

     - Parameters:
        - window: The window to insert into the tab group.
        - position: The position in the tab group at which to insert window.
        - select: A Boolean value indicating whether to select the inserted tab.
     */
    func insertWindow(_ window: NSWindow, position: TabPosition = .afterSelected, select: Bool = true) {
        switch position {
        case .beforeSelected:
            if let index = indexOfSelectedTab {
                insertWindow(window, position: .atIndex(index), select: select)
            }
        case .afterSelected:
            if let index = indexOfSelectedTab {
                insertWindow(window, position: .atIndex(index+1), select: select)
            }
        case let .before(thisWindow):
            if let index = windows.firstIndex(of: thisWindow) {
                insertWindow(window, position: .atIndex(index), select: select)
            }
        case let .after(thisWindow):
            if let index = windows.firstIndex(of: thisWindow) {
                insertWindow(window, position: .atIndex(index+1), select: select)
            }
        case let .atIndex(index):
            if index >= 0, index <= windows.count {
                insertWindow(window, at: index)
                if select {
                    window.makeKeyAndOrderFront(nil)
                }
            }
        case .atStart:
            insertWindow(window, at: 0)
            if select {
                window.makeKeyAndOrderFront(nil)
            }
        case .atEnd:
            addWindow(window)
            if select {
                window.makeKeyAndOrderFront(nil)
            }
        }
    }

    /// The index of the selected tab, or `nil` if no tab is selected.
    var indexOfSelectedTab: Int? {
        if let selectedWindow = selectedWindow {
            return windows.firstIndex(of: selectedWindow)
        }
        return nil
    }

    /**
     Moves the specified tab to a new window.

     - Parameters:
        - tabWindow: The tab window.
        - orderFront: A Boolean value indicating whether the tab should be ordered to the front.
     */
    func moveTabToNewWindow(_ tabWindow: NSWindow, orderFront: Bool) {
        guard windows.count > 1, windows.contains(tabWindow) else { return }
        removeWindow(tabWindow)
        let newFrame = (windows.first?.frame ?? tabWindow.frame).offsetBy(dx: 10, dy: 10.0)
        tabWindow.setFrame(newFrame, display: orderFront)
        if orderFront {
            tabWindow.makeKeyAndOrderFront(nil)
        }
    }

    /// A collection of the windows that are currently grouped together by this window tab group excluding the selected.
    var nonSelectedWindows: [NSWindow] {
        var windows = windows
        if let selected = selectedWindow {
            windows.remove(selected)
        }
        return windows
    }
}

#endif
