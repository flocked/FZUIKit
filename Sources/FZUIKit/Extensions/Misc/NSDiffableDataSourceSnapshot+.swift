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

    public extension NSDiffableDataSourceSnapshot {
        /// A Boolean value indicating whether the snapshot is empty.
        var isEmpty: Bool {
            if numberOfItems > 0 {
                return numberOfSections == 0
            }
            return true
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
    }
#endif
