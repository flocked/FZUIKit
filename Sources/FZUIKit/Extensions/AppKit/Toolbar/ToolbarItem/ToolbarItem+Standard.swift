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
     
     The item can be used with ``Toolbar``.
     */
    static func flexibleSpace() -> Item {
        return Item(.flexibleSpace)
    }

    /**
     A toolbar item that displays an empty space with a standard fixed size.
     
     The item can be used with ``Toolbar``.
     */
    static func space() -> Item {
        return Item(.space)
    }

    /**
     A toolbar item that displays a sidebar.
     
     The item can be used with ``Toolbar``.
     */
    static func toggleSidebar() -> Item {
        return Item(.toggleSidebar)
    }

    @available(macOS 11.0, *)
    /**
     A toolbar item that displays a tracking separator aligned with the sidebar divider in a split view.
     
     The item can be used with ``Toolbar``.
     */
    static func sidebarTrackingSeparator() -> Item {
        return Item(.sidebarTrackingSeparator)
    }

    /**
     A toolbar item that tells your app to print the current document.
     
     The item can be used with ``Toolbar``.
     */
    static func print() -> Item {
        return Item(.print)
    }

    /**
     A toolbar item that shows the standard color panel.
     
     The item can be used with ``Toolbar``.
     */
    static func showColors() -> Item {
        return Item(.showColors)
    }

    /**
     A toolbar item that shows the standard font panel.
     
     The item can be used with ``Toolbar``.
     */
    static func showFonts() -> Item {
        return Item(.showFonts)
    }

    /**
     A toolbar item that tells your app to display the iCloud sharing interface.
     
     The item can be used with ``Toolbar``.
     */
    static func cloudSharing() -> Item {
        return Item(.cloudSharing)
    }
}

#endif
