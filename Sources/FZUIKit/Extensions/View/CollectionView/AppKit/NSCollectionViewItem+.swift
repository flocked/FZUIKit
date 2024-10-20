//
//  NSCollectionViewItem+.swift
//
//
//  Created by Florian Zand on 28.12.23.
//

#if os(macOS)

    import AppKit

    extension NSCollectionViewItem {
        /// The index path of the item.
        @objc open var indexPath: IndexPath? {
            collectionView?.indexPath(for: self)
        }
        
        /// The previous item in the collection view, or `nil` if there isn't a previous item or the item isn't in a collection view.
        @objc open var previousItem: NSCollectionViewItem? {
            guard let indexPath = indexPath, indexPath.item - 1 >= 0 else { return nil }
            return collectionView?.item(at: IndexPath(item: indexPath.item - 1, section: indexPath.section))
        }

        /// The next item in the collection view, or `nil` if there isn't a next item or the item isn't in a collection view.
        @objc open var nextItem: NSCollectionViewItem? {
            guard let collectionView = collectionView, let indexPath = indexPath, indexPath.item + 1 < collectionView.numberOfItems(inSection: indexPath.section) else { return nil }
            return collectionView.item(at: IndexPath(item: indexPath.item + 1, section: indexPath.section))
        }
    }

#endif
