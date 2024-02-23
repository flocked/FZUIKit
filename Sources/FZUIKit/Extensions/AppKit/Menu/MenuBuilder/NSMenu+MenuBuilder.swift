//
//  NSMenu+MenuBuilder.swift
//
//
//  Created by Florian Zand on 08.06.23.
//

#if os(macOS)
    import AppKit

    /// A function builder type that produces an array of menu items.
    @resultBuilder
    public enum MenuBuilder {
        public static func buildBlock(_ block: [NSMenuItem]...) -> [NSMenuItem] {
            block.flatMap { $0 }
        }

        public static func buildOptional(_ item: [NSMenuItem]?) -> [NSMenuItem] {
            item ?? []
        }

        public static func buildEither(first: [NSMenuItem]?) -> [NSMenuItem] {
            first ?? []
        }

        public static func buildEither(second: [NSMenuItem]?) -> [NSMenuItem] {
            second ?? []
        }

        public static func buildArray(_ components: [[NSMenuItem]]) -> [NSMenuItem] {
            components.flatMap { $0 }
        }

        public static func buildExpression(_ expr: [NSMenuItem]?) -> [NSMenuItem] {
            expr ?? []
        }

        public static func buildExpression(_ expr: NSMenuItem?) -> [NSMenuItem] {
            expr.map { [$0] } ?? []
        }
    }

    public extension NSMenu {
        /// Create a new menu with the given title and items.
        convenience init(_ title: String, @MenuBuilder _ items: () -> [NSMenuItem]) {
            self.init(title: title)
            replaceItems(with: items)
        }

        /// Create a new menu with the given title and items.
        convenience init(title: String, @MenuBuilder _ items: () -> [NSMenuItem]) {
            self.init(title: title)
            replaceItems(with: items)
        }

        /// Create a new menu with the given items.
        convenience init(@MenuBuilder _ items: () -> [NSMenuItem]) {
            self.init()
            replaceItems(with: items)
        }

        /// Remove all items in the menu and replace them with the provided list of menu items.
        func replaceItems(@MenuBuilder with items: () -> [NSMenuItem]) {
            removeAllItems()
            for item in items() {
                addItem(item)
            }
            update()
        }
    }
#endif
