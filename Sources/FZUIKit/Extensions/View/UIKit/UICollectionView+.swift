//
//  UICollectionView+.swift
//
//
//  Created by Florian Zand on 26.11.23.
//

#if os(iOS) || os(tvOS)
import UIKit
import FZSwiftUtils

public extension UICollectionView {
    /// Returns the index paths of the currently displayed cells. Unlike `indexPathsForVisibleItems()`  it only returns the cells with visible frame.
    func displayingIndexPaths() -> [IndexPath] {
        return (displayingCells().compactMap { self.indexPath(for: $0) }).sorted()
    }

    /// Returns an array of all displayed cells. Unlike `visibleCells()` it only returns the items with visible frame.
    func displayingCells() -> [UICollectionViewCell] {
        let visibleCells = self.visibleCells
        let visibleRect = self.frame.intersection(superview?.bounds ?? self.frame)
        return visibleCells.filter { $0.frame.intersects(visibleRect) }
    }

    /// Handlers that get called whenever the collection view is displaying new items.
    var displayingItemsHandlers: DisplayingItemsHandlers {
        get { getAssociatedValue(key: "displayingItemsHandlers", object: self, initialValue: DisplayingItemsHandlers()) }
        set {
            set(associatedValue: newValue, key: "displayingItemsHandlers", object: self)
            setupDisplayingItemsTracking()
        }
    }

    /**
     Handlers for the displaying items.
     
     The handlers get called whenever the collection view is displaying new items.
     */
    struct DisplayingItemsHandlers {
        /// Handler that gets called whenever items start getting displayed.
        var isDisplaying: (([IndexPath]) -> Void)?
        /// Handler that gets called whenever items end getting displayed.
        var didEndDisplaying: (([IndexPath]) -> Void)?
    }

    internal var previousDisplayingIndexPaths: [IndexPath] {
        get { getAssociatedValue(key: "previousDisplayingIndexPaths", object: self, initialValue: []) }
        set {
            set(associatedValue: newValue, key: "previousDisplayingIndexPaths", object: self)
        }
    }

    internal var contentOffsetObserver: NSKeyValueObservation? {
        get { getAssociatedValue(key: "contentOffsetObserver", object: self, initialValue: nil) }
        set { set(associatedValue: newValue, key: "contentOffsetObserver", object: self) }
    }

    @objc internal func didScroll() {
        let isDisplaying = self.displayingItemsHandlers.isDisplaying
        let didEndDisplaying = self.displayingItemsHandlers.didEndDisplaying
        guard isDisplaying != nil || didEndDisplaying != nil else { return }

        let displayingIndexPaths = self.displayingIndexPaths()
        let previousDisplayingIndexPaths = self.previousDisplayingIndexPaths
        guard displayingIndexPaths != previousDisplayingIndexPaths else { return }
        self.previousDisplayingIndexPaths = displayingIndexPaths

        if let isDisplaying = isDisplaying {
            let indexPaths = displayingIndexPaths.filter({ previousDisplayingIndexPaths.contains($0) == false })
            if indexPaths.isEmpty == false {
                isDisplaying(indexPaths)
            }
        }

        if let didEndDisplaying = didEndDisplaying {
            let indexPaths = previousDisplayingIndexPaths.filter({ displayingIndexPaths.contains($0) == false })
            if indexPaths.isEmpty == false {
                didEndDisplaying(indexPaths)
            }
        }
    }

    internal func setupDisplayingItemsTracking() {
        if self.displayingItemsHandlers.isDisplaying != nil || self.displayingItemsHandlers.didEndDisplaying != nil {
            if contentOffsetObserver == nil {
                contentOffsetObserver = self.observeChanges(for: \.contentOffset, handler: { [weak self] old, new in
                    guard let self = self, old != new else { return }
                    self.didScroll()
                })
            }
        } else {
            contentOffsetObserver = nil
        }
    }
}

#endif
