//
//  NSToolbar+.swift
//
//
//  Created by Florian Zand on 30.03.23.
//

#if os(macOS)

import AppKit
import FZSwiftUtils

extension NSToolbar {
    /**
     Creates a managed toolbar with the specified identifier and toolbar items.

     This toolbar manages its items automatically by using a ManagedToolbarDelegate as it's delegate. Use the toolbar items isDefaultItem, isSelectable and isImmovableItem properties.
     
     - Parameters identifier: A string used by the class to identify the kind of the toolbar.
     - Parameters items: An array of toolbar items to be managed by the toolbar.
     - Note: You shouldn't change it's delegate.
     */
    public convenience init(
        identifier: NSToolbar.Identifier,
        items: [NSToolbarItem]
    ) {
        self.init(identifier: identifier)
        self.managedToolbarDelegate = ManagedToolbarDelegate(items: items)
        self.delegate = self.managedToolbarDelegate!
    }

    /**
     Creates a managed toolbar with the specified identifier and toolbar items.

     This toolbar manages its items automatically by using a ManagedToolbarDelegate as it's delegate. Use the toolbar items isDefaultItem, isSelectable and isImmovableItem properties.

     - Parameters identifier: A string used by the class to identify the kind of the toolbar.
     - Parameters bulder: The builder for the toolbar items to be managed by the toolbar.
     - Note: You shouldn't change it's delegate.
     */
    public convenience init(
        _ identifier: NSToolbar.Identifier,
        @Builder builder: () -> [NSToolbarItem]
    ) {
        self.init(identifier: identifier, items: builder())
    }

    /// A handler that gets called whenever the selected toolbar item changes.
    public var selectedItemHandler: ((NSToolbarItem.Identifier?) -> ())? {
        get { getAssociatedValue(key: "_selectedItemHandler", object: self, initialValue: nil) }
        set { set(associatedValue: newValue, key: "_selectedItemHandler", object: self)
            setupToolbarItemSelectionObserver()
        }
    }

    internal var toolbarItemSelectionObserver: NSKeyValueObservation? {
        get { getAssociatedValue(key: "_toolbarItemSelectionObserver", object: self, initialValue: nil) }
        set { set(associatedValue: newValue, key: "_toolbarItemSelectionObserver", object: self)
        }
    }

    internal func setupToolbarItemSelectionObserver() {
        if selectedItemHandler != nil {
            if toolbarItemSelectionObserver == nil {
                toolbarItemSelectionObserver = observeChanges(for: \.selectedItemIdentifier) { [weak self] _, itemIdentifier in
                    guard let self = self else { return }
                    self.selectedItemHandler?(itemIdentifier)
                }
            }
        } else {
            toolbarItemSelectionObserver = nil
        }
    }

    internal var managedToolbarDelegate: ManagedToolbarDelegate? {
        get { getAssociatedValue(key: "_managedToolbarDelegate", object: self, initialValue: nil) }
        set { set(associatedValue: newValue, key: "_managedToolbarDelegate", object: self)
        }
    }
}
#endif
