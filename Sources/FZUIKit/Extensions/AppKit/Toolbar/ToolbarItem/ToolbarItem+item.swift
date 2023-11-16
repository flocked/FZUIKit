//
//  ToolbarItem+item.swift
//
//
//  Created by Florian Zand on 09.04.23.
//

#if os(macOS)
import AppKit

public extension ToolbarItem {
    /// A toolbar item.
    class Item: ToolbarItem {
        @discardableResult
        public func title(_ title: String) -> Self {
            set(\.item.title, to: title)
        }

        @discardableResult
        public func image(_ image: NSImage?) -> Self {
            set(\.item.image, to: image)
        }

        @discardableResult
        public func bordered(_ isBordered: Bool) -> Self {
            set(\.item.isBordered, to: isBordered)
        }

        @available(macOS 11.0, *)
        @discardableResult
        public func isNavigational(_ isNavigational: Bool) -> Self {
            item.isNavigational = isNavigational
            return self
        }

        @discardableResult
        public func onAction(_ action: ToolbarItem.ActionBlock?) -> Self {
            item.actionBlock = action
            return self
        }

        @discardableResult
        public func onAction(_ handler: @escaping () -> Void) -> Self {
            item.actionBlock = { _ in
                handler()
            }
            return self
        }
    }
}
#endif
