//
//  UICollectionViewDiffableDataSource+.swift
//
//
//  Created by Florian Zand on 14.09.23.
//

#if os(iOS) || os(tvOS)
import UIKit

public extension UICollectionViewDiffableDataSource {
    /**
     Creates a diffable data source with the specified cell registration, and connects it to the specified collection view.
     
     - Parameters:
        - collectionView: The initialized collection view object to connect to the diffable data source.
        - cellRegistration: A cell registration that creates, configurate and returns each of the cells for the collection view from the data the diffable data source provides.
     */
    convenience init<Cell: UICollectionViewCell>(collectionView: UICollectionView, cellRegistration: UICollectionView.CellRegistration<Cell, ItemIdentifierType>) {
        self.init(collectionView: collectionView, cellProvider: { collectionView,indexPath,itemIdentifier in
            return collectionView.dequeueConfiguredReusableCell(using: cellRegistration, for: indexPath, item: itemIdentifier)
        })
    }
}
#endif
