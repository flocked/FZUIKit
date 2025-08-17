//
//  UITableViewDiffableDataSource+.swift
//  DiffableDataSourceExtensions
//
//  Created by Florian Zand on 08.02.24.
//

#if os(iOS) || os(tvOS)
import UIKit

public extension UICollectionViewDiffableDataSource {    
    /**
     Creates a diffable data source with the specified item provider, and connects it to the specified collection view.

     - Parameters:
        - collectionView: The initialized collection view object to connect to the diffable data source.
        - itemRegistration: A item registration that creates, configurate and returns each of the items for the collection view from the data the diffable data source provides.
     */
    convenience init<Cell>(collectionView: UICollectionView, cellRegistration: UICollectionView.CellRegistration<Cell, ItemIdentifierType>) where Cell: UICollectionViewCell {
        self.init(collectionView: collectionView) { collectionView, indexPath, item in
            collectionView.dequeueConfiguredReusableCell(using: cellRegistration, for: indexPath, item: item)
        }
    }
}
#endif
