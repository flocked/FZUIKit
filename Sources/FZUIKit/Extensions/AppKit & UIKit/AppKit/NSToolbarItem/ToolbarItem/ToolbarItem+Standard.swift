//
//  File.swift
//
//
//  Created by Florian Zand on 09.04.23.
//

#if os(macOS)
    import Cocoa
    import SwiftUI

    public extension ToolbarItem {
        static func FlexibleSpace() -> Item {
            return Item(.flexibleSpace)
        }

        static func Space() -> Item {
            return Item(.space)
        }

        static func ToggleSidebar() -> Item {
            return Item(.toggleSidebar)
        }

        @available(macOS 11.0, *)
        static func SidebarTrackingSeparator() -> Item {
            return Item(.sidebarTrackingSeparator)
        }

        static func Print() -> Item {
            return Item(.print)
        }

        static func ShowColors() -> Item {
            return Item(.showColors)
        }

        static func ShowFonts() -> Item {
            return Item(.showFonts)
        }

        static func CloudSharing() -> Item {
            return Item(.cloudSharing)
        }
    }

#endif
