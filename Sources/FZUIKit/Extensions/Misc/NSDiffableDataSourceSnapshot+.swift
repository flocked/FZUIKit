//
//  NSDiffableDataSourceSnapshot+.swift
//
//
//  Created by Florian Zand on 29.07.23.
//

#if os(macOS) || os(iOS) || os(tvOS)
    #if os(macOS)
        import AppKit
    #elseif canImport(UIKit)
        import UIKit
    #endif

    @available(macOS 10.15.1, iOS 13.0, tvOS 13.0, *)
    public extension NSDiffableDataSourceSnapshot {
        /**
         Creates a snapshot with the sections and items of the specified dictionary.
         
         - Parameter sectionItems: A dictionary of sections and items to add.
         */
        init(_ sectionItems: [SectionIdentifierType: [ItemIdentifierType]]) {
            self.init()
            append(sectionItems)
        }
        
        /// A Boolean value indicating whether the snapshot has no items and sections.
        var isEmpty: Bool {
            numberOfItems == 0 && numberOfSections == 0
        }
        
        /**
         Adds the sections and items with the specified identifiers to the snapshot.

         - Parameter sectionItems: A dictionary of section and item identifiers to add to the snapshot.
         */
        mutating func append(_ sectionItems: [SectionIdentifierType: [ItemIdentifierType]]) {
            appendSections(Array(sectionItems.keys))
            for value in sectionItems {
                appendItems(value.value, toSection: value.key)
            }
        }

        /**
         Moves the items from their current positions in the snapshot to the position immediately after the specified item.

         - Parameters:
            - identifiers: The identifiers of the items to move in the snapshot.
            - toIdentifier:  The identifier of the item after which to move the specified item.
         */
        mutating func moveItems(_ identifiers: [ItemIdentifierType], afterItem toIdentifier: ItemIdentifierType) {
            identifiers.reversed().forEach { moveItem($0, afterItem: toIdentifier) }
        }

        /**
         Moves the items from their current positions in the snapshot to the position immediately after the specified item.

         - Parameters:
            - identifiers: The identifiers of the items to move in the snapshot.
            - toIdentifier:  The identifier of the item before which to move the specified item.
         */
        mutating func moveItems(_ identifiers: [ItemIdentifierType], beforeItem toIdentifier: ItemIdentifierType) {
            identifiers.forEach { moveItem($0, beforeItem: toIdentifier) }
        }
        
        /// Returns a new snapshot with the items filtered by the specified predicate.
        func filter(_ predicate: (ItemIdentifierType) -> Bool) -> Self {
            let remove = itemIdentifiers.filter({ !predicate($0) })
            var snapshot = self
            snapshot.deleteItems(remove)
            return snapshot
        }
    }
#endif
