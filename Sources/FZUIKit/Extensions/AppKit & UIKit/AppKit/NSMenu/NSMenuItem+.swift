//
//  File.swift
//
//
//  Created by Florian Zand on 09.04.23.
//

#if os(macOS)

    import AppKit
    import Foundation
    import SwiftUI

    public extension NSMenuItem {
        convenience init(_ title: String) {
            self.init(title: title)
        }

        convenience init(title: String) {
            self.init(title: title, action: nil, keyEquivalent: "")
            isEnabled = true
        }

        convenience init(image: NSImage) {
            self.init(title: "")
            self.image = image
        }

        convenience init(view: NSView, showsHighlight: Bool = true) {
            self.init(title: "")
            if showsHighlight {
                let highlightableView = NSMenuItemHighlightableView(frame: view.frame)
                highlightableView.addSubview(withConstraint: view)
                self.view = highlightableView
            } else {
                self.view = view
            }
        }

        convenience init<V: View>(view: V, showsHighlight: Bool = true) {
            self.init(title: "")
            self.view = NSMenu.MenuItemView(showsHighlight: showsHighlight, view)
        }

        convenience init(title: String,
                         @MenuBuilder builder: () -> [NSMenuItem])
        {
            self.init(title: title)
            submenu = NSMenu(title: "", items: builder())
        }
    }
#endif
