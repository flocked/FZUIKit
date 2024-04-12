//
//  NSMenu+AnyMenuItem.swift
//
//
//  Created by Florian Zand on 08.06.23.
//
/*
#if os(macOS)
    import AppKit
    #if canImport(SwiftUI)
        import SwiftUI
    #endif

    /// Modifiers used to customize a ``MenuItem`` or ``CustomMenuItem``.
    public protocol AnyMenuItem {
        typealias ActionBlock = (Item) -> Void
        associatedtype Item: NSMenuItem

        /// Calls the given `modifier` to prepare the menu item for display.
        func apply(_ modifier: @escaping (Item) -> Void) -> Self
    }

    public extension AnyMenuItem {
        // MARK: Behavior

        /// Runs a closure when the menu item is selected.
        func onSelect(_ handler: @escaping () -> Void) -> Self {
            let actionBlock: ActionBlock = { _ in
                handler()
            }
            return set(\.actionBlock, to: actionBlock)
        }

        /// Sets the action of the menu item.
        func onSelect(_ action: ActionBlock?) -> Self {
            set(\.actionBlock, to: action)
        }

        /// Set the tag of the menu item
        func tag(_ tag: Int) -> Self {
            set(\.tag, to: tag)
        }

        /// Sets the keyboard shortcut/key equivalent.
        func shortcut(_ shortcut: String, holding modifiers: NSEvent.ModifierFlags = .command) -> Self {
            apply {
                $0.keyEquivalent = shortcut
                $0.keyEquivalentModifierMask = modifiers
            }
        }

        /// Enables the menu item.
        func enabled(_ isEnabled: Bool) -> Self {
            set(\.isEnabled, to: isEnabled)
        }

        /// Hides the menu item.
        func hidden(_ isHidden: Bool) -> Self {
            set(\.isHidden, to: isHidden)
        }

        /// Sets the submenu.
        func submenu(_ menu: NSMenu?) -> Self {
            set(\.submenu, to: menu)
        }

        /// Sets the submenu for the given menu item using a menu builder.
        func submenu(@MenuBuilder _ items: @escaping () -> [NSMenuItem]) -> Self {
            apply {
                $0.submenu = NSMenu(title: $0.title, items)
            }
        }

        /// Set the tooltip displayed when hovering over the menu item.
        func toolTip(_ toolTip: String?) -> Self {
            set(\.toolTip, to: toolTip)
        }

        // MARK: Appearance

        /// Sets the checked/unchecked/mixed state
        func state(_ state: NSControl.StateValue) -> Self {
            set(\.state, to: state)
        }

        /**
         Sets a view that is displayed instead of the title or attributed title.
         
         - Parameters:
            - view: The view to display.
            - showsHighlight: A Boolean value that indicates whether menu item should highlight on interaction.
         */
        func view(_ view: NSView?, showsHighlight: Bool = true) -> Self {
            if let view = view {
                if showsHighlight {
                    return set(\.view, to: MenuItemView(content: view))
                } else {
                    return set(\.view, to: view)
                }
            } else {
                return set(\.view, to: nil)
            }
        }

        /**
         Sets a SwiftUI view that is displayed instead of the title or attributed title.
         
         - Parameters:
            - view: The SwiftUI view to display.
            - showsHighlight: A Boolean value that indicates whether menu item should highlight on interaction.
         */
            func view<Content: View>(@ViewBuilder _ content: () -> Content, showsHighlight: Bool = true) -> Self {
                view(MenuItemHostingView(contentView: content(), showsHighlight: showsHighlight))
            }
        
        /**
         Sets a SwiftUI view that is displayed instead of the title or attributed title.
         
         - Parameters:
            - view: The SwiftUI view to display.
            - showsHighlight: A Boolean value that indicates whether menu item should highlight on interaction.
         */
        func view<Content: View>(_ view: Content, showsHighlight: Bool = true) -> Self {
            self.view(MenuItemHostingView(contentView: view, showsHighlight: showsHighlight))
        }

        /// Sets the image associated with this menu item.
        func image(_ image: NSImage?) -> Self {
            set(\.image, to: image)
        }

        /// Sets an on/off/mixed-state-specific image.
        func image(_ image: NSImage, for state: NSControl.StateValue) -> Self {
            apply { item in
                switch state {
                case .off: item.offStateImage = image
                case .on: item.onStateImage = image
                case .mixed: item.mixedStateImage = image
                default: fatalError("Unsupported MenuItem state \(state)")
                }
            }
        }

        // MARK: Advanced Customizations

        /// Indent the menu item to the given level
        func indentationLevel(_ level: Int) -> Self {
            set(\.indentationLevel, to: level)
        }

        /// Set an arbitrary `keyPath` on the menu item to a value of your choice.
        func set<Value>(_ keyPath: ReferenceWritableKeyPath<Item, Value>, to value: Value) -> Self {
            apply {
                $0[keyPath: keyPath] = value
            }
        }
    }
#endif
*/
