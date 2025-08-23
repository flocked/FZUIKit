//
//  ToolbarItem+Seperator.swift
//
//
//  Created by Florian Zand on 09.04.23.
//

#if os(macOS)
import AppKit
import SwiftUI

@available(macOS 11.0, *)
extension Toolbar {
    /**
     A toolbar separator that aligns with the vertical split view in the same window.
     
     Use a `TrackingSeparator` to divide a toolbar into sections that visually align with the views on either side of the divider of the ``splitView``. This keeps toolbar items above the content that’s the target for the item’s target.
     
     The ``splitView`` must be in the same window as the toolbar containing this item before showing the toolbar.
     */
    open class TrackingSeparator: ToolbarItem {
        var autodetectsSplitView = false
        var isEmptySplitView = true
        fileprivate let separatorItem: ValidationTrackingSeparatorToolbarItem
        override var item: NSToolbarItem {
            separatorItem
        }
        
        /**
         The vertical split view to align with the toolbar separator.
         
         The `splitView` must be in the same window as the toolbar containing the item before showing the toolbar.
         */
        open var splitView: NSSplitView? {
            get { isEmptySplitView ? nil : separatorItem.splitView }
            set {
                guard newValue != splitView else { return }
                separatorItem.splitView = newValue ?? NSSplitView()
                autodetectsSplitView = newValue == nil
                isEmptySplitView = newValue == nil
                updateAutodetectSplitView()
            }
        }
        
        func updateAutodetectSplitView(toolbar: Toolbar? = nil) {
            Swift.print("updateAutodetectSplitView", toolbar != nil, toolbar?.attachedWindow != nil, toolbar?.attachedWindow?.contentView != nil, toolbar?.attachedWindow?.contentView?.firstSuperview(for: NSSplitView.self) != nil, toolbar?.attachedWindow?.contentView is NSSplitView)
            (toolbar?.attachedWindow?.contentView?.subviews(depth: .max) ?? []).forEach({Swift.print($0)})

            guard autodetectsSplitView else { return }
            if let splitView = (toolbar ?? self.toolbar)?.attachedWindow?.contentView?.subviews(type: NSSplitView.self, depth: .max).first {
                separatorItem.splitView = splitView
                isEmptySplitView = false
            } else if !isEmptySplitView {
                separatorItem.splitView = NSSplitView()
                isEmptySplitView = true
            }
        }
        
        /**
         Sets the vertical split view to align with the toolbar separator.
         
         The `splitView` must be in the same window as the toolbar containing the item before showing the toolbar.
         */
        @discardableResult
        open func splitView(_ splitView: NSSplitView) -> Self {
            self.splitView = splitView
            return self
        }
        
        /// The index of the split view divider to align with the tracking separator.
        open var dividerIndex: Int {
            get { separatorItem.dividerIndex }
            set { separatorItem.dividerIndex = newValue }
        }
        
        /// Sets the index of the split view divider to align with the tracking separator.
        @discardableResult
        open func dividerIndex(_ index: Int) -> Self {
            self.dividerIndex = index
            return self
        }
        
        /**
         The handler that is called to validate the toolbar item.
         
         The handler is e.g. called by the toolbar when the toolbar's visibilty or window key state changes.
         */
        public var validateHandler: ((Toolbar.TrackingSeparator)->())?
        
        /**
         Sets the handler that is called to validate the toolbar item.
         
         The handler is e.g. called by the toolbar when the toolbar's visibilty or window key state changes.
         */
        @discardableResult
        public func validateHandler(_ validation: ((Toolbar.TrackingSeparator)->())?) -> Self {
            self.validateHandler = validation
            return self
        }
        
        /**
         Creates a tracking seperator toolbar item that automatically detects the split view used inside the toolbar's window.
         
         - Note: The identifier is used for autosaving the item. When you don't specifiy an identifier an automatic identifier is used. It is recommended to specifiy an identifier, if you have multiple `TrackingSeparator` toolbar items.
         
         - Parameters:
            - identifier: The item identifier.
            - dividerIndex: The index of the divider.
         */
        public init(_ identifier: NSToolbarItem.Identifier? = nil, dividerIndex: Int) {
            self.autodetectsSplitView = true
            self.separatorItem = .init(identifier: identifier ?? Toolbar.automaticIdentifier(for: "TrackingSeparator"), splitView: NSSplitView(), dividerIndex: dividerIndex)
            super.init(separatorItem.itemIdentifier)
            self.separatorItem.item = self
        }
        
        /**
         Creates a tracking seperator toolbar item for the specified split view and divider index.
         
         - Note: The identifier is used for autosaving the item. When you don't specifiy an identifier an automatic identifier is used. It is recommended to specifiy an identifier, if you have multiple `TrackingSeparator` toolbar items.
         
         - Parameters:
            - identifier: The item identifier.
            - splitView: The tracked split view.
            - dividerIndex: The index of the divider.
         */
        public init(_ identifier: NSToolbarItem.Identifier? = nil, splitView: NSSplitView, dividerIndex: Int) {
            self.separatorItem = .init(identifier: identifier ?? Toolbar.automaticIdentifier(for: "TrackingSeparator"), splitView: splitView, dividerIndex: dividerIndex)
            super.init(separatorItem.itemIdentifier)
            self.separatorItem.item = self
        }
    }
}

@available(macOS 11.0, *)
fileprivate class ValidationTrackingSeparatorToolbarItem: NSTrackingSeparatorToolbarItem {
    weak var item: Toolbar.TrackingSeparator?
    
    override func validate() {
        super.validate()
        guard let item = item else { return }
        item.validate()
        item.validateHandler?(item)
    }
}

#endif
