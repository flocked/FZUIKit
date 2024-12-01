//
//  ToolbarItem+PopoverButton.swift
//
//
//  Created by Florian Zand on 09.04.23.
//

#if os(macOS)
    import AppKit

    public extension ToolbarItem {
        /**
         A toolbar item that contains a popover button.

         The item can be used with ``Toolbar``.
         */
        class PopoverButton: ToolbarItem {
            /// The button of the toolbar item that opens the popover.
            public let button: NSButton
            
            private weak var popover: NSPopover?
            private var delegate: Delegate!
            private var _viewController: NSViewController?

            /// The view controller that manages the content of the popover.
            public weak var popoverViewController: NSViewController? {
                didSet {
                    guard oldValue != popoverViewController else { return }
                    _viewController = nil
                    popover?.close()
                    popover = nil
                }
            }
            
            /// Sets the view controller that manages the content of the popover.
            @discardableResult
            public func popoverViewController(_ viewController: NSViewController) -> Self {
                popoverViewController = viewController
                return self
            }
            
            /// The view of the pop over.
            public var popoverView: NSView? {
                get { popoverViewController?.view }
                set {
                    guard newValue != popoverViewController?.view, let view = newValue else { return }
                    let viewController =  NSViewController()
                    viewController.view = view
                    popoverViewController = viewController
                    _viewController = viewController
                }
            }
            
            /// Sets the view of the popover.
            @discardableResult
            public func popoverView(_ view: NSView) -> Self {
                popoverView = view
                return self
            }
            
            /// Sets the title of the button.
            @discardableResult
            public func title(_ title: String) -> Self {
                button.title = title
                return self
            }

            /// Sets the attributed title of the button.
            @discardableResult
            public func attributedTitle(_ title: NSAttributedString) -> Self {
                button.attributedTitle = title
                return self
            }

            /// The image of the button, or `nil` if none.
            @discardableResult
            public func image(_ image: NSImage?) -> Self {
                button.image = image
                return self
            }

            /// Sets the image scaling of the button.
            @discardableResult
            public func imageScaling(_ imageScaling: NSImageScaling) -> Self {
                button.imageScaling = imageScaling
                return self
            }

            /// Sets the bezel style of the button.
            @discardableResult
            public func bezelStype(_ style: NSButton.BezelStyle) -> Self {
                button.bezelStyle = style
                return self
            }

            /// Sets the bezel color of the button, or `nil` if none.
            @discardableResult
            public func bezelColor(_ color: NSColor?) -> Self {
                button.bezelColor = color
                return self
            }

            /// Sets the key-equivalent character and modifier keys of the button.
            @discardableResult
            public func shortcut(_ shortcut: String, holding modifiers: NSEvent.ModifierFlags = .command) -> Self {
                button.keyEquivalent = shortcut
                button.keyEquivalentModifierMask = modifiers
                return self
            }
            
            /// A Boolean value that indicates whether the popover is detachable by the user.
            public var isDetachable: Bool = false {
                didSet {
                    guard oldValue != isDetachable else { return }
                    popover?.isDetachable = isDetachable
                }
            }
            
            /// Sets the Boolean value that indicates whether the popover is detachable by the user.
            @discardableResult
            public func isDetachable(_ isDetachable: Bool) -> Self {
                self.isDetachable = isDetachable
                return self
            }
            
            /// A Boolean value that indicates whether the popover hides it's arrow.
            public var hidesArrow: Bool = false {
                didSet {
                    guard oldValue != hidesArrow else { return }
                    popover?.isArrowVisible = !hidesArrow
                }
            }
            
            /// Sets the Boolean value that indicates whether the popover hides it's arrow.
            @discardableResult
            public func hidesArrow(_ hidesArrow: Bool) -> Self {
                self.hidesArrow = hidesArrow
                return self
            }

            /// Sets the handler that gets called when the user clicks the popover button.
            @discardableResult
            public func onAction(_ action: ((_ item: ToolbarItem.PopoverButton)->())?) -> Self {
                if let action = action {
                    button.actionBlock = { [weak self] _ in
                        guard let self = self else { return }
                        self.showPopover()
                        action(self)
                    }
                } else {
                    button.actionBlock = { [weak self] _ in
                        guard let self = self else { return }
                        self.showPopover()
                    }
                }
                return self
            }

            func showPopover() {
                guard popover == nil || popover?.isShown == false, let viewController = popoverViewController else { return }
                let popover = NSPopover(viewController: viewController)
                popover.behavior = .transient
                popover.isDetachable = isDetachable
                popover.delegate = delegate
                popover.show(relativeTo: button.bounds, of: button, preferredEdge: .maxY, hideArrow: false)
                self.popover = popover
            }

            /**
             Creates a popover button toolbar item.

             - Parameters:
                - identifier: An optional identifier of the item.
                - title: The title of the button.
                - image: The image of the button.
                - popoverViewController: The view controller that manages the content of the popover.
             */
            public convenience init(_ identifier: NSToolbarItem.Identifier? = nil, 
                                    title: String? = nil,
                                    image: NSImage? = nil,
                                    popoverViewController: NSViewController) {
                let button = NSButton.toolbar().title(title ?? "").image(image)
                button.sizeToFit()
                self.init(identifier, button: button, popoverViewController: popoverViewController)
            }
            
            /**
             Creates a popover button toolbar item.

             - Parameters:
                - identifier: An optional identifier of the item.
                - title: The title of the button.
                - image: The image of the button.
                - popoverView: The view of the popover.
             */
            public convenience init(_ identifier: NSToolbarItem.Identifier? = nil,
                                    title: String? = nil,
                                    image: NSImage? = nil,
                                    popoverView: NSView) {
                let button = NSButton.toolbar().title(title ?? "").image(image)
                button.sizeToFit()
                self.init(identifier, button: button, popoverView: popoverView)
            }
            
            /**
             Creates a popover button toolbar item.

             - Parameters:
                - identifier: An optional identifier of the item.
                - button: The popover button.
                - popoverViewController: The view controller that manages the content of the popover.
             */
            public init(_ identifier: NSToolbarItem.Identifier? = nil, button: NSButton, popoverViewController: NSViewController) {
                button.translatesAutoresizingMaskIntoConstraints = false
                self.button = button
                self.popoverViewController = popoverViewController
                super.init(identifier)
                delegate = Delegate(self)
                item.view = button
                button.actionBlock = { [weak self] _ in
                    guard let self = self else { return }
                    self.showPopover()
                }
            }
            
            /**
             Creates a popover button toolbar item.

             - Parameters:
                - identifier: An optional identifier of the item.
                - button: The popover button.
                - popoverView: The view of the popover.
             */
            public init(_ identifier: NSToolbarItem.Identifier? = nil, button: NSButton, popoverView: NSView) {
                button.translatesAutoresizingMaskIntoConstraints = false
                self.button = button
                super.init(identifier)
                self.popoverView = popoverView
                delegate = Delegate(self)
                item.view = button
                button.actionBlock = { [weak self] _ in
                    guard let self = self else { return }
                    self.showPopover()
                }
            }
            
            class Delegate: NSObject, NSPopoverDelegate {
                func popoverDidClose(_ notification: Notification) {
                    item?.popover = nil
                }
                
                weak var item: ToolbarItem.PopoverButton?
                init(_ item: ToolbarItem.PopoverButton? = nil) {
                    self.item = item
                }
            }
        }
    }
#endif
