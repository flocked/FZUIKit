//
//  ToolbarItem+Standard.swift
//
//
//  Created by Florian Zand on 09.04.23.
//

#if os(macOS)
import AppKit

public extension ToolbarItem {
    /// A toolbar item that displays an empty space with a flexible width.
    static func flexibleSpace() -> Item {
        Item(.flexibleSpace)
    }
    
    /// A toolbar item that displays an empty space with a standard fixed size.
    static func space() -> Item {
        Item(.space)
    }
    
    /**
     A toolbar item that toggles a sidebar.
     
     The item sends `toggleSidebar` to the first responder.
     */
    static func toggleSidebar() -> Item {
        Item(.toggleSidebar)
    }
    
    /**
     A toolbar item that displays a tracking separator aligned with the sidebar divider in a split view.
     
     The item’s tracking separator visually aligns itself with the sidebar divider of a vertical split view in the same window.
     */
    @available(macOS 11.0, *)
    static func sidebarTrackingSeparator() -> Item {
        Item(.sidebarTrackingSeparator)
    }
    
    /**
     A toolbar item that toggles a inspector pane.
     
     The item sends `toggleInspector` to the first responder.
     */
    @available(macOS 14.0, *)
    static func toggleInspector() -> Item {
        Item(.toggleInspector)
    }
    
    /**
     A toolbar item that displays a tracking separator aligned with the inspector divider in a split view.
     
     The item’s tracking separator visually aligns itself with the inspector divider of a vertical split view in the same window.
     */
    @available(macOS 14.0, *)
    static func inspectorTrackingSeparator() -> Item {
        Item(.inspectorTrackingSeparator)
    }
    
    /// A toolbar item that tells your app to print the current document.
    static func print() -> Item {
        Item(.print)
    }
    
    /// A toolbar item that shows the standard color panel.
    static func showColors() -> Item {
        Item(.showColors)
    }
    
    /// A toolbar item that shows the standard font panel.
    static func showFonts() -> Item {
        Item(.showFonts)
    }
    
    /// A toolbar item that tells your app to display the iCloud sharing interface.
    static func cloudSharing() -> Item {
        Item(.cloudSharing)
    }
    
    /**
     A toolbar item that shows writing tools.
     
     The item sends `showWritingTools` to the first responder.
     
     - Note: The item is only available on `macOS 15.2`.
     */
    static func writingTools() -> Item {
        Item(.init("NSToolbarWritingToolsItem"))
    }
}

#endif
