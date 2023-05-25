//
//  IndentGroup.swift
//
//
//  Created by Jed Fox on 6/19/21.
//
#if os(macOS)
    import Cocoa

    public extension NSMenu {
        /// A container that increases the `indentationLevel` of its content by one.
        struct IndentGroup {
            fileprivate let children: () -> [NSMenuItem?]

            public init(@MenuBuilder children: @escaping () -> [NSMenuItem?]) {
                self.children = children
            }
        }
    }

    public extension MenuBuilder {
        static func buildExpression(_ expr: NSMenu.IndentGroup?) -> [NSMenuItem] {
            if let items = expr?.children().compactMap({ $0 }) {
                for item in items {
                    item.indentationLevel += 1
                }
                return items
            }
            return []
        }
    }
#endif
