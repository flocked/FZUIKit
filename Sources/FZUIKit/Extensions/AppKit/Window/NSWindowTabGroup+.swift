//
//  NSWindowTabGroup+.swift
//
//
//  Created by Florian Zand on 02.09.22.
//

#if os(macOS)

    import AppKit

    public extension NSWindowTabGroup {
        
        /// The mode how to insert a window as tab.
        enum TabInsertionMode {
            /// Inserts the window before the specified window.
            case before(NSWindow)
            /// Inserts the window after the specified window.
            case after(NSWindow)
            /// Inserts the window at the beginning of the tab group.
            case atStart
            /// Inserts the window at the end of the tab group.
            case atEnd
            /// Inserts the window after the current tab.
            case afterCurrent
            /// Inserts the window at the specified index.
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
            - insertionMode: The option how to insert the window. The default value is `afterCurrent`.
         */
        func insertWindow(_ window: NSWindow, _ insertionMode: TabInsertionMode = .afterCurrent) {
            switch insertionMode {
            case .atStart:
                insertWindow(window, at: 0)
            case .atEnd:
                addWindow(window)
            case let .before(thisWindow):
                if let foundIndex = indexOfWindow(thisWindow) {
                    insertWindow(window, at: foundIndex)
                } else {
                    addWindow(window)
                }
            case let .after(thisWindow):
                if let foundIndex = indexOfWindow(thisWindow) {
                    insertWindow(window, at: foundIndex + 1)
                } else {
                    addWindow(window)
                }
            case let .atIndex(index):
                if index >= 0, index <= windows.count {
                    insertWindow(window, at: index)
                }
            case .afterCurrent:
                if let index = indexOfSelectedTab {
                    insertWindow(window, at: index + 1)
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
