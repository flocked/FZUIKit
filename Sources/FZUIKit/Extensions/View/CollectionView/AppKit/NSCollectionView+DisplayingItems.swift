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

    extension NSCollectionView {
        /// Returns the index paths of the currently displayed items. Unlike `indexPathsForVisibleItems()`  it only returns the items with visible frame.
        public func displayingIndexPaths() -> [IndexPath] {
            (displayingItems().compactMap { self.indexPath(for: $0) }).sorted()
        }

        /// Returns an array of all displayed items. Unlike `visibleItems()` it only returns the items with visible frame.
        public func displayingItems() -> [NSCollectionViewItem] {
            let visibleItems = visibleItems()
            let visibleRect = visibleRect
            return visibleItems.filter { $0.view.frame.intersects(visibleRect) }
        }

        /**
         The handlers for the displaying items.

         The handlers get called whenever the collection view is displaying new items (e.g. when the enclosing scrollview gets scrolled to new items).
         */
        public var displayingItemsHandlers: DisplayingItemsHandlers {
            get { getAssociatedValue(key: "NSCollectionView_displayingItemsHandlers", object: self, initialValue: DisplayingItemsHandlers()) }
            set {
                set(associatedValue: newValue, key: "NSCollectionView_displayingItemsHandlers", object: self)
                setupDisplayingItemsTracking()
            }
        }

        /**
         Handlers for the displaying items (e.g. when the enclosing scrollview gets scrolled to new items).

         The handlers get called whenever the collection view is displaying new items.
         */
        public struct DisplayingItemsHandlers {
            /// Handler that gets called whenever items start getting displayed.
            var isDisplaying: (([IndexPath]) -> Void)?
            /// Handler that gets called whenever items end getting displayed.
            var didEndDisplaying: (([IndexPath]) -> Void)?
        }

        var previousDisplayingIndexPaths: [IndexPath] {
            get { getAssociatedValue(key: "NSCollectionView_previousDisplayingIndexPaths", object: self, initialValue: []) }
            set {
                set(associatedValue: newValue, key: "NSCollectionView_previousDisplayingIndexPaths", object: self)
            }
        }

        @objc func didScroll(_: Any) {
            let isDisplaying = displayingItemsHandlers.isDisplaying
            let didEndDisplaying = displayingItemsHandlers.didEndDisplaying
            guard isDisplaying != nil || didEndDisplaying != nil else { return }

            let displayingIndexPaths = displayingIndexPaths()
            let previousDisplayingIndexPaths = previousDisplayingIndexPaths
            guard displayingIndexPaths != previousDisplayingIndexPaths else { return }
            self.previousDisplayingIndexPaths = displayingIndexPaths

            if let isDisplaying = isDisplaying {
                let indexPaths = displayingIndexPaths.filter { previousDisplayingIndexPaths.contains($0) == false }
                if indexPaths.isEmpty == false {
                    isDisplaying(indexPaths)
                }
            }

            if let didEndDisplaying = didEndDisplaying {
                let indexPaths = previousDisplayingIndexPaths.filter { displayingIndexPaths.contains($0) == false }
                if indexPaths.isEmpty == false {
                    didEndDisplaying(indexPaths)
                }
            }
        }

        func setupDisplayingItemsTracking() {
            guard let contentView = enclosingScrollView?.contentView else { return }
            if displayingItemsHandlers.isDisplaying != nil || displayingItemsHandlers.didEndDisplaying != nil {
                contentView.postsBoundsChangedNotifications = true
                NotificationCenter.default.addObserver(self, selector: #selector(didScroll(_:)), name: NSView.boundsDidChangeNotification, object: contentView)
            } else {
                NotificationCenter.default.removeObserver(self, name: NSView.boundsDidChangeNotification, object: contentView)
            }
        }
    }

#endif
