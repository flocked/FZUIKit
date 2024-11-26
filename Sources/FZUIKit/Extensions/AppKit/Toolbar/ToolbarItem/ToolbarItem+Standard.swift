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
            Item(.flexibleSpace)
        }

        /**
         A toolbar item that displays an empty space with a standard fixed size.

         The item can be used with ``Toolbar``.
         */
        static func space() -> Item {
            Item(.space)
        }

        /**
         A toolbar item that toggles a sidebar.

         The item can be used with ``Toolbar``.
         */
        static func toggleSidebar() -> Item {
            Item(.toggleSidebar)
        }

        /**
         A toolbar item that displays a tracking separator aligned with the sidebar divider in a split view.

         The item can be used with ``Toolbar``.
         */
        @available(macOS 11.0, *)
        static func sidebarTrackingSeparator() -> Item {
            Item(.sidebarTrackingSeparator)
        }
        
        /**
         A toolbar item that toggles a inspector pane.

         The item can be used with ``Toolbar``.
         */
        @available(macOS 14.0, *)
        static func toggleInspector() -> Item {
            Item(.toggleInspector)
        }
        
        /**
         A toolbar item that displays a tracking separator aligned with the inspector divider in a split view.

         The item can be used with ``Toolbar``.
         */
        @available(macOS 14.0, *)
        static func inspectorTrackingSeparator() -> Item {
            Item(.inspectorTrackingSeparator)
        }

        /**
         A toolbar item that tells your app to print the current document.

         The item can be used with ``Toolbar``.
         */
        static func print() -> Item {
            Item(.print)
        }

        /**
         A toolbar item that shows the standard color panel.

         The item can be used with ``Toolbar``.
         */
        static func showColors() -> Item {
            Item(.showColors)
        }

        /**
         A toolbar item that shows the standard font panel.

         The item can be used with ``Toolbar``.
         */
        static func showFonts() -> Item {
            Item(.showFonts)
        }

        /**
         A toolbar item that tells your app to display the iCloud sharing interface.

         The item can be used with ``Toolbar``.
         */
        static func cloudSharing() -> Item {
            Item(.cloudSharing)
        }
    }

#endif
