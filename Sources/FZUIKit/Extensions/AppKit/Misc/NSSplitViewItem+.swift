//
//  NSSplitViewItem+.swift
//  
//
//  Created by Florian Zand on 04.07.25.
//

#if os(macOS)
import AppKit

extension NSSplitViewItem {
    /// Creates a split view item that represents a sidebar for the specified view controller.
    public class func sidebar(_ viewController: NSViewController) -> Self {
        Self(sidebarWithViewController: viewController)
    }
    
    /// Creates a split view item that represents a content list for the specified view controller.
    public class func contentList(_ viewController: NSViewController) -> Self {
        Self(contentListWithViewController: viewController)
    }
    
    /// Creates a split view item that represents a content list for the specified view controller.
    public class func `default`(_ viewController: NSViewController) -> Self {
        Self(viewController: viewController)
    }
    
    /// Creates a split view item that represents a inspector for the specified view controller.
    @available(macOS 11.0, *)
    public class func inspector(_ viewController: NSViewController) -> Self {
        Self(inspectorWithViewController: viewController)
    }
}

#endif
