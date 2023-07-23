//
//  NSCollectionView+.swift
//  
//
//  Created by Florian Zand on 06.06.22.
//

#if os(macOS)

import AppKit
import Foundation

public extension NSCollectionView {
    /**
     The frame of the item at the specified index path.
     - Parameters indexPath: The index path of the item.
     - Returns: The frame of the item or nil if no item exists at the specified path.
     */
    func frameForItem(at indexPath: IndexPath) -> CGRect? {
        return layoutAttributesForItem(at: indexPath)?.frame
    }

    /**
     The item item at the specified location.
     - Parameters location: The location of the item.
     - Returns: The item or nil if no item exists at the specified location.
     */
    func item(at location: CGPoint) -> NSCollectionViewItem? {
        if let indexPath = indexPathForItem(at: location) {
            return item(at: indexPath)
        }
        return nil
    }

    /**
     The item index paths for the specified section.
     - Parameters section: The section of the items.
     - Returns: The item index paths.
     */
    func indexPaths(for section: Int) -> [IndexPath] {
        var indexPaths = [IndexPath]()
        if numberOfSections > section {
            let numberOfItems = self.numberOfItems(inSection: section)
            for item in 0 ..< numberOfItems {
                indexPaths.append(IndexPath(item: item, section: section))
            }
        }
        return indexPaths
    }

    /*
    var allIndexPaths: [IndexPath] {
        var indexPaths = [IndexPath]()
        for section in 0 ..< numberOfSections {
            indexPaths.append(contentsOf: self.indexPaths(for: section))
        }
        return indexPaths
    }

    var nonSelectedIndexPaths: [IndexPath] {
        let selected = selectionIndexPaths
        return allIndexPaths.filter { selected.contains($0) == false }
    }
     */

    func scrollToTop() {
        enclosingScrollView?.scrollToBeginningOfDocument(nil)
    }

    func scrollToBottom() {
        enclosingScrollView?.scrollToEndOfDocument(nil)
    }

    func setCollectionViewLayout(_ layout: NSCollectionViewLayout, animated: Bool, completion: ((Bool) -> Void)? = nil) {
        if animated == true {
            performBatchUpdates({
                self.animator().collectionViewLayout = layout
            }, completionHandler: { completed in
                completion?(completed)
            })
        } else {
            collectionViewLayout = layout
            completion?(true)
        }
    }

    var contentOffset: CGPoint {
        get { return enclosingScrollView?.contentOffset ?? .zero }
        set { enclosingScrollView?.contentOffset = newValue }
    }

    var contentSize: CGSize { return enclosingScrollView?.contentSize ?? .zero }
}

public extension NSCollectionView {
    typealias SavedScrollPosition = NSScrollView.SavedScrollPosition
    
    func saveScrollPosition() -> SavedScrollPosition {
        return SavedScrollPosition(bounds: bounds, visible: visibleRect)
    }

    func restoreScrollPosition(_ saved: SavedScrollPosition) {
        let oldBounds = saved.bounds
        let oldVisible = saved.visible
        let oldY = oldVisible.midY
        let oldH = oldBounds.height
        guard oldH > 0.0 else { return }

        let fraction = (oldY - oldBounds.minY) / oldH
        let newBounds = bounds
        var newVisible = visibleRect
        let newY = newBounds.minY + fraction * newBounds.height
        newVisible.origin.y = newY - 0.5 * newVisible.height
        scroll(newVisible.origin)
    }
}

#endif
