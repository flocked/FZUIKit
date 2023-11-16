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
    /// A toolbar item that displays an empty space with a flexible width.
    static func FlexibleSpace() -> Item {
        return Item(.flexibleSpace)
    }

    /// A toolbar item that displays an empty space with a standard fixed size.
    static func Space() -> Item {
        return Item(.space)
    }

    /// A toolbar item that displays a sidebar.
    static func ToggleSidebar() -> Item {
        return Item(.toggleSidebar)
    }

    @available(macOS 11.0, *)
    static func SidebarTrackingSeparator() -> Item {
        return Item(.sidebarTrackingSeparator)
    }

    /// A toolbar item that tells your app to print the current document.
    static func Print() -> Item {
        return Item(.print)
    }

    /// A toolbar item that shows the standard color panel.
    static func ShowColors() -> Item {
        return Item(.showColors)
    }

    /// A toolbar item that shows the standard font panel.
    static func ShowFonts() -> Item {
        return Item(.showFonts)
    }

    /// A toolbar item that tells your app to display the iCloud sharing interface.
    static func CloudSharing() -> Item {
        return Item(.cloudSharing)
    }
}

#endif
