//
//  NSCollectionView+DisplayingItems.swift
//  
//
//  Created by Florian Zand on 05.07.23.
//

#if os(macOS)

import AppKit
import Foundation
import FZSwiftUtils

public extension NSCollectionView {
    /// Returns the index paths of the currently displayed items. Unlike `indexPathsForVisibleItems()`  it only returns the items with visible frame.
    func displayingIndexPaths() -> [IndexPath] {
        return displayingItems().compactMap { self.indexPath(for: $0) }.sorted()
    }
    /// Returns an array of all displayed items. Unlike `visibleItems()` it only returns the items with visible frame.
    func displayingItems() -> [NSCollectionViewItem] {
        let visibleItems = self.visibleItems()
        let visibleRect = self.visibleRect
        self.indexPathsForVisibleItems()
        return visibleItems.filter { NSIntersectsRect($0.view.frame, visibleRect) }
    }
    
    /**
     Handlers that get called whenever the collection view is displaying new items (e.g. when the enclosing scrollview gets scrolled to new items).
     */
    var displayingItemsHandlers: DisplayingItemsHandlers {
        get { getAssociatedValue(key: "NSCollectionView_displayingItemsHandlers", object: self, initialValue: DisplayingItemsHandlers()) }
        set {
            set(associatedValue: newValue, key: "NSCollectionView_displayingItemsHandlers", object: self)
        }
    }
    
    /**
     Handlers for the displaying items.
     
     The handlers get called whenever the collection view is displaying new items (e.g. when the enclosing scrollview gets scrolled to new items).
     */
    struct DisplayingItemsHandlers {
        /// Handler that gets called whenever items start getting displayed.
        var isDisplaying: (([IndexPath])->())? = nil
        /// Handler that gets called whenever items end getting displayed.
        var didEndDisplaying: (([IndexPath])->())? = nil
    }
    
    internal var previousDisplayingIndexPaths: [IndexPath] {
        get { getAssociatedValue(key: "NSCollectionView_previousDisplayingIndexPaths", object: self, initialValue: []) }
        set {
            set(associatedValue: newValue, key: "NSCollectionView_previousDisplayingIndexPaths", object: self)
        }
    }
    
    @objc internal func didScroll(_ any: Any) {
        let isDisplaying = self.displayingItemsHandlers.isDisplaying
        let didEndDisplaying = self.displayingItemsHandlers.didEndDisplaying
        
        guard isDisplaying != nil || didEndDisplaying != nil else { return }
        let displayingIndexPaths = self.displayingIndexPaths()
        let previousDisplayingIndexPaths = self.previousDisplayingIndexPaths
        var added = [IndexPath]()
        var removed = [IndexPath]()
        if let isDisplaying = isDisplaying {
            for displayingIndexPath in displayingIndexPaths {
                if (previousDisplayingIndexPaths.contains(displayingIndexPath) == false) {
                    added.append(displayingIndexPath)
                }
            }
            isDisplaying(added)
        }
        
        if let didEndDisplaying = didEndDisplaying {
            for previousDisplayingIndexPath in previousDisplayingIndexPaths {
                if (displayingIndexPaths.contains(previousDisplayingIndexPath) == false) {
                    removed.append(previousDisplayingIndexPath)
                }
            }
            didEndDisplaying(removed)
        }
        
        self.previousDisplayingIndexPaths = displayingIndexPaths
    }
    
    internal func setupDisplayingItemsTracking() {
        guard let contentView = self.enclosingScrollView?.contentView else { return }
        if self.displayingItemsHandlers.isDisplaying != nil || self.displayingItemsHandlers.didEndDisplaying != nil {
            NotificationCenter.default.addObserver(self, selector: #selector(self.didScroll(_:)), name: NSView.boundsDidChangeNotification, object: contentView)
        } else {
            NotificationCenter.default.removeObserver(self, name: NSView.boundsDidChangeNotification, object: contentView)
        }
    }
}

#endif
