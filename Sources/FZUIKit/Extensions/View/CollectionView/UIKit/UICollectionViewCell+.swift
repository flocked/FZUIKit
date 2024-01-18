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
    var collectionView: UICollectionView? {
        firstSuperview(for: UICollectionView.self)
    }
    
    /// The previous cell in the collection view, or `nil` if there isn't a previous cell or the cell isn't in a collection view.
    @objc open var previousCell: UICollectionViewCell? {
        if let indexPath = collectionView?.indexPath(for: self), indexPath.item - 1 >= 0 {
            let previousIndexPath = IndexPath(item: indexPath.item - 1, section: indexPath.section)
            return collectionView?.cellForItem(at: previousIndexPath)
        }
        return nil
    }

    /// The next cell in the collection view, or `nil` if there isn't a next cell or the cell isn't in a collection view.
    @objc open var nextCell: UICollectionViewCell? {
        if let indexPath = collectionView?.indexPath(for: self), indexPath.item + 1 < (self.collectionView?.numberOfItems(inSection: indexPath.section) ?? -10) {
            let nextIndexPath = IndexPath(item: indexPath.item + 1, section: indexPath.section)
            return collectionView?.cellForItem(at: nextIndexPath)
        }
        return nil
    }
}

#endif
