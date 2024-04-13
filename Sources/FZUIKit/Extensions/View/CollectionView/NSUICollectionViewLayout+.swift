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
                
        #if os(macOS) || os(iOS)
        /**
         A interactive grid layout where the user can change the amount of columns by pinching the collection view.
         
         - Parameters:
            - columns: The amount of columns for the grid.
            - columnRange: The range of columns that the user can change to, if `isPinchable` or `isKeyDownControllable` is set to `true`.
            - isPinchable: A Boolean value that indicates whether the user can change the amount of columns by pinching the collection view.
            - isKeyDownControllable: A Boolean value that indicates whether the user can change the amount of columns by pressing the `plus` or `minus` key.
            - animateColumns: A Boolean value that indicates whether changing the amount of columns is animated.
            - itemAspectRatio: The aspect ratio of the items.
            - spacing: The spacing between the items.
            - insets: The insets of the layout.
            - header: The layout's supplementary header type.
            - footer: The layout's supplementary footer type.
         */
        static func grid(columns: Int = 3, columnRange: ClosedRange<Int> = 1...12, isPinchable: Bool = false, isKeyDownControllable: Bool = false, animateColumns: Bool = true, itemAspectRatio: CGSize = CGSize(1, 1), spacing: CGFloat = 8.0, insets: NSDirectionalEdgeInsets = .init(16), header: NSCollectionLayoutBoundarySupplementaryItem.ItemType? = nil, footer: NSCollectionLayoutBoundarySupplementaryItem.ItemType? = nil) -> NSUICollectionViewLayout {
            let layout = _grid(columns: columns, itemAspectRatio: itemAspectRatio, spacing: spacing, insets: insets, header: header, footer: footer, prepareHandler: pinchUpdateHandler(isPinchable || isKeyDownControllable))
            if isPinchable || isKeyDownControllable {
                layout.columnConfiguration = .init(columns: columns, columnRange: columnRange, isPinchable: isPinchable, animated: animateColumns, changeAmount: isKeyDownControllable ? 1 : 0, changeAmountAlt: isKeyDownControllable ? columnRange.count : 0, changeAmountAlt2: 0) { columns in
                        .grid(columns: columns, columnRange: columnRange, isPinchable: isPinchable, isKeyDownControllable: isKeyDownControllable, animateColumns: animateColumns, itemAspectRatio: itemAspectRatio, insets: insets, header: header, footer: footer)
                }
            }
            return layout
        }
        
        func swizzlePrepareLayout() {
            guard !isMethodReplaced(NSSelectorFromString("prepareLayout")) else { return }
            do {
                try replaceMethod(
                    NSSelectorFromString("prepareLayout"),
                    methodSignature: (@convention(c)  (AnyObject, Selector) -> ()).self,
                    hookSignature: (@convention(block)  (AnyObject) -> ()).self) { store in {
                        object in
                        if let collectionView = (object as? NSUICollectionViewLayout)?.collectionView, collectionView.pinchColumnsGestureRecognizer == nil {
                            collectionView.pinchColumnsGestureRecognizer = .init(target: nil, action: nil)
                            collectionView.addGestureRecognizer(collectionView.pinchColumnsGestureRecognizer!)
                        }
                        store.original(object, NSSelectorFromString("prepareLayout"))
                    }
                    }
            } catch {
                Swift.debugPrint(error)
            }
        }
        #else
        /**
         A collection view layout that displays the items in a grid.
         
         - Parameters:
            - columns: The amount of columns for the grid.
            - itemAspectRatio: The aspect ratio of the items.
            - spacing: The spacing between the items.
            - insets: The insets of the layout.
            - header: The layout's supplementary header type.
            - footer: The layout's supplementary footer type.
         */
        static func grid(columns: Int = 3, itemAspectRatio: CGSize = CGSize(1, 1), spacing: CGFloat = 8.0, insets: NSDirectionalEdgeInsets = .init(16), header: NSCollectionLayoutBoundarySupplementaryItem.ItemType? = nil, footer: NSCollectionLayoutBoundarySupplementaryItem.ItemType? = nil) -> NSUICollectionViewLayout {
            _grid(columns: columns, itemAspectRatio: itemAspectRatio, spacing: spacing, insets: insets, header: header, footer: footer)
        }
        #endif
        internal static func _grid(columns: Int = 3, itemAspectRatio: CGSize = CGSize(1, 1), spacing: CGFloat = 8.0, insets: NSDirectionalEdgeInsets = .init(16), header: NSCollectionLayoutBoundarySupplementaryItem.ItemType? = nil, footer: NSCollectionLayoutBoundarySupplementaryItem.ItemType? = nil, prepareHandler: ((NSUICollectionViewCompositionalLayout)->())? = nil) -> NSUICollectionViewLayout {
            var prepareLayoutHandler: ()->() = { }
            let layout = NSUICollectionViewCompositionalLayout { (_: Int, layoutEnvironment: NSCollectionLayoutEnvironment) -> NSCollectionLayoutSection? in
                
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

                prepareLayoutHandler()
                let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1),
                                                       heightDimension: .absolute(groupHeight))
                let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitem: item, count: columns)
                group.interItemSpacing = .fixed(spacing)

                // Section
                let section = NSCollectionLayoutSection(group: group)
                section.interGroupSpacing = spacing
                section.contentInsets = insets

                // Header & Footer
                if let headerItem = header?.item(elementKind: NSUICollectionView.elementKindSectionHeader) {
                    section.boundarySupplementaryItems.append(headerItem)
                }
                if let footherItem = footer?.item(elementKind: NSUICollectionView.elementKindSectionFooter) {
                    section.boundarySupplementaryItems.append(footherItem)
                }
                return section
            }
            prepareLayoutHandler = { [weak layout] in
                guard let layout = layout else { return }
                prepareHandler?(layout)
            }
            return layout
        }
    }
#endif
