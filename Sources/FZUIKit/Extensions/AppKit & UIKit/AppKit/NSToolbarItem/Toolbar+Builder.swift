//
//  File.swift
//
//
//  Created by Florian Zand on 19.04.23.
//

#if os(macOS)
    import AppKit

    public extension Toolbar {
        convenience init(
            _ identifier: NSToolbar.Identifier,
            allowsUserCustomization: Bool = false,
            @Builder builder: () -> [ToolbarItem]
        ) {
            self.init(identifier, allowsUserCustomization: allowsUserCustomization, items: builder())
        }

        @resultBuilder
        enum Builder {
            public static func buildBlock(_ block: [ToolbarItem]...) -> [ToolbarItem] {
                block.flatMap { $0 }
            }

            public static func buildOptional(_ item: [ToolbarItem]?) -> [ToolbarItem] {
                item ?? []
            }

            public static func buildEither(first: [ToolbarItem]?) -> [ToolbarItem] {
                first ?? []
            }

            public static func buildEither(second: [ToolbarItem]?) -> [ToolbarItem] {
                second ?? []
            }

            public static func buildArray(_ components: [[ToolbarItem]]) -> [ToolbarItem] {
                components.flatMap { $0 }
            }

            public static func buildExpression(_ expr: [ToolbarItem]?) -> [ToolbarItem] {
                expr ?? []
            }

            public static func buildExpression(_ expr: ToolbarItem?) -> [ToolbarItem] {
                expr.map { [$0] } ?? []
            }
        }
    }
#endif
