//
//  ToolbarItem+Standard.swift
//
//
//  Created by Florian Zand on 09.04.23.
//

#if os(macOS)
import AppKit

public extension Toolbar {
    /// A toolbar item that displays an empty space with a flexible width.
    static func flexibleSpace() -> ToolbarItem {
        ToolbarItem(standard: .flexibleSpace)
    }
    
    /// A toolbar item that displays an empty space with a standard fixed size.
    static func space() -> ToolbarItem {
        ToolbarItem(standard: .space)
    }
    
    /**
     A toolbar item that toggles a sidebar.
     
     The item sends `toggleSidebar(_:)` to the first responder.
     */
    static func toggleSidebar() -> ToolbarItem {
        ToolbarItem(standard: .toggleSidebar)
    }
    
    /**
     A toolbar item that displays a tracking separator aligned with the sidebar divider in a split view.
     
     The item’s tracking separator visually aligns itself with the sidebar divider of a vertical split view in the same window.
     */
    static func sidebarTrackingSeparator() -> ToolbarItem {
        ToolbarItem(standard: .sidebarTrackingSeparator)
    }
    
    /**
     A toolbar item that toggles a inspector pane.
     
     The item sends `toggleInspector(_:)` to the first responder.
     */
    @available(macOS 14.0, *)
    static func toggleInspector() -> ToolbarItem {
        ToolbarItem(standard: .toggleInspector)
    }
    
    /**
     A toolbar item that displays a tracking separator aligned with the inspector divider in a split view.
     
     The item’s tracking separator visually aligns itself with the inspector divider of a vertical split view in the same window.
     */
    @available(macOS 14.0, *)
    static func inspectorTrackingSeparator() -> ToolbarItem {
        ToolbarItem(standard: .inspectorTrackingSeparator)
    }
    
    /**
     A toolbar item that tells your app to print the current document.
     
     The item sends `printDocument(_:)` to the first responder.
     */
    static func print() -> ToolbarItem {
        ToolbarItem(standard: .print)
    }
    
    /// A toolbar item that shows the standard color panel.
    static func showColors() -> ToolbarItem {
        ToolbarItem(standard: .showColors)
    }
    
    /// A toolbar item that shows the standard font panel.
    static func showFonts() -> ToolbarItem {
        ToolbarItem(standard: .showFonts)
    }
    
    /// A toolbar item that tells your app to display the iCloud sharing interface.
    static func cloudSharing() -> ToolbarItem {
        ToolbarItem(standard: .cloudSharing)
    }
    
    /**
     A toolbar item that shows writing tools.
     
     The item sends `showWritingTools(_:)` to the first responder.
     */
    @available(macOS 15.2, *)
    static func writingTools() -> ToolbarItem {
        ToolbarItem(standard: "NSToolbarWritingToolsItem")
    }
}

#endif
