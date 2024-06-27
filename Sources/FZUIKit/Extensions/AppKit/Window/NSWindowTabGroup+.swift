//
//  NSWindowTabGroup+.swift
//
//
//  Created by Florian Zand on 02.09.22.
//

#if os(macOS)

    import AppKit

    public extension NSWindowTabGroup {
        /// A collection of the windows that are currently grouped together by this window tab group excluding the selected.
        var nonSelectedWindows: [NSWindow] {
            var windows = windows
            if let index = indexOfSelectedTab {
                windows.remove(at: index)
            }
            return windows
        }
        
        /// The position of an inserted tab.
        enum TabPosition {
            /// Inserts the tab before the specified window.
            case before(NSWindow)
            /// Inserts the tab after the specified window.
            case after(NSWindow)
            /// Inserts the tab at the beginning of the tab group.
            case atStart
            /// Inserts the tab at the end of the tab group.
            case atEnd
            /// Inserts the tab after the current tab.
            case afterCurrent
            /// Inserts the tab before the current tab.
            case beforeCurrent
            /// Inserts the tab at the specified index.
            case atIndex(Int)
        }

        func moveTabToNewWindow(_ tabWindow: NSWindow, makeKeyAndOrderFront: Bool) {
            if windows.contains(tabWindow), windows.count > 1 {
                removeWindow(tabWindow)
                var newFrame = windows.first?.frame ?? tabWindow.frame
                newFrame.origin = CGPoint(x: newFrame.origin.x + 10.0, y: newFrame.origin.y + 10.0)
                tabWindow.setFrame(newFrame, display: makeKeyAndOrderFront)
                if makeKeyAndOrderFront {
                    tabWindow.makeKeyAndOrderFront(nil)
                }
            }
        }

        /**
         Inserts the specified window as tab.
         
         - Parameters:
            - window: The window to insert.
            - position: A value that indicates the position of the added tab.
            - select: A Boolean value that indicates whether to select the inserted tab.
         */
        func insertWindow(_ window: NSWindow, position: TabPosition = .afterCurrent, select: Bool = true) {
            switch position {
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
            case let .before(thisWindow):
                if let foundIndex = indexOfWindow(thisWindow) {
                    insertWindow(window, at: foundIndex)
                } else {
                    addWindow(window)
                }
                if select {
                    window.makeKeyAndOrderFront(nil)
                }
            case let .after(thisWindow):
                if let foundIndex = indexOfWindow(thisWindow) {
                    insertWindow(window, at: foundIndex + 1)
                } else {
                    addWindow(window)
                }
                if select {
                    window.makeKeyAndOrderFront(nil)
                }
            case let .atIndex(index):
                if index >= 0, index <= windows.count {
                    insertWindow(window, at: index)
                    if select {
                        window.makeKeyAndOrderFront(nil)
                    }
                }
            case .afterCurrent:
                if let index = indexOfSelectedTab {
                    insertWindow(window, at: index + 1)
                    if select {
                        window.makeKeyAndOrderFront(nil)
                    }
                }
            case .beforeCurrent:
                if let index = indexOfSelectedTab {
                    insertWindow(window, at: index)
                    if select {
                        window.makeKeyAndOrderFront(nil)
                    }
                }
            }
        }

        /// The tab index of the specified window, or `nil` if the window isn't a tab.
        func indexOfWindow(_ window: NSWindow) -> Int? {
            windows.firstIndex(of: window)
        }

        /// The index of the selected tab, or `nil` if no tab is selected.
        var indexOfSelectedTab: Int? {
            if let selectedWindow = selectedWindow {
                return indexOfWindow(selectedWindow)
            }
            return nil
        }
    }

#endif
