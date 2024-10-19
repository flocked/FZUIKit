//
//  NSUICollectionViewLayout+.swift
//
//
//  Created by Florian Zand on 23.07.23.
//

#if os(macOS) || os(iOS) || os(tvOS)
    import FZSwiftUtils
    #if os(macOS)
        import AppKit
    #elseif canImport(UIKit)
        import UIKit
    #endif

    public extension NSUICollectionViewLayout {
        /**
         A collection view layout that displays the items as a list.
         
         - Parameters:
            - rowHeight: The height of each row.
            - seperatorLine: A Boolean value that indicates whether the layout displays seperator lines.
         */
        static func list(rowHeight: CGFloat, seperatorLine: Bool) -> NSUICollectionViewLayout {
            let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0),
                                                  heightDimension: .fractionalHeight(1.0))

            var itemSupplementaryItems = [NSCollectionLayoutBoundarySupplementaryItem]()
            if seperatorLine {
                itemSupplementaryItems.append(.bottomSeperatorLine)
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
        
        /**
         A collection view layout that displays the items with a fixed width or height.
         
         - Parameters:
            - orientation: The orientation of the items.
            - itemSize: The fixed width or height of the items.
            - spacing: The spacing between the items. The default value is `0`.
            - scrollingBehavior: The scrolling behavior of the items. The default value is `continuous`.
            - insets: The insets of the layout. The default value is `zero`.
         */
        static func fixed(orientation: NSUIUserInterfaceLayoutOrientation, itemSize: CGFloat, spacing: CGFloat = 0.0, scrollingBehavior: NSUICollectionLayoutSectionOrthogonalScrollingBehavior = .continuous, insets: NSDirectionalEdgeInsets = .zero) -> NSUICollectionViewLayout {
            let layoutItemSize: NSCollectionLayoutSize
            if orientation == .horizontal {
                layoutItemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0),
                                                  heightDimension: .absolute(itemSize))
            } else {
                layoutItemSize = NSCollectionLayoutSize(widthDimension: .absolute(itemSize),
                                                  heightDimension: .fractionalHeight(1.0))
            }

            let item = NSCollectionLayoutItem(layoutSize: layoutItemSize, supplementaryItems: [])
            let groupSize: NSCollectionLayoutSize
            if orientation == .horizontal {
                groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0),
                                                       heightDimension: .fractionalHeight(1.0))
            } else {
                groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0),
                                                   heightDimension: .fractionalHeight(1.0))
            }
            let group: NSCollectionLayoutGroup
            if orientation == .horizontal {
                group = NSCollectionLayoutGroup.vertical(layoutSize: groupSize,
                                                               subitems: [item])
            } else {
                group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize,
                                                               subitems: [item])
            }
            group.interItemSpacing = .fixed(spacing)
            group.contentInsets = insets
            
            let section = NSCollectionLayoutSection(group: group)
            section.orthogonalScrollingBehavior = scrollingBehavior
            
            let layout = NSUICollectionViewCompositionalLayout(section: section)
            return layout
        }

        /**
         A collection view layout that displays each item full size.
         
         - Parameters:
            - direction: The item direction of the layout.
            - paging: A Boolean value that indicates whether the items are paging.
            - itemSpacing: The spacing between the items.
            - insets: The insets of the layout.
         */
        static func fullSize(direction: NSUICollectionView.ScrollDirection, paging: Bool, itemSpacing: CGFloat = 0.0, insets: NSDirectionalEdgeInsets = .zero) -> NSUICollectionViewLayout {
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
            
            if itemSpacing != 0.0 {
                layoutGroup.interItemSpacing = .fixed(itemSpacing)
            }

            let layoutSection = NSCollectionLayoutSection(group: layoutGroup)
            layoutSection.contentInsets = insets
            layoutSection.orthogonalScrollingBehavior = paging ? .paging : .continuous
            let config = NSUICollectionViewCompositionalLayoutConfiguration()
            config.scrollDirection = direction
            let layout = NSUICollectionViewCompositionalLayout(section: layoutSection, configuration: config)
            return layout
        }
    }
#endif
