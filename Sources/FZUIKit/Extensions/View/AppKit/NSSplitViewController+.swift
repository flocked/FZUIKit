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
         
         Changing this property animates the sidebar. If you don't want to animate the sidebar, use ``AppKit/NSSplitViewController/collapeSidebar(_:animated:)``.
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
         Collapses or expands the first sidebar in the split view controller using an animation.
         
         If the split view controller doesn’t contain a sidebar, calling this method does nothing.
         
         - Parameters:
            - shouldCollapse: A Boolean value that indicates whether the sidebar should collapse or expand.
            - animated: A Boolean value that indicates whether the sidebar the collapsing/expanding of the sidebar should be animated.
         
         */
        @objc public dynamic func collapeSidebar(_ shouldCollapse: Bool, animated: Bool = false) {
            guard splitViewItems.count > 1, let sidebarItem = splitViewItems.first, shouldCollapse != sidebarItem.isCollapsed else { return }
            if animated {
                toggleSidebar(nil)
            } else {
                sidebarItem.isCollapsed = shouldCollapse
            }

        }
    }

#endif
