//
//  NSCollectionViewItem+.swift
//
//
//  Created by Florian Zand on 28.12.23.
//

#if os(macOS)

import AppKit

extension NSCollectionViewItem {
    var _collectionView: NSCollectionView? {
        collectionView ?? view.firstSuperview(for: NSCollectionView.self)
    }
    
    /// The index path of the item.
    @objc open var indexPath: IndexPath? {
        _collectionView?.indexPath(for: self)
    }
    
    /// A Boolean value indicating whether the item is visible in the collection view that owns the item.
    @objc open var isVisible: Bool {
        guard let collectionView = _collectionView else { return false }
        return collectionView.visibleRect.intersects(view.frame)
    }
    
    /// The previous item in the collection view, or `nil` if there isn't a previous item or the item isn't in a collection view.
    @objc open var previousItem: NSCollectionViewItem? {
        guard let collectionView = _collectionView, let indexPath = indexPath, let previousIndexPath = collectionView.previousIndexPath(for: indexPath) else { return nil }
        return collectionView.item(at: previousIndexPath)
    }
    
    /// The next item in the collection view, or `nil` if there isn't a next item or the item isn't in a collection view.
    @objc open var nextItem: NSCollectionViewItem? {
        guard let collectionView = _collectionView, let indexPath = indexPath, let nextIndexPath = collectionView.nextIndexPath(for: indexPath) else { return nil }
        return collectionView.item(at: nextIndexPath)
    }
}

#endif
