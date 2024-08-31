//
//  NSSplitViewController+.swift
//
//
//  Created by Florian Zand on 07.11.23.
//

#if os(macOS)
    import AppKit
import FZSwiftUtils

    extension NSSplitViewController {
        /**
         A Boolean value that indicates whether the sidebar is visible.
         
         If the split view doesn't contain a sidebar, it returns `false`.
         
         Changing this property animates the sidebar. If you don't want to animate the sidebar, use ``isSidebarVisible(_:animated:)``.
         */
       @objc public dynamic var isSidebarVisible: Bool {
            get {
                guard splitViewItems.count > 1, let sidebarItem = splitViewItems.first else { return false }
                return !sidebarItem.isCollapsed
            }
            set {
                guard splitViewItems.count > 1, let sidebarItem = splitViewItems.first, newValue != !sidebarItem.isCollapsed else { return }
                toggleSidebar(nil)
            }
        }
        
        /**
         Collapses or expands the first split view item.
         
         If the split view controller doesn’t contain a sidebar, calling this method does nothing.
         
         - Parameters:
            - isVisible: A Boolean value that indicates whether the sidebar is visible.
            - animated: A Boolean value that indicates whether the collapsing/expanding of the sidebar should be animated.
         */
        @discardableResult
        @objc open func isSidebarVisible(_ isVisible: Bool, animated: Bool = true) -> Self {
            if animated {
                self.isSidebarVisible = isVisible
            } else if splitViewItems.count > 1, let sidebarItem = splitViewItems.first {
                sidebarItem.isCollapsed = !isVisible
            }
            return self
        }
    }

#endif
