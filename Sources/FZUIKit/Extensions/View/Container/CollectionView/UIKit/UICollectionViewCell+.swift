//
//  UICollectionViewCell+.swift
//  
//
//  Created by Florian Zand on 18.01.24.
//

#if os(iOS) || os(tvOS)
import UIKit

extension UICollectionViewCell {
    /// The collection view that owns the cell.
    @objc open var collectionView: UICollectionView? {
        firstSuperview(for: UICollectionView.self)
    }
    
    /// The index path of the item.
    @objc open var indexPath: IndexPath? {
        collectionView?.indexPath(for: self)
    }
    
    /// The previous cell in the collection view, or `nil` if there isn't a previous cell or the cell isn't in a collection view.
    @objc open var previousCell: UICollectionViewCell? {
        guard let indexPath = indexPath, indexPath.item - 1 >= 0 else { return nil }
        return collectionView?.cellForItem(at: IndexPath(item: indexPath.item - 1, section: indexPath.section))
    }

    /// The next cell in the collection view, or `nil` if there isn't a next cell or the cell isn't in a collection view.
    @objc open var nextCell: UICollectionViewCell? {
        guard let collectionView = collectionView, let indexPath = indexPath, indexPath.item + 1 < collectionView.numberOfItems(inSection: indexPath.section) else { return nil }
        return collectionView.cellForItem(at: IndexPath(item: indexPath.item + 1, section: indexPath.section))
    }
}

#endif
