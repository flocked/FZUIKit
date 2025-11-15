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
     The items for the specified section.
     
     
     
     */
    subscript (section: SectionIdentifierType) -> [ItemIdentifierType]? {
        get {
            guard sectionIdentifiers.contains(section) else { return nil }
            return itemIdentifiers(inSection: section)
        }
        set {
            if let newValue = newValue {
                if !sectionIdentifiers.contains(section) {
                    appendSections([section])
                }
                let itemsToDelete = itemIdentifiers.filter { newValue.contains($0) } + itemIdentifiers(inSection: section).filter { !newValue.contains($0) }
                deleteItems(itemsToDelete)
                appendItems(newValue, toSection: section)
            } else if sectionIdentifiers.contains(section) {
                deleteSections([section])
            }
        }
    }
    
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
        sectionItems.forEach({ appendItems($0.value, toSection: $0.key) })
    }
    
    /**
     Adds the specified section with its item to the snapshot.
          
     - Parameters:
        - sectionIdentifier: The identifier of the section to append.
        - itemIdentifiers: An array of item identifiers to append to the section.
     */
    mutating func append(_ sectionIdentifier: SectionIdentifierType, with itemIdentifiers: [ItemIdentifierType]) {
        appendSections([sectionIdentifier])
        appendItems(itemIdentifiers, toSection: sectionIdentifier)
    }
    
    /**
     Adds the section with the specified identifier to the snapshot.
     
     - Parameter identifier: The identifier specifying the section to add to the snapshot.
     */
    mutating func append(_ identifier: SectionIdentifierType) {
        append([identifier])
    }
    
    /**
     Adds the sections with the specified identifiers to the snapshot.
     
     - Parameter identifiers: An array of identifiers specifying the sections to add to the snapshot.
     */
    mutating func append(_ identifiers: [SectionIdentifierType]) {
        appendSections(identifiers)
    }
    
    /**
     Adds the item with the specified identifier to the specified section of the snapshot.
     
     - Parameters:
        - identifier: The identifier specifying the item to add to the snapshot.
        - sectionIdentifier: The section to which to add the items. If no value is provided, the items are appended to the last section of the snapshot.
     */
    mutating func append(_ identifier: ItemIdentifierType, toSection sectionIdentifier: SectionIdentifierType? = nil) {
        append([identifier], toSection: sectionIdentifier)
    }
    
    /**
     Adds the items with the specified identifiers to the specified section of the snapshot.
     
     If the snapshot doesn't contain the specified section, the section is added to the snapshot.
     
     All specified items that are already in the snapshot, are moved to 
     If the snapshot already contains specified items, they are moved to the specified section.
     
     - Parameters:
        - identifiers: An array of identifiers specifying the items to add to the snapshot.
        - sectionIdentifier: The section to which to add the items. If no value is provided, the items are appended to the last section of the snapshot.
     */
    mutating func append(_ identifiers: [ItemIdentifierType], toSection sectionIdentifier: SectionIdentifierType? = nil) {
        if let sectionIdentifier = sectionIdentifier, !sectionIdentifiers.contains(sectionIdentifier) {
            appendSections([sectionIdentifier])
        }
        deleteItems(identifiers.filter({ itemIdentifiers.contains($0) }))
        appendItems(identifiers, toSection: sectionIdentifier)
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
