//
//  NSToolbar+Builder.swift
//
//
//  Created by Florian Zand on 09.04.23.
//

#if os(macOS)
import AppKit

public extension NSToolbar {
    @resultBuilder
    enum Builder {
        public static func buildBlock(_ block: [NSToolbarItem]...) -> [NSToolbarItem] {
            block.flatMap { $0 }
        }

        public static func buildOptional(_ item: [NSToolbarItem]?) -> [NSToolbarItem] {
            item ?? []
        }

        public static func buildEither(first: [NSToolbarItem]?) -> [NSToolbarItem] {
            first ?? []
        }

        public static func buildEither(second: [NSToolbarItem]?) -> [NSToolbarItem] {
            second ?? []
        }

        public static func buildArray(_ components: [[NSToolbarItem]]) -> [NSToolbarItem] {
            components.flatMap { $0 }
        }

        public static func buildExpression(_ expr: [NSToolbarItem]?) -> [NSToolbarItem] {
            expr ?? []
        }

        public static func buildExpression(_ expr: NSToolbarItem?) -> [NSToolbarItem] {
            expr.map { [$0] } ?? []
        }

        public static func buildExpression(_ expr: ToolbarItem?) -> [NSToolbarItem] {
            expr.map { [$0.item] } ?? []
        }
    }
}
#endif
