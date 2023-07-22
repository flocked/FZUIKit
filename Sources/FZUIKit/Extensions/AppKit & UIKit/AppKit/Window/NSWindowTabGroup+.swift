//
//  NSWindowTabGroup+.swift
//
//
//  Created by Florian Zand on 02.09.22.
//

#if os(macOS)

import Cocoa

public extension NSWindowTabGroup {
    enum TabInsertionType {
        case before(NSWindow)
        case after(NSWindow)
        case atStart
        case atEnd
        case afterCurrent
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

    func insertWindow(_ window: NSWindow, _ insertionType: TabInsertionType = .atEnd) {
        switch insertionType {
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

    func indexOfWindow(_ window: NSWindow) -> Int? {
        return windows.firstIndex(of: window)
    }

    var indexOfSelectedTab: Int? {
        if let selectedWindow = selectedWindow {
            return indexOfWindow(selectedWindow)
        }
        return nil
    }
}

#endif
