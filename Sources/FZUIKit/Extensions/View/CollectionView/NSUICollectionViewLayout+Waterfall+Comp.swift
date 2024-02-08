//
//  NSUICollectionViewLayout+Waterfall+Comp.swift
//
//
//  Created by Florian Zand on 22.08.22.
//

#if os(macOS) || os(iOS) || os(tvOS)
    import Foundation
    #if os(macOS)
        import AppKit
    #elseif canImport(UIKit)
        import UIKit
    #endif

    public typealias CollectionViewItemSizeProvider = (IndexPath) -> CGSize

    public extension NSUICollectionViewLayout {
        /**
         Creates a waterfall collection view layout with the specifed amount of columns.
         
         - Parameters:
            - columnCount: The amount of columns.
            - spacing: The spacing between the items.
            - insets: The layout insets.
            - itemSizeProvider: The handler that provides the item sizes..
         */
        static func waterfallCompositional(columnCount: Int = 2, spacing: CGFloat = 8.0, insets: NSUIEdgeInsets = .init(8.0), itemSizeProvider: @escaping (IndexPath) -> CGSize) -> NSUICollectionViewLayout {
            var numberOfItems: (Int) -> Int = { _ in 0 }
            let layout = NSUICollectionViewCompositionalLayout { section, environment in
                let groupLayoutSize = NSCollectionLayoutSize(
                    widthDimension: .fractionalWidth(1),
                    heightDimension: .estimated(environment.container.effectiveContentSize.height)
                )
                let group = NSCollectionLayoutGroup.custom(layoutSize: groupLayoutSize) { environment in
                    let itemProvider = LayoutItemProvider(columnCount: columnCount, spacing: spacing, environment: environment, itemSizeProvider: itemSizeProvider)
                    var items = [NSCollectionLayoutGroupCustomItem]()
                    for i in 0 ..< numberOfItems(section) {
                        let indexPath = IndexPath(item: i, section: section)
                        let item = itemProvider.item(for: indexPath)
                        items.append(item)
                    }
                    return items
                }
                group.contentInsets = insets.directional

                let section = NSCollectionLayoutSection(group: group)
                // section.contentInsetsReference = configuration.contentInsetsReference
                return section
            }
            numberOfItems = { [weak layout] in
                layout?.collectionView?.numberOfItems(inSection: $0) ?? 0
            }
            return layout
        }
    }

    public class LayoutItemProvider {
        private var columnHeights: [CGFloat]
        private let columnCount: CGFloat
        private let itemSizeProvider: CollectionViewItemSizeProvider
        private let spacing: CGFloat
        private let contentSize: CGSize

        public init(columnCount: Int = 2,
                    spacing: CGFloat = 8,
                    environment: NSCollectionLayoutEnvironment,
                    itemSizeProvider: @escaping CollectionViewItemSizeProvider)
        {
            columnHeights = [CGFloat](repeating: 0, count: columnCount)
            self.columnCount = CGFloat(columnCount)
            self.itemSizeProvider = itemSizeProvider
            self.spacing = spacing
            contentSize = environment.container.effectiveContentSize
        }

        public func item(for indexPath: IndexPath) -> NSCollectionLayoutGroupCustomItem {
            let frame = frame(for: indexPath)
            columnHeights[columnIndex()] = frame.maxY + spacing
            return NSCollectionLayoutGroupCustomItem(frame: frame)
        }

        private func frame(for indexPath: IndexPath) -> CGRect {
            let size = itemSize(for: indexPath)
            let origin = itemOrigin(width: size.width)
            return CGRect(origin: origin, size: size)
        }

        private func itemOrigin(width: CGFloat) -> CGPoint {
            let y = columnHeights[columnIndex()].rounded()
            let x = (width + spacing) * CGFloat(columnIndex())
            return CGPoint(x: x, y: y)
        }

        private func itemSize(for indexPath: IndexPath) -> CGSize {
            let width = itemWidth()
            let height = itemHeight(for: indexPath, itemWidth: width)
            return CGSize(width: width, height: height)
        }

        private func itemWidth() -> CGFloat {
            let spacing = (columnCount - 1) * spacing
            return (contentSize.width - spacing) / columnCount
        }

        private func itemHeight(for indexPath: IndexPath, itemWidth: CGFloat) -> CGFloat {
            let itemSize = itemSizeProvider(indexPath)
            let aspectRatio = itemSize.height / itemSize.width
            let itemHeight = itemWidth * aspectRatio
            return itemHeight.rounded()
        }

        private func columnIndex() -> Int {
            columnHeights
                .enumerated()
                .min(by: { $0.element < $1.element })?
                .offset ?? 0
        }
    }
#endif
