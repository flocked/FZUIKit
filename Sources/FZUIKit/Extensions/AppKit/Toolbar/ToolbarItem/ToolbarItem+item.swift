//
//  ToolbarItem+item.swift
//
//
//  Created by Florian Zand on 09.04.23.
//

#if os(macOS)
    import AppKit

    public extension ToolbarItem {
        /**
         A toolbar item.

         The item can be used with ``Toolbar``.
         */
        class Item: ToolbarItem {
            
            /// The title of the item.
            public var title: String {
                get { item.title }
                set { item.title = newValue }
            }
            
            /// Sets the title of the item.
            @discardableResult
            @objc open func title(_ title: String) -> Self {
                item.title = title
                return self
            }
            
            /// The image of the item, or `nil` if none.
            public var image: NSImage? {
                get { item.image }
                set { item.image = newValue }
            }

            /// Sets the image of the item, or `nil` if none.
            @discardableResult
            @objc open func image(_ image: NSImage?) -> Self {
                item.image = image
                return self
            }
            
            /// A Boolean value that indicates whether the toolbar item has a bordered style.
            public var isBordered: Bool {
                get { item.isBordered }
                set { item.isBordered = newValue }
            }

            /// Sets the Boolean value that indicates whether the toolbar item has a bordered style.
            @discardableResult
            @objc open func bordered(_ isBordered: Bool) -> Self {
                item.isBordered = isBordered
                return self
            }
            
            /// A Boolean value that indicates whether the toolbar item behaves as a navigation item in the toolbar.
            @available(macOS 11.0, *)
            public var isNavigational: Bool {
                get { item.isNavigational }
                set { item.isNavigational = newValue }
            }

            /// Sets the Boolean value that indicates whether the toolbar item behaves as a navigation item in the toolbar.
            @available(macOS 11.0, *)
            @discardableResult
            @objc open func isNavigational(_ isNavigational: Bool) -> Self {
                item.isNavigational = isNavigational
                return self
            }
            
            /// The handler that gets called when the user clicks the item.
            public var actionBlock: ((_ item: Item)->())? {
                didSet {
                    if let actionBlock = actionBlock {
                        item.actionBlock = { _ in
                            actionBlock(self)
                        }
                    } else {
                        item.actionBlock = nil
                    }
                }
            }

            /// Sets the handler that gets called when the user clicks the item.
            @discardableResult
            @objc open func onAction(_ action: ((_ item: Item)->())?) -> Self {
                actionBlock = action
                return self
            }
        }
    }
#endif
