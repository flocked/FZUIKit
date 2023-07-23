//
//  NSCollectionViewLayout+.swift
//  
//
//  Created by Florian Zand on 23.07.23.
//

import FZSwiftUtils
#if os(macOS)
import AppKit
#elseif canImport(UIKit)
import UIKit
#endif

public extension NSUICollectionViewLayout {
    static func list(rowHeight: CGFloat, seperatorLine: Bool) -> NSUICollectionViewLayout {
        let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0),
                                              heightDimension: .fractionalHeight(1.0))

        var itemSupplementaryItems = [NSCollectionLayoutBoundarySupplementaryItem]()
        if seperatorLine {
            let seperatorItem = NSUICollectionViewCompositionalLayout.seperatorLine(kind: .bottomLine)
            itemSupplementaryItems.append(seperatorItem)
        }
        let item = NSCollectionLayoutItem(layoutSize: itemSize, supplementaryItems: itemSupplementaryItems)
        let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0),
                                               heightDimension: .absolute(rowHeight))
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize,
                                                       subitems: [item])

        let section = NSCollectionLayoutSection(group: group)

        let layout = NSUICollectionViewCompositionalLayout(section: section)
        return layout
    }

    static func fullSize(paging: Bool, direction: NSUICollectionView.ScrollDirection) -> NSUICollectionViewLayout {
        let itemSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1.0),
            heightDimension: .fractionalHeight(1.0)
        )

        let layoutItem = NSCollectionLayoutItem(layoutSize: itemSize)
        let groupSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1.0),
            heightDimension: .fractionalHeight(1.0)
        )
        let layoutGroup = NSCollectionLayoutGroup.vertical(
            layoutSize: groupSize,
            subitems: [layoutItem]
        )
        let layoutSection = NSCollectionLayoutSection(group: layoutGroup)
        layoutSection.orthogonalScrollingBehavior = paging ? .paging : .continuous
        let config = NSUICollectionViewCompositionalLayoutConfiguration()
        config.scrollDirection = direction
        let layout = NSUICollectionViewCompositionalLayout(section: layoutSection, configuration: config)
        return layout
    }

    static func grid(columns: Int = 3, itemAspectRatio: CGSize = CGSize(1, 1), spacing: CGFloat = 8.0, insets: NSDirectionalEdgeInsets = .init(16), header: NSUICollectionViewCompositionalLayout.SupplementaryItemType? = nil, footer: NSUICollectionViewCompositionalLayout.SupplementaryItemType? = nil) -> NSUICollectionViewLayout {
        return NSUICollectionViewCompositionalLayout { (_: Int, layoutEnvironment: NSCollectionLayoutEnvironment) -> NSCollectionLayoutSection? in

            // Item
            let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(itemAspectRatio.width / itemAspectRatio.height),
                                                  heightDimension: .fractionalHeight(1))

            let item = NSCollectionLayoutItem(layoutSize: itemSize)

            // Group
            let groupHeight: CGFloat = {
                let totalSpacing = spacing * (CGFloat(columns) - 1)
                let horizontalInsets = insets.leading + insets.trailing

                let itemWidth = (layoutEnvironment.container.effectiveContentSize.width - totalSpacing - horizontalInsets) / CGFloat(columns)

                return itemWidth * itemAspectRatio.height / itemAspectRatio.width
            }()

            let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1),
                                                   heightDimension: .absolute(groupHeight))
            let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitem: item, count: columns)
            group.interItemSpacing = .fixed(spacing)

            // Section
            let section = NSCollectionLayoutSection(group: group)
            section.interGroupSpacing = spacing
            section.contentInsets = insets

            // Header & Footer
            if let headerItem = header?.item(elementKind: "Header") {
                section.boundarySupplementaryItems.append(headerItem)
            }
            if let footherItem = footer?.item(elementKind: "Footer") {
                section.boundarySupplementaryItems.append(footherItem)
            }
            return section
        }
    }
}
