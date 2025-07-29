//
//  NSCollectionLayoutSection+.swift
//
//
//  Created by Florian Zand on 29.08.22.
//

#if os(macOS) || os(iOS) || os(tvOS)
#if os(macOS)
import AppKit
#elseif canImport(UIKit)
import UIKit
#endif


public extension NSCollectionLayoutSection {
    /**
     Adds a boundary supplementary item of the specified item kind and height, with an alignment relative to a section or layout.

     - Parameters:
        - kind: The element kind of the item.
        - height: The height of the item.
        - floating: A Boolean value that indicates whether the item floats.
        - alignment: The alignment of the item.
     */
    func addSupplementaryItem(_ kind: String, height: NSCollectionLayoutDimension = .estimated(44), floating: Bool = true, alignment: NSRectAlignment = .top) {
        let layoutSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: height)
        let item = NSCollectionLayoutBoundarySupplementaryItem(layoutSize: layoutSize, elementKind: kind, alignment: alignment)
        item.zIndex = .max
        item.pinToVisibleBounds = floating
        if let index = boundarySupplementaryItems.firstIndex(where: {$0.elementKind == kind}) {
            boundarySupplementaryItems.remove(at: index)
        }
        boundarySupplementaryItems.append(item)
    }

    /**
     Adds a header boundary supplementary item of the specified height.

     - Parameters:
        - height: The height of the item.
        - floating: A Boolean value that indicates whether the item floats.
     */
    func addHeader(height: NSCollectionLayoutDimension = .estimated(44), floating: Bool = true) {
        addSupplementaryItem(NSUICollectionView.elementKindSectionHeader, height: height, floating: floating, alignment: .top)
    }

    /**
     Adds a footer boundary supplementary item of the specified height.

     - Parameters:
        - height: The height of the item.
        - floating: A Boolean value that indicates whether the item floats.
     */
    func addFooter(height: NSCollectionLayoutDimension = .estimated(44), floating: Bool = true) {
        addSupplementaryItem(NSUICollectionView.elementKindSectionFooter, height: height, floating: floating, alignment: .bottom)
    }
}
#endif
