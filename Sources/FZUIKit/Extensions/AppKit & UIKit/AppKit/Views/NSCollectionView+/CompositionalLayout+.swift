//
//  NSCollectionViewCompo.swift
//  FZExtensions
//
//  Created by Florian Zand on 07.06.22.
//

import Foundation
import FZSwiftUtils
#if os(macOS)
    import AppKit
    public typealias SupplementaryElementKind = NSCollectionView.SupplementaryElementKind
#elseif canImport(UIKit)
    import UIKit
    public typealias SupplementaryElementKind = String
#endif

public extension NSUICollectionViewCompositionalLayout {
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

    static func grid(columns: Int = 3, itemAspectRatio: CGSize = CGSize(1, 1), spacing: CGFloat = 0.0, insets: NSDirectionalEdgeInsets = .zero, header: SupplementaryItemType? = nil, footer: SupplementaryItemType? = nil) -> NSUICollectionViewLayout {
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

public extension NSUICollectionViewCompositionalLayout {
    enum SupplementaryKind: SupplementaryElementKind {
        case topLine
        case bottomLine

        internal var alignment: NSRectAlignment {
            switch self {
            case .topLine: return .top
            case .bottomLine: return .bottom
            }
        }
    }

    static func seperatorLine(kind: SupplementaryKind) -> NSCollectionLayoutBoundarySupplementaryItem {
        let lineItemHeight: CGFloat = 1.0
        let lineItemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(0.92), heightDimension: .absolute(lineItemHeight))
        let item = NSCollectionLayoutBoundarySupplementaryItem(layoutSize: lineItemSize, elementKind: kind.rawValue, alignment: kind.alignment)
        let supplementaryItemContentInsets = NSDirectionalEdgeInsets(top: 0, leading: 4, bottom: 0, trailing: 4)
        item.contentInsets = supplementaryItemContentInsets
        return item
    }

    enum SupplementaryItemType {
        case normal(height: CGFloat)
        case pinToTop(height: CGFloat)

        fileprivate var pinToVisibleBounds: Bool {
            switch self {
            case .normal: return false
            case .pinToTop: return true
            }
        }

        fileprivate var height: CGFloat {
            switch self {
            case let .normal(height): return height
            case let .pinToTop(height): return height
            }
        }

        func item(elementKind: String) -> NSCollectionLayoutBoundarySupplementaryItem {
            let sectionHeaderSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .estimated(height))
            let item = NSCollectionLayoutBoundarySupplementaryItem(layoutSize: sectionHeaderSize, elementKind: elementKind, alignment: .top)
            item.pinToVisibleBounds = pinToVisibleBounds
            return item
        }
    }
}
