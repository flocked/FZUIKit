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
        class PopoverButton: ToolbarItem, NSPopoverDelegate {
            /// The button of the toolbar item that opens the popover.
            public let button: NSButton
            
            weak var popover: NSPopover?

            /// The view controller of the popover.
            public weak var popoverViewController: NSViewController? {
                didSet {
                    guard oldValue != popoverViewController else { return }
                    closePopover()
                }
            }
            
            /// Sets the view controller of the popover.
            @discardableResult
            public func popoverViewController(_ viewController: NSViewController) -> Self {
                popoverViewController = viewController
                return self
            }
            
            /// Sets the title of the button.
            @discardableResult
            public func title(_ title: String) -> Self {
                button.title = title
                return self
            }

            /// Sets the alternate title of the button.
            @discardableResult
            public func alternateTitle(_ title: String) -> Self {
                button.alternateTitle = title
                return self
            }

            /// Sets the attributed title of the button.
            @discardableResult
            public func attributedTitle(_ title: NSAttributedString) -> Self {
                button.attributedTitle = title
                return self
            }

            /// Sets the attributed alternate title of the button.
            @discardableResult
            public func attributedAlternateTitle(_ title: NSAttributedString) -> Self {
                button.attributedAlternateTitle = title
                return self
            }

            /// Sets the button type.
            @discardableResult
            public func type(_ type: NSButton.ButtonType) -> Self {
                button.setButtonType(type)
                return self
            }

            /// Sets the state of the button.
            @discardableResult
            public func state(_ state: NSControl.StateValue) -> Self {
                button.state = state
                return self
            }
            
            /// Sets the state of the button.
            @discardableResult
            public func state(_ state: Bool) -> Self {
                button.state = state ? .on : .off
                return self
            }

            /// The state of the button.
            public var state: NSControl.StateValue {
                get { button.state }
                set { button.state = newValue }
            }

            /// Sets the Boolean value that determines whether the button has a border.
            @discardableResult
            public func bordered(_ isBordered: Bool) -> Self {
                button.isBordered = isBordered
                return self
            }

            /// Sets the Boolean value that determines whether the button is transparent..
            @discardableResult
            public func transparent(_ isTransparent: Bool) -> Self {
                button.isTransparent = isTransparent
                return self
            }

            /// The image of the button, or `nil` if none.
            @discardableResult
            public func image(_ image: NSImage?) -> Self {
                button.image = image
                return self
            }

            /// Sets the alternate image of the button, or `nil` if none.
            @discardableResult
            public func alternateImage(_ image: NSImage?) -> Self {
                button.alternateImage = image
                return self
            }

            /// Sets the image position of the button.
            @discardableResult
            public func imagePosition(_ position: NSControl.ImagePosition) -> Self {
                button.imagePosition = position
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
            public func bezelStyle(_ style: NSButton.BezelStyle) -> Self {
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

            /// Sets the action block of the button.
            @discardableResult
            public func onAction(_ action: ((ToolbarItem.PopoverButton)->())?) -> Self {
                button.actionBlock = { [weak self] _ in
                    guard let self = self else { return }
                    self.showPopover()
                    action?(self)
                }
                return self
            }

            func showPopover() {
                guard popover == nil || popover?.isShown == false else { return }
                let popover = NSPopover()
                popover.contentViewController = popoverViewController
                popover.behavior = .transient
                popover.delegate = self
                popover.show(relativeTo: button.bounds, of: button, preferredEdge: .maxY)
                self.popover = popover
            }

            func closePopover() {
                popover?.close()
                popover = nil
            }

            /**
             Creates a popover button toolbar item.

             - Parameters:
                - identifier: An optional identifier of the item.
                - title: The title of the button.
                - image: The image of the button.
                - popoverContentController: The view controller of the popover button.
             */
            public convenience init(_ identifier: NSToolbarItem.Identifier? = nil, 
                                    title: String?,
                                    image: NSImage? = nil,
                                    popoverContentController: NSViewController) {
                let button = Self.button.title(title ?? "").image(image)
                self.init(identifier, button: button, popoverContentController: popoverContentController)
            }
            
            static var button: NSButton {
                NSButton(frame: .zero).bezelStyle(.texturedRounded).buttonType(.momentaryChange)
            }
            
            /**
             Creates a popover button toolbar item.

             - Parameters:
                - identifier: An optional identifier of the item.
                - image: The image of the button.
                - popoverContentController: The view controller of the popover button.
             */
            public convenience init(_ identifier: NSToolbarItem.Identifier? = nil, 
                                    image: NSImage,
                                    popoverContentController: NSViewController) {
                let button = Self.button.image(image)
                self.init(identifier, button: button, popoverContentController: popoverContentController)
            }
            
            /**
             Creates a popover button toolbar item.

             - Parameters:
                - identifier: An optional identifier of the item.
                - symbolImage: The name of the symbol image of the button.
                - popoverContentController: The view controller of the popover button.
             */
            @available(macOS 11.0, *)
            public convenience init(_ identifier: NSToolbarItem.Identifier? = nil,
                                    symbolImage: String,
                                    popoverContentController: NSViewController) {
                let button = Self.button.image(NSImage(systemSymbolName: symbolImage))
                self.init(identifier, button: button, popoverContentController: popoverContentController)
            }

            /**
             Creates a popover button toolbar item.

             - Parameters:
                - identifier: An optional identifier of the item.
                - button: The popover button.
                - popoverContentController: The view controller of the popover button.
             */
            public init(_ identifier: NSToolbarItem.Identifier? = nil, 
                        button: NSButton,
                        popoverContentController: NSViewController) {
                button.translatesAutoresizingMaskIntoConstraints = false
                self.button = button
                popoverViewController = popoverContentController
                super.init(identifier)
                item.view = self.button
                self.button.actionBlock = { [weak self] _ in
                    guard let self = self else { return }
                    self.showPopover()
                }
            }
        }
    }
#endif
