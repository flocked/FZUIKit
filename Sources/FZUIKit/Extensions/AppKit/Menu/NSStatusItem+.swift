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
            set { setAssociatedValue(newValue, key: "onClick")
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
            set { setAssociatedValue(newValue, key: "onRightClick")
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
            set { setAssociatedValue(newValue, key: "rightClickMenu")
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
        
        /// Sets the allowed behaviors for the status item.
        @discardableResult
        public func behavior(_ behavior: Behavior) -> Self {
            self.behavior = behavior
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
        public static func fiexedWidth(_ width: CGFloat) -> NSStatusItem {
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
            if onClick != nil { mask.insert(.leftMouseUp) }
            if onRightClick != nil || rightClickMenu != nil { mask.insert(.rightMouseUp) }
            if onMouseHold != nil { mask.insert([.leftMouseDown, .leftMouseUp]) }
            if onRightMouseHold != nil { mask.insert([.rightMouseDown, .rightMouseUp]) }
            button?.sendAction(on: mask)
            
            if onClick != nil || onRightClick != nil || onMouseHold != nil || onRightMouseHold != nil || rightClickMenu != nil {
                if let menu = menu {
                    leftClickMenu = menu
                    self.menu = nil
                }
                menuObservation = observeChanges(for: \.menu) { [weak self] old, new in
                    guard let self = self else { return }
                    self.leftClickMenu = new
                    self.menu = nil
                }
                button?.actionBlock = { [weak self] button in
                    guard let self = self, let event = NSApp.currentEvent else { return }
                    switch event.type {
                    case .leftMouseDown:
                        self.onMouseHold?(.started)
                    case .leftMouseUp:
                        self.onMouseHold?(.ended)
                        self.onClick?()
                        if let leftClickMenu = self.leftClickMenu {
                            self.perform(NSSelectorFromString("popUpStatusItemMenu:"), with: leftClickMenu)
                        }
                    case .rightMouseDown:
                        self.onRightMouseHold?(.started)
                    case .rightMouseUp:
                        self.onRightMouseHold?(.ended)
                        self.onRightClick?()
                        if let rightClickMenu = self.rightClickMenu {
                            self.perform(NSSelectorFromString("popUpStatusItemMenu:"), with: rightClickMenu)
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
        
        /*
        var popoverView: NSView? {
            popover?.contentView
        }
        
        var popoverViewController: NSViewController? {
            popover?.contentViewController
        }
        
        var popover: NSPopover? {
            get { getAssociatedValue("popover") }
            set { setAssociatedValue(newValue, key: "popover") }
        }
         */
    }
#endif
