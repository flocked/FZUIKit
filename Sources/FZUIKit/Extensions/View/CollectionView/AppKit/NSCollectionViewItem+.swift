//
//  NSCollectionViewItem+.swift
//
//
//  Created by Florian Zand on 28.12.23.
//

#if os(macOS)

    import AppKit

    extension NSCollectionViewItem {
        /// The previous item in the collection view, or `nil` if there isn't a previous item or the item isn't in a collection view.
        @objc open var previousItem: NSCollectionViewItem? {
            if let indexPath = collectionView?.indexPath(for: self), indexPath.item - 1 >= 0 {
                let previousIndexPath = IndexPath(item: indexPath.item - 1, section: indexPath.section)
                return collectionView?.item(at: previousIndexPath)
            }
            return nil
        }

        /// The next item in the collection view, or `nil` if there isn't a next item or the item isn't in a collection view.
        @objc open var nextItem: NSCollectionViewItem? {
            if let indexPath = collectionView?.indexPath(for: self), indexPath.item + 1 < (self.collectionView?.numberOfItems(inSection: indexPath.section) ?? -10) {
                let nextIndexPath = IndexPath(item: indexPath.item + 1, section: indexPath.section)
                return collectionView?.item(at: nextIndexPath)
            }
            return nil
        }
    }

#endif
