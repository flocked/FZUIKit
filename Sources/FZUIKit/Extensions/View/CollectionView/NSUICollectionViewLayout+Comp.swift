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
    - userInteraction: User interaction options for changing the amount of columns by pinching the collection view and pressing the `plus` or `minus` key.
    - itemAspectRatio: The aspect ratio of the items.
    - spacing: The spacing between the items.
    - insets: The insets of the layout.
    - header: The layout's supplementary header type.
    - footer: The layout's supplementary footer type.
 */
public static func gridCompositional(columns: Int = 3, userInteraction: ColumnsLayoutUserInteraction = .init(), itemAspectRatio: CGSize = CGSize(1, 1), spacing: CGFloat = 8.0, insets: NSDirectionalEdgeInsets = .init(16), header: NSCollectionLayoutBoundarySupplementaryItem.ItemType? = nil, footer: NSCollectionLayoutBoundarySupplementaryItem.ItemType? = nil) -> NSUICollectionViewLayout {
    let layout = _grid(columns: columns, itemAspectRatio: itemAspectRatio, spacing: spacing, insets: insets, header: header, footer: footer)
    layout.configurate(with: userInteraction) { columns in
        .gridCompositional(columns: columns, userInteraction: userInteraction, itemAspectRatio: itemAspectRatio, spacing: spacing, insets: insets, header: header, footer: footer)
    }
    return layout
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
public static func grid(columns: Int = 3, itemAspectRatio: CGSize = CGSize(1, 1), spacing: CGFloat = 8.0, insets: NSDirectionalEdgeInsets = .init(16), header: NSCollectionLayoutBoundarySupplementaryItem.ItemType? = nil, footer: NSCollectionLayoutBoundarySupplementaryItem.ItemType? = nil) -> NSUICollectionViewLayout {
    _grid(columns: columns, itemAspectRatio: itemAspectRatio, spacing: spacing, insets: insets, header: header, footer: footer)
}
#endif
internal static func _grid(columns: Int = 3, itemAspectRatio: CGSize = CGSize(1, 1), spacing: CGFloat = 8.0, insets: NSDirectionalEdgeInsets = .init(16), header: NSCollectionLayoutBoundarySupplementaryItem.ItemType? = nil, footer: NSCollectionLayoutBoundarySupplementaryItem.ItemType? = nil, center: NSUIUserInterfaceLayoutOrientation? = nil) -> CollectionViewCompositionalColumnLayout {
    let layout = CollectionViewCompositionalColumnLayout { (_: Int, layoutEnvironment: NSCollectionLayoutEnvironment) -> NSCollectionLayoutSection? in
        // Item
        let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(itemAspectRatio.width / itemAspectRatio.height), heightDimension: .fractionalHeight(1))

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

        /*
        if let center = center {
            let containerSize = layoutEnvironment.container.contentSize
            
            if center == .horizontal {
                let groupWidthDimension = group.layoutSize.widthDimension.dimension
                let itemWidth = containerSize.width * groupWidthDimension
                let inset = (containerSize.width - CGFloat(columns) * itemWidth) / 2.0
            } else {
                let groupHeightDimension = group.layoutSize.heightDimension.dimension
                let itemHeight = containerSize.height * groupHeightDimension
            }
        }
        */
        
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
    layout.columns = columns
    return layout
}
    
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
     A waterfall collection view layout.
     
     - Parameters:
        - columns: The amount of columns.
        - userInteraction: User interaction options for changing the amount of columns by pinching the collection view and pressing the `plus` or `minus` key.
        - spacing: The spacing between the items.
        - insets: The layout insets.
        - itemOrder: The order of the items.
        - itemSizeProvider: The handler that provides the item sizes..
     */
    public static func waterfallCompositional(columns: Int = 3, userInteraction: ColumnsLayoutUserInteraction = .init(), spacing: CGFloat = 8.0, insets: NSUIEdgeInsets = .init(8.0), itemOrder: WaterfallItemOrder = .shortestColumn, itemSizeProvider: @escaping (IndexPath) -> CGSize) -> NSUICollectionViewLayout {
        let layout = _waterfallCompositional(columns: columns,spacing: spacing, insets: insets, itemOrder: itemOrder, itemSizeProvider: itemSizeProvider)
        layout.configurate(with: userInteraction) { columns in
            .waterfallCompositional(columns: columns, userInteraction: userInteraction, spacing: spacing, insets: insets, itemOrder: itemOrder, itemSizeProvider: itemSizeProvider)
        }
        return layout
    }
    
    /// User interaction options for changing the amount of columns by pinching the collection view and pressing the `plus` or `minus` key.
    public struct ColumnsLayoutUserInteraction {
        public init(isPinchable: Bool = false, isKeyDownControllable: Bool = false, columnRange: ClosedRange<Int> = 1...12, animationDuration: CGFloat = 0.2) {
            self.isPinchable = isPinchable
            self.keyDownColumnControl = isKeyDownControllable ? .amount(1) : .disabled
            self.keyDownColumnControlShift = .disabled
            self.keyDownColumnControlCommand = .disabled
            self.columnRange = columnRange
            self.animationDuration = animationDuration
        }
        
        /// A Boolean value that indicates whether the user can change the amount of columns by pinching the collection view.
        public var isPinchable: Bool = false
        
        /// The amount of columns added or removed when the user presses the `plus` / `minus` key.
        public var keyDownColumnControl: KeyDownColumnControl = .disabled
        
        /// The amount of columns added or removed when the user presses the `plus` / `minus` key while holding `shift`.
        public var keyDownColumnControlShift: KeyDownColumnControl = .disabled
        
        /// The amount of columns added or removed when the user presses the `plus` / `minus` key while holding `command`.
        public var keyDownColumnControlCommand: KeyDownColumnControl = .disabled
        
        /// The range of columns that the user can change to.
        public var columnRange: ClosedRange<Int> = 1...12
        
        /**
         The animation duration when the user changes the amount of columns.
                  
         A value of `0.0` changes the columns amount without any animation.
         */
        public var animationDuration: CGFloat = 0.25
        
        /// Key down control of the column amount.
        public enum KeyDownColumnControl: Hashable {
            /// The amount of columns is changed by the specified amount.
            case amount(Int)
            /// The amount of columns is changed to the minimum column range.
            case fullRange
            /// Keyboard control is disabled.
            case disabled
            
            var value: Int {
                switch self {
                case .amount(let value): return value
                case .fullRange: return -1
                case .disabled: return 0
                }
            }
            
            var clamped: Self {
                switch self {
                case .amount(let value): return value == 0 ? .disabled : .amount(value.clamped(min: 0))
                default: return self
                }
            }
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
    
    static func _waterfallCompositional(columns: Int = 2, spacing: CGFloat = 8.0, insets: NSUIEdgeInsets = .init(8.0), itemOrder: WaterfallItemOrder = .shortestColumn, itemSizeProvider: @escaping (IndexPath) -> CGSize) -> CollectionViewCompositionalColumnLayout {
        var numberOfItems: (Int) -> Int = { _ in 0 }
        let layout = CollectionViewCompositionalColumnLayout { section, environment in
            let height = environment.container.effectiveContentSize.height.clamped(min: 100)
            let groupLayoutSize = NSCollectionLayoutSize(
                widthDimension: .fractionalWidth(1),
                heightDimension: .estimated(height)
            )
            
            let group = NSCollectionLayoutGroup.custom(layoutSize: groupLayoutSize) { environment in
                let itemProvider = WaterfallLayoutItemProvider(columnCount: columns, spacing: spacing, itemOrder: itemOrder, contentSize: environment.container.effectiveContentSize, itemSizeProvider: itemSizeProvider)
                
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
        layout.columns = columns
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

class CollectionViewCompositionalColumnLayout: NSUICollectionViewCompositionalLayout, InteractiveCollectionViewLayout {

    var columns = 3
    var columnRange: ClosedRange<Int> = 2...12
    var isPinchable = false
    var animationDuration: TimeInterval = 0.25
    var keyDownColumnChangeAmount = 0
    var keyDownColumnChangeAmountAlt = 0
    var keyDownColumnChangeAmountShift = 0
    var invalidation: ((_ columns: Int) -> NSUICollectionViewLayout)?
    
    #if os(macOS) || os(iOS)
    func configurate(with userInteraction: ColumnsLayoutUserInteraction, invalidation: @escaping (_ columns: Int) -> NSUICollectionViewLayout) {
        self.columnRange = userInteraction.columnRange
        self.isPinchable = userInteraction.isPinchable
        self.keyDownColumnChangeAmount = userInteraction.keyDownColumnControl.value
        self.keyDownColumnChangeAmountAlt = userInteraction.keyDownColumnControlCommand.value
        self.keyDownColumnChangeAmountShift = userInteraction.keyDownColumnControlShift.value
        self.animationDuration = userInteraction.animationDuration
        self.invalidation = invalidation
    }
    
    override func prepare() {
        super.prepare()
        collectionView?.setupColumnInteractionGestureRecognizer(needsGestureRecognizer)
    }
    #endif
    
    func _invalidateLayout(animated: Bool) {
        collectionView?.setCollectionViewLayout(invalidation?(columns) ?? self, animated: animated)
    }
}

#endif
