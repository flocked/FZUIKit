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
    /**
     Adds the sections and items with the specified identifiers to the snapshot.
     
     - Parameters sectionItems: A dictionary of section and item identifiers to add to the snapshot.
     */
    mutating func append(_ sectionItems: [SectionIdentifierType: [ItemIdentifierType]]) {
        self.appendSections(Array(sectionItems.keys))
        for value in sectionItems {
            self.appendItems(value.value, toSection: value.key)
        }
    }
}
#endif
