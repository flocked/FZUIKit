//
//  NSUICollectionViewLayout+Waterfall+Comp.swift
//
//
//  Created by Florian Zand on 22.08.22.
//

#if os(macOS) || os(iOS) || os(tvOS)
    import Foundation
    import FZSwiftUtils
    #if os(macOS)
        import AppKit
    #elseif canImport(UIKit)
        import UIKit
    #endif

extension NSUICollectionViewLayout {
    
    /// The item order of a compositional waterfall layout.
    public enum WaterfallItemOrder {
        /// Each item is added to the shortest column.
        case shortestColumn
        /// The items are added to the columns from left to right.
        case leftToRight
        /// The items are added to the columns from right to left.
        case rightToLeft
    }
    
#if os(macOS) || os(iOS)
    /**
     A interactive waterfall collection view layout where the user can change the amount of columns by pinching the collection view.
     
     - Parameters:
     - columns: The amount of columns.
     - columnRange: The range of columns that the user can change to, if `isPinchable` or `isKeyDownControllable` is set to `true`.
     - isPinchable: A Boolean value that indicates whether the user can change the amount of columns by pinching the collection view.
     - isKeyDownControllable: A Boolean value that indicates whether the user can change the amount of columns by pressing the `plus` or `minus` key.
     - animateColumns: A Boolean value that indicates whether changing the amount of columns is animated.
     - spacing: The spacing between the items.
     - insets: The layout insets.
     - itemSizeProvider: The handler that provides the item sizes..
     */
    public static func waterfallCompositional(columns: Int = 3, columnRange: ClosedRange<Int> = 1...12, isPinchable: Bool = false, isKeyDownControllable: Bool = false, animateColumns: Bool = true, spacing: CGFloat = 8.0, insets: NSUIEdgeInsets = .init(8.0), itemOrder: WaterfallItemOrder = .shortestColumn, itemSizeProvider: @escaping (IndexPath) -> CGSize) -> NSUICollectionViewLayout {
        let layout = _waterfallCompositional(columns: columns,spacing: spacing, insets: insets, itemOrder: itemOrder, prepareHandler: pinchUpdateHandler(isPinchable || isKeyDownControllable), itemSizeProvider: itemSizeProvider)
        if isPinchable || isKeyDownControllable {
            layout.swizzlePrepareLayout()
            layout.columnConfiguration = .init(columns: columns, columnRange: columnRange, isPinchable: isPinchable, animated: animateColumns, changeAmount: isKeyDownControllable ? 1 : 0, changeAmountAlt: isKeyDownControllable ? columnRange.count : 0, changeAmountAlt2: 0) { columns in
                    .waterfallCompositional(columns: columns, columnRange: columnRange, isPinchable: isPinchable, isKeyDownControllable: isKeyDownControllable, animateColumns: animateColumns, spacing: spacing, insets: insets, itemSizeProvider: itemSizeProvider )
            }
        }
        return layout
    }
    
    static func pinchUpdateHandler(_ isPinchable: Bool) -> ((NSUICollectionViewCompositionalLayout)->())? {
        guard isPinchable else { return nil }
        return { layout in
            guard let collectionView = layout.collectionView, collectionView.pinchColumnsGestureRecognizer == nil else { return }
            collectionView.pinchColumnsGestureRecognizer = .init(target: nil, action: nil)
            collectionView.addGestureRecognizer(collectionView.pinchColumnsGestureRecognizer!)
        }
    }
#else
    /**
     Creates a waterfall collection view layout with the specifed amount of columns.
     
     - Parameters:
     - columns: The amount of columns.
     - spacing: The spacing between the items.
     - insets: The layout insets.
     - itemSizeProvider: The handler that provides the item sizes..
     */
    public static func waterfallCompositional(columns: Int = 2, spacing: CGFloat = 8.0, insets: NSUIEdgeInsets = .init(8.0), itemOrder: WaterfallItemOrder = .shortestColumn, itemSizeProvider: @escaping (IndexPath) -> CGSize) -> NSUICollectionViewLayout {
        _waterfallCompositional(columns: columns, spacing: spacing, insets: insets, itemOrder: itemOrder, itemSizeProvider: itemSizeProvider)
    }
#endif
    
    static func _waterfallCompositional(columns: Int = 2, spacing: CGFloat = 8.0, insets: NSUIEdgeInsets = .init(8.0), itemOrder: WaterfallItemOrder = .shortestColumn, prepareHandler: ((NSUICollectionViewCompositionalLayout)->())? = nil, itemSizeProvider: @escaping (IndexPath) -> CGSize) -> NSUICollectionViewLayout {
        var numberOfItems: (Int) -> Int = { _ in 0 }
        var prepareLayoutHandler: ()->() = { }
        let layout = NSUICollectionViewCompositionalLayout { section, environment in
            let height = environment.container.effectiveContentSize.height.clamped(min: 100)
            let groupLayoutSize = NSCollectionLayoutSize(
                widthDimension: .fractionalWidth(1),
                heightDimension: .estimated(height)
            )
            
            let group = NSCollectionLayoutGroup.custom(layoutSize: groupLayoutSize) { environment in
                let itemProvider = WaterfallLayoutItemProvider(columnCount: columns, spacing: spacing, itemOrder: itemOrder, contentSize: environment.container.effectiveContentSize, itemSizeProvider: itemSizeProvider)
                
                var items = [NSCollectionLayoutGroupCustomItem]()
                
                prepareLayoutHandler()
                
                for i in 0 ..< numberOfItems(section) {
                    
                    let indexPath = IndexPath(item: i, section: section)
                    let item = itemProvider.item(for: indexPath)
                    items.append(item)
                }
                return items
            }
          //  group.contentInsets = insets.directional
            
            let section = NSCollectionLayoutSection(group: group)
            // section.contentInsetsReference = configuration.contentInsetsReference
            return section
        }
        numberOfItems = { [weak layout] in
            layout?.collectionView?.numberOfItems(inSection: $0) ?? 0
        }
        prepareLayoutHandler = { [weak layout] in
            guard let layout = layout else { return }
            prepareHandler?(layout)
        }
        return layout
    }
    
    class WaterfallLayoutItemProvider {
        private var columnHeights: [CGFloat]
        private let columnCount: Int
        private let itemSizeProvider: (IndexPath) -> CGSize
        private let spacing: CGFloat
        private let contentSize: CGSize
        private let itemWidth: CGFloat
        private let itemOrder: WaterfallItemOrder
        private var columnIndex: Int = 0
        
        init(columnCount: Int = 2, spacing: CGFloat = 8, itemOrder: WaterfallItemOrder = .shortestColumn, contentSize: CGSize, itemSizeProvider: @escaping (IndexPath) -> CGSize) {
            columnHeights = [CGFloat](repeating: 0, count: columnCount)
            self.columnCount = columnCount
            self.itemSizeProvider = itemSizeProvider
            self.spacing = spacing
            self.itemWidth = (contentSize.width - ((CGFloat(columnCount) - 1) * spacing)) / CGFloat(columnCount)
            self.contentSize = contentSize
            self.itemOrder = itemOrder
            self.columnIndex = itemOrder == .leftToRight ? -1 : columnCount
        }
        
        func item(for indexPath: IndexPath) -> NSCollectionLayoutGroupCustomItem {
            let frame = frame(for: indexPath)
            columnHeights[columnIndex] = frame.maxY + spacing
            return NSCollectionLayoutGroupCustomItem(frame: frame)
        }
        
        func frame(for indexPath: IndexPath) -> CGRect {
            advanceColumnIndex()
            let size = itemSize(for: indexPath)
            let origin = itemOrigin(width: size.width)
            return CGRect(origin: origin, size: size)
        }
        
        private func itemOrigin(width: CGFloat) -> CGPoint {
            let y = columnHeights[columnIndex].rounded()
            let x = (width + spacing) * CGFloat(columnIndex)
            return CGPoint(x: x, y: y)
        }
        
        private func itemSize(for indexPath: IndexPath) -> CGSize {
            let height = itemHeight(for: indexPath, itemWidth: itemWidth)
            return CGSize(width: itemWidth, height: height)
        }
        
        private func itemHeight(for indexPath: IndexPath, itemWidth: CGFloat) -> CGFloat {
            let itemSize = itemSizeProvider(indexPath)
            let aspectRatio = itemSize.height / itemSize.width
            let itemHeight = itemWidth * aspectRatio
            return itemHeight.rounded()
        }
        
        private func advanceColumnIndex() {
            switch itemOrder {
            case .shortestColumn:
                columnIndex = columnHeights
                    .enumerated()
                    .min(by: { $0.element < $1.element })?
                    .offset ?? 0
            case .leftToRight:
                columnIndex += 1
                if columnIndex >= columnCount { columnIndex = 0 }
            case .rightToLeft:
                columnIndex -= 1
                if columnIndex < 0 { columnIndex = columnCount - 1 }
            }
        }
    }
}
#endif
