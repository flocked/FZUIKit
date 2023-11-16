//
//  ToolbarItem+Standard.swift
//
//
//  Created by Florian Zand on 09.04.23.
//

#if os(macOS)
import AppKit
import SwiftUI

public extension ToolbarItem {
    /**
     A toolbar item that displays an empty space with a flexible width.
     
     It can be used as an item of a ``Toolbar``.
     */
    static func FlexibleSpace() -> Item {
        return Item(.flexibleSpace)
    }

    /**
     A toolbar item that displays an empty space with a standard fixed size.
     
     It can be used as an item of a ``Toolbar``.
     */
    static func Space() -> Item {
        return Item(.space)
    }

    /**
     A toolbar item that displays a sidebar.
     
     It can be used as an item of a ``Toolbar``.
     */
    static func ToggleSidebar() -> Item {
        return Item(.toggleSidebar)
    }

    @available(macOS 11.0, *)
    /**
     A toolbar item that displays a tracking separator aligned with the sidebar divider in a split view.
     
     It can be used as an item of a ``Toolbar``.
     */
    static func SidebarTrackingSeparator() -> Item {
        return Item(.sidebarTrackingSeparator)
    }

    /**
     A toolbar item that tells your app to print the current document.
     
     It can be used as an item of a ``Toolbar``.
     */
    static func Print() -> Item {
        return Item(.print)
    }

    /**
     A toolbar item that shows the standard color panel.
     
     It can be used as an item of a ``Toolbar``.
     */
    static func ShowColors() -> Item {
        return Item(.showColors)
    }

    /**
     A toolbar item that shows the standard font panel.
     
     It can be used as an item of a ``Toolbar``.
     */
    static func ShowFonts() -> Item {
        return Item(.showFonts)
    }

    /**
     A toolbar item that tells your app to display the iCloud sharing interface.
     
     It can be used as an item of a ``Toolbar``.
     */
    static func CloudSharing() -> Item {
        return Item(.cloudSharing)
    }
}

#endif
