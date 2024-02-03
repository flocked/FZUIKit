//
//  NSSplitViewController+.swift
//
//
//  Created by Florian Zand on 07.11.23.
//

#if os(macOS)
    import AppKit

    public extension NSSplitViewController {
        /**
         A Boolean value that indicates whether the sidebar is visible.
         
         If the split view doesn't contain a sidebar, it returns `false`.
         */
        var isSidebarVisible: Bool {
            get {
                guard splitViewItems.count > 1, let sidebarItem = splitViewItems.first else { return false }
                return !sidebarItem.isCollapsed
            }
            set {
                guard splitViewItems.count > 1, let sidebarItem = splitViewItems.first, newValue != !sidebarItem.isCollapsed else { return }
                toggleSidebar(nil)
            }
        }
    }

#endif
