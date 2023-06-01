//
//  NSCollectionView+.swift
//  FZExtensions
//
//  Created by Florian Zand on 06.06.22.
//

#if os(macOS)

import AppKit
import Foundation

public extension NSCollectionView {
    enum ElementKind {
        public static let itemTopSeperator: String = "ElementKindItemTopSeperator"
        public static let itemBottomSeperator: String = "ElementKindBottomSeperator"
        public static let itemBackground: String = "ElementKindItemBackground"
        public static let groupBackground: String = "ElementKindGroumBackground"
        public static let sectionBackground: String = "ElementKindSectionBackground"
        public static var sectionHeader: String {
            return NSCollectionView.elementKindSectionHeader
        }

        public static var sectionFooter: String {
            return NSCollectionView.elementKindSectionFooter
        }
    }

    func displayingIndexPaths() -> [IndexPath] {
        return displayingItems().compactMap { self.indexPath(for: $0) }.sorted()
    }

    func displayingItems() -> [NSCollectionViewItem] {
        let visibleItems = self.visibleItems()
        let visibleRect = self.visibleRect
        return visibleItems.filter { NSIntersectsRect($0.view.frame, visibleRect) }
    }

    func frameForItem(at indexPath: IndexPath) -> CGRect? {
        return layoutAttributesForItem(at: indexPath)?.frame
    }

    func item(at location: CGPoint) -> NSCollectionViewItem? {
        if let indexPath = indexPathForItem(at: location) {
            return item(at: indexPath)
        }
        return nil
    }
    
    func item(for event: NSEvent) -> NSCollectionViewItem? {
        let location = event.location(in: self)
        return item(at: location)
    }

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

    func scrollToTop() {
        enclosingScrollView?.scrollToBeginningOfDocument(nil)
    }

    func scrollToBottom() {
        enclosingScrollView?.scrollToEndOfDocument(nil)
    }

    func setCollectionViewLayout(_ layout: NSCollectionViewLayout, animated: Bool) {
        if animated == true {
            performBatchUpdates({
                self.animator().collectionViewLayout = layout
            })
        } else {
            collectionViewLayout = layout
        }
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
        get { return enclosingScrollView?.documentVisibleRect.origin ?? .zero }
        set { scroll(newValue) }
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
