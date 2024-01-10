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
        func addSupplementaryItem(_ kind: String, height: NSCollectionLayoutDimension = .estimated(44), floating: Bool = true, alignment: NSRectAlignment = .top) {
            let layoutSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0),
                                                    heightDimension: height)
            let item = NSCollectionLayoutBoundarySupplementaryItem(
                layoutSize: layoutSize,
                elementKind: kind, alignment: alignment
            )

            item.zIndex = .max
            item.pinToVisibleBounds = floating
            boundarySupplementaryItems.append(item)
        }

        func addFooter(height: NSCollectionLayoutDimension = .estimated(44), floating: Bool = true) {
            addSupplementaryItem(NSUICollectionView.elementKindSectionFooter, height: height, floating: floating, alignment: .bottom)
        }

        func addHeader(height: NSCollectionLayoutDimension = .estimated(44), floating: Bool = true) {
            addSupplementaryItem(NSUICollectionView.elementKindSectionHeader, height: height, floating: floating, alignment: .top)
        }
    }
#endif
