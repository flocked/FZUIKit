//
//  DiffableDataSourceTransaction.swift
//
//
//  Created by Florian Zand on 16.09.23.
//

#if os(iOS) || os(tvOS)
import UIKit

/// A transaction that describes the changes after reordering the items in the view.
public struct DiffableDataSourceTransaction<SectionIdentifierType, ItemIdentifierType> where SectionIdentifierType: Hashable, ItemIdentifierType: Hashable {
    /// The snapshot before the transaction occured.
    public let initialSnapshot: NSDiffableDataSourceSnapshot<SectionIdentifierType, ItemIdentifierType>

    /// The snapshot after the transaction occured.
    public let finalSnapshot: NSDiffableDataSourceSnapshot<SectionIdentifierType, ItemIdentifierType>

    /// A collection of insertions and removals that describe the difference between initial and final snapshots.
    public let difference: CollectionDifference<ItemIdentifierType>
}

extension DiffableDataSourceTransaction {
    init(initial: NSDiffableDataSourceSnapshot<SectionIdentifierType, ItemIdentifierType>, final: NSDiffableDataSourceSnapshot<SectionIdentifierType, ItemIdentifierType>) {
        initialSnapshot = initial
        finalSnapshot = final
        difference = initial.itemIdentifiers.difference(from: final.itemIdentifiers)
    }
}
#endif
