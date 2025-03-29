//
//  NSStatusItem+.swift
//
//
//  Created by Florian Zand on 10.04.23.
//

#if os(macOS)
    import AppKit
    import FZSwiftUtils
import SwiftUI

    extension NSStatusItem {
        /**
         The handler to be called when the status item gets clicked.
         
         To detect right clicks, use ``onRightClick``.
         
         When using this handler, the `action` and `target` of the item's button is set to `nil` and this handler is used  instead.
         */
        public var onClick: (()->())? {
            get { getAssociatedValue("onClick") }
            set { 
                setAssociatedValue(newValue, key: "onClick")
                updateAction()
            }
        }

        /**
         The handler to be called when the status item gets right clicked.
         
         To detect left clicks, use ``onClick``.
         
         When using this handler, the `action` and `target` of the item's button is set to `nil` and this handler is used  instead.
         */
        public var onRightClick: (()->())? {
            get { getAssociatedValue("onRightClick") }
            set { 
                setAssociatedValue(newValue, key: "onRightClick")
                updateAction()
            }
        }
        
        /// The handler that provides the menu that is displayed when the item is clicked.
        public var menuProvider: (()->(NSMenu?))? {
            get { (menu as? MenuProvider)?.menuProvider }
            set {
                if let newValue = newValue {
                    menu = MenuProvider(newValue)
                } else if menu is MenuProvider {
                    menu = nil
                }
            }
        }
        
        /// The menu that is displayed when the item is right clicked.
        public var rightClickMenu: NSMenu? {
            get { getAssociatedValue("rightClickMenu") }
            set { 
                setAssociatedValue(newValue, key: "rightClickMenu")
                updateAction()
            }
        }
        
        /// The handler that provides the menu that is displayed when the item is right clicked.
        public var rightClickMenuProvider: (()->(NSMenu?))? {
            get { (rightClickMenu as? MenuProvider)?.menuProvider }
            set {
                if let newValue = newValue {
                    rightClickMenu = MenuProvider(newValue)
                } else if menu is MenuProvider {
                    rightClickMenu = nil
                }
            }
        }
        
        /// Sets the Boolean value indicating if the menu bar currently displays the status item.
        @discardableResult
        public func isVisible(_ isVisible: Bool) -> Self {
            self.isVisible = isVisible
            return self
        }
        
        /// Sets the amount of space in the status bar that should be allocated to the status item.
        @discardableResult
        public func length(_ length: CGFloat) -> Self {
            self.length = length
            return self
        }
        
        /// A Boolean value indicating whether the status item can be removed by the user.
        public var allowsRemoval: Bool {
            get { behavior.contains(.removalAllowed) }
            set { behavior[.removalAllowed] = newValue }
        }
        
        /// Sets the Boolean value indicating whether the status item can be removed by the user.
        @discardableResult
        public func allowsRemoval(_ allows: Bool) -> Self {
            allowsRemoval = allows
            return self
        }
        
        /// A Boolean value indicating whether the application should quite upon removal of the status item.
        public var terminateOnRemoval: Bool {
            get { behavior.contains(.terminationOnRemoval) }
            set { behavior[.terminationOnRemoval] = newValue }
        }
        
        /// Sets the Boolean value indicating whether the application should quite upon removal of the status item.
        @discardableResult
        public func terminateOnRemoval(_ terminateOnRemoval: Bool) -> Self {
            self.terminateOnRemoval = terminateOnRemoval
            return self
        }
        
        /// Sets the pull-down menu displayed when the user clicks the status item.
        @discardableResult
        public func menu(_ menu: NSMenu?) -> Self {
            self.menu = menu
            return self
        }
        
        /// Sets the pull-down menu displayed when the user clicks the status item.
        @discardableResult
        public func menu(@MenuBuilder items: () -> [NSMenuItem]) -> Self {
            self.menu = NSMenu()
            self.menu?.items = items()
            return self
        }
        
        /// Sets the pull-down menu displayed when the user right clicks the status item.
        @discardableResult
        public func rightClickMenu(_ menu: NSMenu?) -> Self {
            self.rightClickMenu = menu
            return self
        }
        
        /// Sets the pull-down menu displayed when the user right clicks the status item.
        @discardableResult
        public func rightClickMenu(@MenuBuilder items: () -> [NSMenuItem]) -> Self {
            self.rightClickMenu = NSMenu()
            self.rightClickMenu?.items = items()
            return self
        }
        
        /// Sets the handler to be called when the status item gets clicked.
        @discardableResult
        public func onClick(_ action: (()->())?) -> Self {
            self.onClick = action
            return self
        }
        
        /// Sets the handler to be called when the status item gets right clicked.
        @discardableResult
        public func onRightClick(_ action: (()->())?) -> Self {
            self.onRightClick = action
            return self
        }
        
        /// The mouse click state.
        public enum MouseClickState: Int, Hashable {
            /// The mouse started clicking the item.
            case isPressed
            /// The mouse ended clicking the item.
            case isReleased
        }
        
        /// The handler that gets called when the mouse is clicking and holding the item.
        public var onMouseHold: ((_ state: MouseClickState)->())? {
            get { getAssociatedValue("onMouseHold") }
            set { setAssociatedValue(newValue, key: "onMouseHold")
                updateAction()
            }
        }
        
        /// The handler that gets called when the mouse is right clicking and holding the item.
        public var onRightMouseHold: ((MouseClickState)->())? {
            get { getAssociatedValue("onRightMouseHold") }
            set { setAssociatedValue(newValue, key: "onRightMouseHold")
                updateAction()
            }
        }
        
        /// A status item with a length that dynamically adjusts to the width of its contents.
        public static var variableWidth: NSStatusItem {
            NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
        }
        
        /// A status item with a length that is equal to the status bar’s thickness.
        public static var squareWidth: NSStatusItem {
            NSStatusBar.system.statusItem(withLength: NSStatusItem.squareLength)
        }
        
        /// A status item with the specified width.
        public static func fixedWidth(_ width: CGFloat) -> NSStatusItem {
            NSStatusBar.system.statusItem(withLength: width)
        }
        
        /// A status item with the specified text.
        public static func text(_ text: String) -> NSStatusItem {
            let item = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
            item.button?.title = text
            return item
        }
        
        /// A status item with the specified image.
        public static func image(_ image: NSImage) -> NSStatusItem {
            let item = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
            item.button?.image = image
            return item
        }
        
        /// A status item with the specified symbol image.
        @available(macOS 11.0, *)
        public static func symbolImage(_ symbolName: String, symbolConfiguration: NSImage.SymbolConfiguration? = nil) -> NSStatusItem {
            let item = NSStatusBar.system.statusItem(withLength: NSStatusItem.squareLength)
            item.button?.image = NSImage(systemSymbolName: symbolName)
            item.button?.symbolConfiguration = symbolConfiguration
            return item
        }
        
        /// A status item with the specified view.
        public static func view(_ view: NSView) -> NSStatusItem {
            let item = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
            item.button?.addSubview(view)
            return item
        }
        
        /// A status item with the specified `SwiftUI` view.
        public static func view<Content: View>(_ view: Content) -> NSStatusItem {
            let item = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
            item.button?.addSubview(NSHostingView(rootView: view))
            return item
        }
        
        func updateAction() {
            var mask: NSEvent.EventTypeMask = []
            if onClick != nil || popover != nil { mask.insert(.leftMouseUp) }
            if onRightClick != nil || rightClickMenu != nil || rightClickPopover != nil { mask.insert(.rightMouseUp) }
            if onMouseHold != nil { mask.insert([.leftMouseDown, .leftMouseUp]) }
            if onRightMouseHold != nil { mask.insert([.rightMouseDown, .rightMouseUp]) }
            button?.sendAction(on: mask)
            
            if onClick != nil || onRightClick != nil || onMouseHold != nil || onRightMouseHold != nil || rightClickMenu != nil || popover != nil || rightClickPopover != nil {
                if let menu = menu {
                    leftClickMenu = menu
                    self.menu = nil
                }
                menuObservation = observeChanges(for: \.menu, uniqueValues: false) { [weak self] old, new in
                    guard let self = self, !self.isUpdatingMenu else { return }
                    self.leftClickMenu = new
                    self.isUpdatingMenu = true
                    self.menu = nil
                    self.isUpdatingMenu = false
                }
                button?.actionBlock = { [weak self] button in
                    guard let self = self, let event = NSApp.currentEvent else { return }
                    switch event.type {
                    case .leftMouseDown:
                        self.onMouseHold?(.isPressed)
                    case .leftMouseUp:
                        self.onMouseHold?(.isReleased)
                        self.onClick?()
                        if let popover = self.popover, let button = self.button {
                            if popover.isShown && popover.isDetached {
                                popover.undetach()
                            } else if popover.isShown {
                                popover.close()
                            } else {
                                popover.show(relativeTo: button.bounds, of: button, preferredEdge: .maxY)
                                button.isHighlighted = true
                            }
                        }
                        if let leftClickMenu = self.leftClickMenu {
                            perform(NSSelectorFromString("popUpMenu"), with: leftClickMenu)
                        }
                    case .rightMouseDown:
                        self.onRightMouseHold?(.isPressed)
                    case .rightMouseUp:
                        self.onRightMouseHold?(.isReleased)
                        self.onRightClick?()
                        if let popover = self.rightClickPopover, let button = self.button {
                            if popover.isShown && popover.isDetached {
                                popover.undetach()
                            } else if popover.isShown {
                                popover.close()
                            } else {
                                popover.show(relativeTo: button.bounds, of: button, preferredEdge: .maxY)
                                button.isHighlighted = true
                            }
                        }
                        if let rightClickMenu = self.rightClickMenu {
                            perform(NSSelectorFromString("popUpMenu"), with: rightClickMenu)
                        }
                    default: break
                    }
                }
            } else {
                menuObservation = nil
                menu = leftClickMenu
                leftClickMenu = nil
                button?.actionBlock = nil
            }
        }
        
        var leftClickMenu: NSMenu? {
            get { getAssociatedValue("leftClickMenu") }
            set { setAssociatedValue(newValue, key: "leftClickMenu") }
        }
        
        var menuObservation: KeyValueObservation? {
            get { getAssociatedValue("menuObservation") }
            set { setAssociatedValue(newValue, key: "menuObservation") }
        }
        
        var isUpdatingMenu: Bool {
            get { getAssociatedValue("isUpdatingMenu") ?? false }
            set { setAssociatedValue(newValue, key: "isUpdatingMenu") }
        }
        
        class MenuProvider: NSMenu, NSMenuDelegate {
            var menuProvider: (()->(NSMenu?))
            var providedMenu: NSMenu?
            
            init(_ menuProvider: @escaping () -> NSMenu?) {
                self.menuProvider = menuProvider
                super.init(title: "")
                delegate = self
            }
            
            func menuNeedsUpdate(_ menu: NSMenu) {
                guard let providedMenu = menuProvider() else { return }
                self.providedMenu = providedMenu
                let items = providedMenu.items
                providedMenu.items = []
                menu.items = items
            }
            
            func menuDidClose(_ menu: NSMenu) {
                guard let providedMenu = providedMenu else { return }
                let items = menu.items
                menu.items = []
                providedMenu.items = items
                self.providedMenu = nil
            }
            
            required init(coder: NSCoder) {
                fatalError("init(coder:) has not been implemented")
            }
        }
        
        /// The popover displayed when clicking the item.
        public var popover: NSPopover? {
            get { getAssociatedValue("popover") }
            set { 
                setAssociatedValue(newValue, key: "popover")
                updateAction()
            }
        }
        
        /// Sets the popover displayed when clicking the item.
        @discardableResult
        public func popover(_ popover: NSPopover?) -> Self {
            self.popover = popover
            return self
        }
        
        /// The popover displayed when right-clicking the item.
        public var rightClickPopover: NSPopover? {
            get { getAssociatedValue("rightClickPopover") }
            set {
                setAssociatedValue(newValue, key: "rightClickPopover")
                updateAction()
            }
        }
        
        /// Sets the popover displayed when right-clicking the item.
        @discardableResult
        public func rightClickPopover(_ popover: NSPopover?) -> Self {
            self.rightClickPopover = popover
            return self
        }
    }
#endif
