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
    
    /**
     Updates the UI to reflect the state of the data in the specified snapshot, optionally animating the UI changes and executing a completion handler.

     It’s safe to call this method from a background queue, but you must do so consistently in your app. Always call this method exclusively from the main queue or from a background queue.

     - Parameters:
        - snapshot: The snapshot reflecting the new state of the data in the collection view.
        - option: Option how to apply the snapshot to the table view.
        - completion: An optional closure to be executed when the animations are complete. This closure has no return value and takes no parameters. The system calls this closure from the main queue. The default value is `nil`.
     */
    func apply(_ snapshot: NSDiffableDataSourceSnapshot<SectionIdentifierType, ItemIdentifierType>, _ option: NSDiffableDataSourceSnapshotApplyOption, completion: (() -> Void)? = nil) {
        switch option {
        case .usingReloadData:
            if #available(iOS 15.0, tvOS 15.0, *) {
                applySnapshotUsingReloadData(snapshot, completion: completion)
            } else {
                apply(snapshot, animatingDifferences: false, completion: completion)
            }
        case .animated(duration: let duration):
            if duration == NSDiffableDataSourceSnapshotApplyOption.noAnimationDuration {
                apply(snapshot, animatingDifferences: true, completion: completion)
            } else {
                UIView.animate(withDuration: duration) {
                    self.apply(snapshot, animatingDifferences: true, completion: completion)
                }
            }
        case .withoutAnimation:
            if #available(iOS 15.0, tvOS 15.0, *) {
                apply(snapshot, animatingDifferences: false, completion: completion)
            } else {
                UIView.animate(withDuration: 0.0) {
                    self.apply(snapshot, animatingDifferences: true, completion: completion)
                }
            }
        }
    }
}
#endif
