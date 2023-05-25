//
//  File.swift
//
//
//  Created by Florian Zand on 09.04.23.
//

#if os(macOS)
    import AppKit

    public extension NSToolbar {
        convenience init(
            _ identifier: NSToolbar.Identifier,
            allowsUserCustomization: Bool = false,
            selectionDidChange: ((NSToolbarItem.Identifier?) -> Void)? = nil,
            @Builder builder: () -> [NSToolbarItem]
        ) {
            self.init(identifier: identifier, items: builder())
            self.allowsUserCustomization = allowsUserCustomization
            itemSelectionHandler = selectionDidChange
        }

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

    /*
     public extension NSToolbar {
         convenience init(
             _ identifier: NSToolbar.Identifier,
             allowsUserCustomization: Bool = false,
             selectionDidChange: ((NSToolbarItem.Identifier?) -> Void)? = nil,
             @ToolbarBuilder builder: () -> [any ToolbarItem]) {
                 self.init(identifier: identifier, items: builder().compactMap({$0.item}))
                 self.allowsUserCustomization = allowsUserCustomization
                 self.itemSelectionHandler = selectionDidChange
         }
     }

     @resultBuilder
     public struct ToolbarBuilder {
         public static func buildBlock(_ block: [any ToolbarItem]...) -> [any ToolbarItem] {
             block.flatMap { $0 }
         }

         public static func buildOptional(_ item: [any ToolbarItem]?) -> [any ToolbarItem] {
             item ?? []
         }

         public static func buildEither(first: [any ToolbarItem]?) -> [any ToolbarItem] {
             first ?? []
         }
         public static func buildEither(second: [any ToolbarItem]?) -> [any ToolbarItem] {
             second ?? []
         }

         public static func buildArray(_ components: [[any ToolbarItem]]) -> [any ToolbarItem] {
             components.flatMap { $0 }
         }

         public static func buildExpression(_ expr: [any ToolbarItem]?) -> [any ToolbarItem] {
             expr ?? []
         }

         public static func buildExpression(_ expr: (any ToolbarItem)?) -> [any ToolbarItem] {
             expr.map { [$0] } ?? []
         }
     }
      */
#endif
