//
//  NSUICollectionViewLayout+Column.swift
//
//  Parts taken from:
//  Created by Nicholas Tau on 6/30/14.
//  Copyright (c) 2014 Nicholas Tau. All rights reserved.
//
//  Created by Florian Zand on 06.06.22.
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
     A interactive waterfall layout where the user can change the amount of columns by pinching the collection view.

     - Parameters:
        - columns: The amount of columns.
        - spacing: The spacing between the columns and items.
        - insets: The layout insets.
        - orientation: The orientation of the layout.
        - itemSizeProvider: The handler that provides the item sizes..
     */
    static func waterfall(columns: Int, spacing: CGFloat = 10, insets: NSUIEdgeInsets = .init(10.0), orientation: NSUIUserInterfaceLayoutOrientation = .horizontal, itemSizeProvider: @escaping (_ indexPath: IndexPath) -> CGSize) -> ColumnCollectionViewLayout {
        let layout = ColumnCollectionViewLayout.init(columns: columns, orientation: orientation, spacing: spacing, insets: insets)
        layout.itemLayout = .waterfall(itemSizeProvider)
        return layout
    }
    
    /**
     Creates a grid collection view layout.
     
     - Parameters:
        - columns: The amount of columns for the grid.
        - spacing: The spacing between the columns and items.
        - insets: The insets of the layout.
        - orientation: The orientation of the layout.
        - itemAspectRatio: The aspect ratio of the items.
     */
    static func grid(columns: Int, orientation: NSUIUserInterfaceLayoutOrientation = .horizontal, spacing: CGFloat = 10, insets: NSUIEdgeInsets = .init(10.0), itemAspectRatio: CGSize = CGSize(1,1)) -> ColumnCollectionViewLayout {
        let layout = ColumnCollectionViewLayout.init(columns: columns, orientation: orientation, spacing: spacing, insets: insets)
        layout.itemLayout = .grid(itemAspectRatio)
        return layout
    }
}

/// A layout that organizes items into columns (either as `waterfall` or `grid`).
public class ColumnCollectionViewLayout: NSUICollectionViewLayout, InteractiveCollectionViewLayout {
    
    /// Handler that provides the sizes for each item.
    public typealias ItemSizeProvider = (_ indexPath: IndexPath) -> CGSize
    
    /// The layout of the items.
    public enum ItemLayout {
        /// Flexible item heights.
        case waterfall(_ itemSizeProvider: ItemSizeProvider)
        /// Fixed item sizes.
        case grid(_ aspectRatio: CGSize)
    }
    
    /// The layout of the items.
    public var itemLayout: ItemLayout = .grid(CGSize(1.0))
    
    /// Sets handler that provides the sizes for each item.
    public func itemLayout(_ itemLayout: ItemLayout) -> Self {
        self.itemLayout = itemLayout
        return self
    }
    
    /// The order each item is displayed.
    open var itemOrder: ItemSortOrder = .shortestColumn
    
    /// Sets the order each item is displayed.
    @discardableResult
    open func itemOrder(_ direction:  ItemSortOrder) -> Self {
        itemOrder = direction
        return self
    }
    
    /// The order each item is displayed.
    public enum ItemSortOrder: Int, Hashable {
        /// Each item is added to the shortest column.
        case shortestColumn
        /// The items are added to the columns from left to right.
        case leftToRight
        /// The items are added to the columns from right to left.
        case rightToLeft
    }
    
    /// The amount of columns.
   public var columns: Int = 3
    
    /// Sets the amount of columns.
    @discardableResult
    open func columns(_ columns: Int) -> Self {
        self.columns = columns
        return self
    }
    
    /// The orientation of the columns.
    public var orientation: NSUIUserInterfaceLayoutOrientation = .horizontal
    
    /// Sets the orientation of the columns.
    public func orientation(_ orientation: NSUIUserInterfaceLayoutOrientation = .horizontal) -> Self {
        self.orientation = orientation
        return self
    }
        
#if os(macOS) || os(iOS)
    /// User interaction options for changing the amount of columns by pinching the collection view and pressing the `plus` or `minus` key.
    public struct UserInteraction {
        
        /// A Boolean value that indicates whether the user can change the amount of columns by pinching the collection view.
        public var isPinchable: Bool = false
        
        /// The range of columns that the user can change to.
        public var columnRange: ClosedRange<Int> = 2...12 {
            didSet { columnRange = columnRange.clamped(min: 1) }
        }
        
        /**
         The animation duration when the user changes the amount of columns.
                  
         A value of `0.0` changes the columns amount without any animation.
         */
        public var animationDuration: CGFloat = 0.25
        
        #if os(macOS)
        
        /// The amount of columns added or removed when the user presses the `plus` / `minus` key.
        public var keyDownColumnControl: KeyDownColumnControl = .disabled
        
        /// The amount of columns added or removed when the user presses the `plus` / `minus` key while holding `shift`.
        public var keyDownColumnControlShift: KeyDownColumnControl = .disabled
        
        /// The amount of columns added or removed when the user presses the `plus` / `minus` key while holding `command`.
        public var keyDownColumnControlCommand: KeyDownColumnControl = .disabled
        
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
        
        public init(isPinchable: Bool = false, isKeyDownControllable: Bool = false, columnRange: ClosedRange<Int> = 1...12, animationDuration: CGFloat = 0.2) {
            self.isPinchable = isPinchable
            self.keyDownColumnControl = isKeyDownControllable ? .amount(1) : .disabled
            self.keyDownColumnControlShift = .disabled
            self.keyDownColumnControlCommand = .disabled
            self.columnRange = columnRange
            self.animationDuration = animationDuration
        }
        
        #endif
    }
    
    /// User interaction options for changing the amount of columns by pinching the collection view and pressing the `plus` or `minus` key.
    public var userInteraction: UserInteraction = .init() {
        didSet {
            collectionView?.setupColumnInteractionGestureRecognizer(needsGestureRecognizer)
        }
    }
    
    var isPinchable: Bool {
        userInteraction.isPinchable
    }
    
    #if os(macOS)
    var keyDownColumnChangeAmount: Int {
        userInteraction.keyDownColumnControl.value
    }
    
    var keyDownColumnChangeAmountAlt: Int  {
        userInteraction.keyDownColumnControlCommand.value
    }
    
    var keyDownColumnChangeAmountShift: Int {
        userInteraction.keyDownColumnControlShift.value
    }
    #endif
    
    var columnRange: ClosedRange<Int> {
        userInteraction.columnRange
    }
    
    var animationDuration: TimeInterval {
        userInteraction.animationDuration
    }
    
#else
    var isPinchable = false
    var columnRange = 2...12
    var animationDuration: TimeInterval = 0.25
#endif
    
    /// The spacing between the columns.
    open var columnSpacing: CGFloat = 10 {
        didSet { columnSpacing = columnSpacing.clamped(min: 0) }
    }
    
    /// Sets the spacing between the columns.
    @discardableResult
    open func columnSpacing(_ spacing:  CGFloat) -> Self {
        columnSpacing = spacing
        return self
    }
    
    /// The spacing between the items.
    open var itemSpacing: CGFloat = 10.0  {
        didSet { itemSpacing = itemSpacing.clamped(min: 0) }
    }
    
    /// Sets the spacing between the items.
    @discardableResult
    open func itemSpacing(_ spacing:  CGFloat) -> Self {
        self.itemSpacing = spacing
        return self
    }
    
    public struct HeaderFooterAttributes: Hashable {
        /// The height of the header/footer.
        public var height: CGFloat = 0.0
        
        /// The inset of the header/footer.
        public var inset: NSUIEdgeInsets = .zero
        
        /**
         A Boolean value that indicates whether headers pin to the top/footers pin to the bottom of the collection view bounds during scrolling.
                  
         When this property is `true`, section header views scroll with content until they reach the top of the screen, at which point they are pinned to the upper bounds of the collection view. Each new header view that scrolls to the top of the screen pushes the previously pinned header view offscreen.
         */
        public var pinToVisibleBounds: Bool = false
    }
    
    /// The header attributes.
    public var header: HeaderFooterAttributes = .init()
    
    /// Sets the header attributes.
    @discardableResult
    open func header(_ header: HeaderFooterAttributes) -> Self {
        self.header = header
        return self
    }

    /// The footer attributes.
    public var footer: HeaderFooterAttributes = .init()
    
    /// Sets the footer attributes.
    @discardableResult
    open func footer(_ footer: HeaderFooterAttributes) -> Self {
        self.footer = footer
        return self
    }
    
    /// The sizing for each column.
    enum ColumnSizing: Hashable {
        /// Fixed column size.
        case fixed(CGFloat)
        /// Fixed column size.
        case relative(CGFloat)
        /// Each column size.
        case automatic
    }
    
    /// The sizing for each column.
    var columnSizing: ColumnSizing = .automatic {
        didSet {
            switch columnSizing {
            case .relative(let value):
                columnSizing = .relative(value.clamped(to: 0.0...1.0))
            default: break
            }
        }
    }
    
    /// Sets the sizing for each column.
    @discardableResult
    func columnSizing(_ columnSizing: ColumnSizing) -> Self {
        self.columnSizing = columnSizing
        return self
    }
    
    @objc var scrollDirection: NSUICollectionView.ScrollDirection {
        orientation == .horizontal ? .vertical : .horizontal
    }
    
    /// The margins used to lay out content in a section.
    open var sectionInset: NSUIEdgeInsets = NSUIEdgeInsets(10)
    
    /// Sets the margins used to lay out content in a section.
    @discardableResult
    open func sectionInset(_ inset: NSUIEdgeInsets) -> Self {
        sectionInset = inset
        return self
    }
    
    /// A Boolean value that indicates whether to apply the ``sectionInset`` to the  safe area of the collection view.
    @available(macOS 11.0, iOS 13.0, tvOS 13.0, *)
    open var sectionInsetUsesSafeArea: Bool {
        get { _sectionInsetUsesSafeArea }
        set { _sectionInsetUsesSafeArea = newValue }
    }
    
    /// Sets the Boolean value that indicates whether to apply the ``sectionInset`` to the  safe area of the collection view.
    @available(macOS 11.0, iOS 13.0, tvOS 13.0, *)
    @discardableResult
    open func sectionInsetUsesSafeArea(_ useSafeArea: Bool) -> Self {
        sectionInsetUsesSafeArea = useSafeArea
        return self
    }
    
    private var columnSizes: [[CGFloat]] = []
    private var sectionItemAttributes: [[NSUICollectionViewLayoutAttributes]] = []
    private var allItemAttributes: [NSUICollectionViewLayoutAttributes] = []
    private var headersAttributes: [HeaderFooterLayoutAttributes] = []
    private var footersAttributes: [HeaderFooterLayoutAttributes] = []
    private var unionRects: [CGRect] = []
    private var mappedItemColumns: [IndexPath: Int] = [:]
    private var _sectionInsetUsesSafeArea: Bool = false
    private var previousBounds: CGRect = .zero
    private var didCalcuateItemAttributes: Bool = false
    /// How many items to be union into a single rectangle
    private let unionSize = 20
    
    private func collectionViewContentSizing(includingSectionInset: Bool = true) -> CGSize {
        guard let collectionView = collectionView else { return .zero }
        var size = collectionView.bounds.size
        #if os(macOS)
        var insets: NSEdgeInsets = .zero
        if #available(macOS 11.0, *), sectionInsetUsesSafeArea {
            insets = collectionView.enclosingScrollView?.safeAreaInsets ?? .zero
        } else {
            insets = collectionView.enclosingScrollView?.contentInsets ?? .zero
        }
        #else
        let insets = sectionInsetUsesSafeArea ? collectionView.adjustedContentInset : collectionView.contentInset
        #endif
        size.width -= insets.width
        size.height -= insets.height + header.height + header.inset.height + footer.height + footer.inset.height
        if includingSectionInset {
            size.width -= sectionInset.width
            size.height -= sectionInset.height
        }
        return size
    }

    var itemSizing: CGFloat {
        let spaceColumCount = CGFloat(columns - 1)
        let size = orientation == .horizontal ? collectionViewContentSizing().width : collectionViewContentSizing().height
        switch columnSizing {
        case .fixed(let value):
            return value
        case .relative(let value):
            return (orientation == .horizontal ? collectionViewContentSizing().width : collectionViewContentSizing().height) * value
        case .automatic:
            return ((size - (spaceColumCount * columnSpacing)) / CGFloat(columns))
        }
    }
    
    override open func prepare() {
        // Swift.print("prepare")
        if !didCalcuateItemAttributes {
            #if os(macOS)
            previousBounds = collectionView?.visibleRect ?? previousBounds
            #else
            previousBounds = collectionView?.bounds ?? previousBounds
            #endif
            #if os(macOS) || os(iOS)
            collectionView?.setupColumnInteractionGestureRecognizer(needsGestureRecognizer)
            #endif
            prepareItemAttributes()
        } else {
            didCalcuateItemAttributes = false
        }
    }
    
    func prepareItemAttributes(keepItemOrder: Bool = false) {
        guard let collectionView = collectionView, collectionView.numberOfSections > 0  else { return }
        let numberOfSections = collectionView.numberOfSections

        headersAttributes = []
        footersAttributes = []
        unionRects = []
        allItemAttributes = []
        sectionItemAttributes = []
        columnSizes = Array(repeating: Array(repeating: CGFloat(0.0), count: columns), count: numberOfSections)

        var top: CGFloat = 0.0
        var attributes = NSUICollectionViewLayoutAttributes()

        for section in 0 ..< numberOfSections {
            // MARK: 1. Get section-specific metrics (itemSpacing, sectionInset)

            let columns = columnSizes[section].count
            let itemSizing = itemSizing

            // MARK: 2. Section header

            top += header.inset.top
            
            if header.height > 0 {
                let attributes = HeaderFooterLayoutAttributes(forSupplementaryViewOfKind: NSUICollectionView.elementKindSectionHeader, with: IndexPath(item: 0, section: section))
                attributes.frame = CGRect(x: header.inset.left, y: top, width: collectionView.bounds.width - header.inset.width, height: header.height)
                attributes.cachedOrigin = attributes.frame.origin
                headersAttributes.append(attributes)
                allItemAttributes.append(attributes)
                top = attributes.frame.maxY + header.inset.bottom
            }
            
            top += sectionInset.top
            columnSizes[section] = [CGFloat](repeating: top, count: columns)

            // MARK: 3. Section items

            let itemCount = collectionView.numberOfItems(inSection: section)
            var itemAttributes: [NSUICollectionViewLayoutAttributes] = []

            for idx in 0 ..< itemCount {
                let indexPath = IndexPath(item: idx, section: section)
                let columnIndex = nextColumnIndexForItem(indexPath, keepItemOrder: keepItemOrder)
                mappedItemColumns[indexPath] = columnIndex
                #if os(macOS)
                attributes = NSUICollectionViewLayoutAttributes(forItemWith: indexPath)
                #elseif canImport(UIKit)
                attributes = NSUICollectionViewLayoutAttributes(forCellWith: indexPath)
                #endif
                
                if orientation == .horizontal {
                    attributes.frame.origin.x = sectionInset.left + (itemSizing + columnSpacing) * CGFloat(columnIndex)
                    attributes.frame.origin.y = columnSizes[section][columnIndex]
                } else {
                    attributes.frame.origin.y = sectionInset.top + (itemSizing + columnSpacing) * CGFloat(columnIndex)
                    attributes.frame.origin.x = columnSizes[section][columnIndex]
                }

                attributes.frame.size = CGSize(orientation == .horizontal ? itemSizing : .zero, orientation == .horizontal ? .zero : itemSizing)
                
                switch itemLayout {
                case .waterfall(let itemSizeProvider):
                    let itemSize = itemSizeProvider(indexPath)
                    if orientation == .horizontal {
                        if itemSize.height > 0.0 {
                            attributes.frame.size.height = itemSize.width > 0.0 ?  (itemSize.height * itemSizing / itemSize.width) : itemSize.height
                        }
                    } else if itemSize.width > 0.0 {
                        attributes.frame.size.width = itemSize.height > 0.0 ? (itemSize.width * itemSizing / itemSize.height) : itemSize.width
                    }
                case .grid(let itemAspectRatio):
                    if orientation == .horizontal {
                        attributes.frame.size.height = itemAspectRatio.aspectRatio * itemSizing
                    } else {
                        attributes.frame.size.width = itemAspectRatio.aspectRatio * itemSizing
                    }
                }

                itemAttributes.append(attributes)
                allItemAttributes.append(attributes)
                columnSizes[section][columnIndex] = (orientation == .horizontal ? attributes.frame.maxY : attributes.frame.maxX) + itemSpacing
            }
            sectionItemAttributes.append(itemAttributes)

            // MARK: 4. Section footer

            let columnIndex = longestColumnIndex(inSection: section)
            top = columnSizes[section][columnIndex] - itemSpacing + sectionInset.bottom
            
            top += footer.inset.top
            if footer.height > 0 {
                let attributes = HeaderFooterLayoutAttributes(forSupplementaryViewOfKind: NSUICollectionView.elementKindSectionFooter, with: IndexPath(item: 0, section: section))
                attributes.frame = CGRect(x: footer.inset.left, y: top, width: collectionView.bounds.width - footer.inset.width, height: footer.height)
                attributes.cachedOrigin = attributes.frame.origin
                footersAttributes.append(attributes)
                allItemAttributes.append(attributes)
                top = attributes.frame.maxY + footer.inset.bottom
            }
            
            columnSizes[section] = [CGFloat](repeating: top, count: columns)
        }
        
        updateHeaderFooterAttributes()
        updateUnionRects()
    }
    
    func updateUnionRects() {
        unionRects = []
        var idx = 0
        while idx < allItemAttributes.count {
            let rect1 = allItemAttributes[idx].frame
            idx = min(idx + unionSize, allItemAttributes.count) - 1
            let rect2 = allItemAttributes[idx].frame
            unionRects.append(rect1.union(rect2))
            idx += 1
        }
    }
    
    func updateHeaderFooterAttributes() {
        guard let collectionView = collectionView else { return }
        if header.pinToVisibleBounds {
            for attribute in headersAttributes {
                #if os(macOS)
                let nextHeaderOrigin = headersAttributes[safe: attribute.indexPath!.section + 1]?.frame.origin ?? CGPoint(.greatestFiniteMagnitude)
                #else
                let nextHeaderOrigin = headersAttributes[safe: attribute.indexPath.section + 1]?.frame.origin ?? CGPoint(.greatestFiniteMagnitude)
                #endif
                let offsetAdjustment = collectionView.contentOffset.y
                let nextHeaderOffset = nextHeaderOrigin.y - attribute.frame.size.height - footer.height
                attribute.frame.origin.y = min(max(offsetAdjustment, attribute.cachedOrigin.y), nextHeaderOffset)
                attribute.zIndex = attribute.frame.y ==  offsetAdjustment ? 1000 : 0
            }
        }
        if footer.pinToVisibleBounds {
            for attribute in footersAttributes {
                #if os(macOS)
                let previousFooterOrigin = footersAttributes[safe: attribute.indexPath!.section - 1]?.frame.origin ?? CGPoint(-CGFloat.greatestFiniteMagnitude)
                let offsetAdjustment = collectionView.contentOffset.y + collectionView.visibleRect.height - attribute.frame.height
                #else
                let previousFooterOrigin = footersAttributes[safe: attribute.indexPath.section - 1]?.frame.origin ?? CGPoint(-CGFloat.greatestFiniteMagnitude)
                let offsetAdjustment = collectionView.contentOffset.y + collectionView.bounds.height - attribute.frame.height
                #endif
                let previousFooterOffset = previousFooterOrigin.y + attribute.frame.size.height + header.height
                attribute.frame.origin.y = max(min(offsetAdjustment, attribute.cachedOrigin.y), previousFooterOffset)
                attribute.zIndex = 1000
            }
        }
    }
    
    override open var collectionViewContentSize: CGSize {
        guard let collectionView = collectionView, collectionView.numberOfSections > 0, let size = columnSizes.last?.first else {
            return .zero
        }
        return orientation == .horizontal ? CGSize(collectionView.bounds.width, size) : CGSize(size, collectionView.bounds.height)
    }

    override open func layoutAttributesForItem(at indexPath: IndexPath) -> NSUICollectionViewLayoutAttributes? {
        sectionItemAttributes[safe: indexPath.section]?[safe: indexPath.item]
    }
    
    override open func layoutAttributesForSupplementaryView(ofKind elementKind: String, at indexPath: IndexPath) -> NSUICollectionViewLayoutAttributes {
        if elementKind == NSUICollectionView.elementKindSectionHeader, let attribute = headersAttributes[safe: indexPath.section] {
            return attribute
        } else if elementKind == NSUICollectionView.elementKindSectionFooter, let attribute = footersAttributes[safe: indexPath.section] {
            return attribute
        }
        return NSUICollectionViewLayoutAttributes()
    }
    
    public override func invalidateLayout(with context: NSUICollectionViewLayoutInvalidationContext) {
        // Swift.print("invalidateLayoutWithContext")
        let context = context as! InvalidationContext
        if context.invalidateItemAttributes {
            let contentOffset = collectionView?.contentOffset ?? .zero
            let oldSize = collectionViewContentSize
            prepareItemAttributes(keepItemOrder: true)
            let newSize = collectionViewContentSize
            if orientation == .horizontal {
                context.contentOffsetAdjustment.y = (contentOffset.y * (newSize.height / oldSize.height)) - contentOffset.y
            } else {
                context.contentOffsetAdjustment.x = (contentOffset.x * (newSize.width / oldSize.width)) - contentOffset.x
            }
            didCalcuateItemAttributes = true
        } else if context.invalidateHeaderFooterAttributes {
            updateHeaderFooterAttributes()
            updateUnionRects()
            #if os(macOS)
            context.invalidateSupplementaryElements(ofKind: NSUICollectionView.elementKindSectionHeader, at: Set(headersAttributes.compactMap({$0.indexPath})))
            context.invalidateSupplementaryElements(ofKind: NSUICollectionView.elementKindSectionFooter, at: Set(footersAttributes.compactMap({$0.indexPath})))
            #else
            context.invalidateSupplementaryElements(ofKind: NSUICollectionView.elementKindSectionHeader, at: headersAttributes.compactMap({$0.indexPath}))
            context.invalidateSupplementaryElements(ofKind: NSUICollectionView.elementKindSectionFooter, at: footersAttributes.compactMap({$0.indexPath}))
            #endif
        }
        super.invalidateLayout(with: context)
    }
    
    open override func shouldInvalidateLayout(forBoundsChange newBounds: CGRect) -> Bool {
        guard orientation == .horizontal && previousBounds.width != newBounds.width || orientation == .vertical && previousBounds.height != newBounds.height || ((header.pinToVisibleBounds || footer.pinToVisibleBounds) && previousBounds.y != newBounds.y) else { return false }
        return true
    }
        
    open override func invalidationContext(forBoundsChange newBounds: CGRect) -> NSUICollectionViewLayoutInvalidationContext {
        // Swift.print("invalidationContext BoundsChange", newBounds, previousBounds)
        let context = super.invalidationContext(forBoundsChange: newBounds) as! InvalidationContext
        context.invalidateHeaderFooterAttributes = (header.pinToVisibleBounds || footer.pinToVisibleBounds) && previousBounds.y != newBounds.y
        context.invalidateItemAttributes = orientation == .horizontal && previousBounds.width != newBounds.width || orientation == .vertical && previousBounds.height != newBounds.height
        previousBounds = newBounds
        return context
    }
    
    public override class var invalidationContextClass: AnyClass {
        InvalidationContext.self
    }
    
    override open func layoutAttributesForElements(in rect: CGRect) -> [NSUICollectionViewLayoutAttributes] {
        var begin = 0, end = unionRects.count

        if let i = unionRects.firstIndex(where: { rect.intersects($0) }) {
            begin = i * unionSize
        }
        if let i = unionRects.lastIndex(where: { rect.intersects($0) }) {
            end = min((i + 1) * unionSize, allItemAttributes.count)
        }
        
        let attributes = allItemAttributes[begin ..< end]
            .filter { rect.intersects($0.frame) }

        return attributes
    }

    private func shortestColumnIndex(inSection section: Int) -> Int {
        columnSizes[section].enumerated().min(by: { $0.element < $1.element })?.offset ?? 0
    }

    private func longestColumnIndex(inSection section: Int) -> Int {
        columnSizes[section].enumerated().max(by: { $0.element < $1.element })?.offset ?? 0
    }

    private func nextColumnIndexForItem(_ indexPath: IndexPath, keepItemOrder: Bool) -> Int {
        if keepItemOrder, let mappedColumn = mappedItemColumns[indexPath] {
            return mappedColumn
        }
        var index = 0
        switch itemOrder {
        case .shortestColumn:
            index = shortestColumnIndex(inSection: indexPath.section)
        case .leftToRight:
            index = indexPath.item % columns
        case .rightToLeft:
            index = (columns - 1) - (indexPath.item % columns)
        }
        return index
    }
    
    /// Invalidates the layout animated.
    public func invalidateLayout(animated: Bool, keepScrollPosition: Bool) {
        guard let collectionView = collectionView else { return }
        let displayingIndexPaths = keepScrollPosition ? collectionView.displayingIndexPaths() : []
        invalidateLayout(animated: animated)
        guard !displayingIndexPaths.isEmpty else { return }
        collectionView.scrollToItems(at: Set(displayingIndexPaths), scrollPosition: .centeredVertically)
    }
    
    func invalidateLayout(animated: Bool) {
        guard let collectionView = collectionView else { return }
        let displayingIndexPaths = collectionView.displayingIndexPaths()
        
        collectionView.collectionViewLayout = animatedInvalidationLayout()
        #if os(macOS)
        collectionView.setCollectionViewLayout(self, animated: animated)
        #else
        collectionView.setCollectionViewLayout(copy, animated: animated, completion: { _ in collectionView.collectionViewLayout = self })
        #endif
    }
    
    func animatedInvalidationLayout() -> AnimatedInvalidationLayout {
        let layout = AnimatedInvalidationLayout()
        layout.columnSizes = columnSizes
        layout.sectionItemAttributes = sectionItemAttributes
        layout.headersAttributes = headersAttributes
        layout.footersAttributes = footersAttributes
        layout.orientation = orientation
        return layout
    }
    
    class AnimatedInvalidationLayout: NSUICollectionViewLayout {
        var columnSizes: [[CGFloat]] = []
        var orientation :NSUIUserInterfaceLayoutOrientation = .horizontal
        var sectionItemAttributes: [[NSUICollectionViewLayoutAttributes]] = []
        var headersAttributes: [ColumnCollectionViewLayout.HeaderFooterLayoutAttributes] = []
        var footersAttributes: [ColumnCollectionViewLayout.HeaderFooterLayoutAttributes] = []
        
        override open var collectionViewContentSize: CGSize {
            guard let collectionView = collectionView, collectionView.numberOfSections > 0, let size = columnSizes.last?.first else {
                return .zero
            }
            return orientation == .horizontal ? CGSize(collectionView.bounds.width, size) : CGSize(size, collectionView.bounds.height)
        }

        override open func layoutAttributesForItem(at indexPath: IndexPath) -> NSUICollectionViewLayoutAttributes? {
            sectionItemAttributes[safe: indexPath.section]?[safe: indexPath.item]
        }
        
        override open func layoutAttributesForSupplementaryView(ofKind elementKind: String, at indexPath: IndexPath) -> NSUICollectionViewLayoutAttributes {
            if elementKind == NSUICollectionView.elementKindSectionHeader, let attribute = headersAttributes[safe: indexPath.section] {
                return attribute
            } else if elementKind == NSUICollectionView.elementKindSectionFooter, let attribute = footersAttributes[safe: indexPath.section] {
                return attribute
            }
            return NSUICollectionViewLayoutAttributes()
        }
    }
    
    class HeaderFooterLayoutAttributes: NSUICollectionViewLayoutAttributes {
        var cachedOrigin: CGPoint = .zero
    }
    
    class InvalidationContext: NSUICollectionViewLayoutInvalidationContext {
        var invalidateHeaderFooterAttributes: Bool = false
        var invalidateItemAttributes: Bool = false
    }
    
    /**
     A interactive waterfall layout where the user can change the amount of columns by pinching the collection view.

     - Parameters:
        - columnsCount: The amount of columns.
        - spacing: The spacing between the columns and items.
        - insets: The layout insets.
        - orientation: The orientation of the layout.
        - itemSizeProvider: The handler that provides the item sizes..
     */
    public static func waterfall(columnsCount columns: Int, spacing: CGFloat = 10, insets: NSUIEdgeInsets = .init(10.0), orientation: NSUIUserInterfaceLayoutOrientation = .horizontal, itemSizeProvider: @escaping ItemSizeProvider) -> ColumnCollectionViewLayout {
        let layout = ColumnCollectionViewLayout()
        layout.columns = columns
        layout.orientation = orientation
        layout.itemSpacing = spacing
        layout.columnSpacing = spacing
        layout.itemLayout = .waterfall(itemSizeProvider)
        layout.sectionInset = insets
        return layout
    }
    
    /**
     Creates a grid collection view layout.
     
     - Parameters:
        - columnsCount: The amount of columns for the grid.
        - spacing: The spacing between the columns and items.
        - insets: The insets of the layout.
        - orientation: The orientation of the layout.
        - itemAspectRatio: The aspect ratio of the items.
     */
    public static func grid(columnsCount: Int, orientation: NSUIUserInterfaceLayoutOrientation = .horizontal, spacing: CGFloat = 10, insets: NSUIEdgeInsets = .init(10.0), itemAspectRatio: CGSize = CGSize(1,1)) -> ColumnCollectionViewLayout {
        let layout = ColumnCollectionViewLayout()
        layout.columns = columnsCount
        layout.orientation = orientation
        layout.itemSpacing = spacing
        layout.columnSpacing = spacing
        layout.itemLayout = .grid(itemAspectRatio)
        layout.sectionInset = insets
        return layout
    }
    
    /**
     Creates a collection view layout.
     
     - Parameters:
        - columns: The amount of columns for the grid.
        - orientation: The orientation of the layout.
        - spacing: The spacing between the columns and items.
        - insets: The insets of the layout.
     */
    public init(columns: Int = 3, orientation: NSUIUserInterfaceLayoutOrientation = .horizontal, spacing: CGFloat = 10, insets: NSUIEdgeInsets = .init(10.0)) {
        super.init()
        self.columns = columns
        self.orientation = orientation
        self.itemSpacing = spacing
        self.columnSpacing = spacing
        self.sectionInset = insets
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

protocol InteractiveCollectionViewLayout: NSUICollectionViewLayout {
    var columns: Int { get set }
    var columnRange: ClosedRange<Int> { get }
    var isPinchable: Bool { get }
    #if os(macOS)
    var keyDownColumnChangeAmount: Int { get }
    var keyDownColumnChangeAmountAlt: Int { get }
    var keyDownColumnChangeAmountShift: Int { get }
    #endif
    func invalidateLayout(animated: Bool)
}

extension InteractiveCollectionViewLayout {
    var needsGestureRecognizer: Bool {
        #if os(macOS)
        isPinchable || keyDownColumnChangeAmount != 0 || keyDownColumnChangeAmountAlt != 0 || keyDownColumnChangeAmountShift != 0
        #else
        isPinchable
        #endif
    }
}

#if os(macOS) || os(iOS)
extension NSUICollectionView {
    var columnInteractionGestureRecognizer: ColumnInteractionGestureRecognizer? {
        get { getAssociatedValue("columnInteractionGestureRecognizer") }
        set { setAssociatedValue(newValue, key: "columnInteractionGestureRecognizer") }
    }
    
    func setupColumnInteractionGestureRecognizer(_ needsRecognizer: Bool) {
        if needsRecognizer {
            if columnInteractionGestureRecognizer == nil {
                columnInteractionGestureRecognizer = .init()
                addGestureRecognizer(columnInteractionGestureRecognizer!)
            }
            #if os(macOS)
            columnInteractionGestureRecognizer!.setupKeyDownMonitor()
            #endif
        } else if !needsRecognizer {
            columnInteractionGestureRecognizer?.removeFromView()
            columnInteractionGestureRecognizer = nil
        }
    }
    
    class ColumnInteractionGestureRecognizer: NSUIMagnificationGestureRecognizer {
        
        var initalColumns: Int = 0
        var displayingIndexPaths: [IndexPath] = []
        
        #if os(macOS)
        var keyDownMonitor: NSEvent.Monitor?

        func setupKeyDownMonitor() {
            if let interactiveLayout = interactiveLayout, interactiveLayout.keyDownColumnChangeAmount != 0 || interactiveLayout.keyDownColumnChangeAmountShift != 0 || interactiveLayout.keyDownColumnChangeAmountAlt != 0 {
                guard keyDownMonitor == nil else { return }
                keyDownMonitor = NSEvent.localMonitor(for: .keyDown) { event in
                    guard event.keyCode == 44 || event.keyCode == 30, self.collectionView?.isFirstResponder == true else { return event }
                    self.updateColumns(with: event)
                    return nil
                }
            } else {
                keyDownMonitor = nil
            }
        }
        
        func updateColumns(with event: NSEvent) {
            guard event.keyCode == 44 || event.keyCode == 30, collectionView?.isFirstResponder == true, let interactiveLayout = interactiveLayout else { return }
            let addition = event.modifierFlags.contains(.shift) ? interactiveLayout.keyDownColumnChangeAmountShift : event.modifierFlags.contains(.command) ? interactiveLayout.keyDownColumnChangeAmountAlt : interactiveLayout.keyDownColumnChangeAmount
            displayingIndexPaths = collectionView?.displayingIndexPaths() ?? []
            if addition == -1 {
                columns = event.keyCode == 44 ? columnRange.upperBound : columnRange.lowerBound
            } else {
                columns += event.keyCode == 44 ? addition : -addition
            }
            scrollToDisplayingIndexPaths()
        }
        #endif
        
        var collectionView: NSUICollectionView? {
            view as? NSUICollectionView
        }
        
        var collectionViewLayout: NSUICollectionViewLayout? {
            collectionView?.collectionViewLayout
        }
        
        var interactiveLayout: InteractiveCollectionViewLayout? {
            collectionViewLayout as? InteractiveCollectionViewLayout
        }
        
        var columnRange: ClosedRange<Int> {
            interactiveLayout?.columnRange ?? 1...12
        }
        
        var isPinchable: Bool {
            interactiveLayout?.isPinchable ?? false
        }
                
        var columns: Int {
            get { interactiveLayout?.columns ?? 2 }
            set {
                let newValue = newValue.clamped(to: columnRange)
                guard newValue != columns, let interactiveLayout = interactiveLayout else { return }
                interactiveLayout.columns = newValue
                interactiveLayout.invalidateLayout(animated: true)
            }
        }
               
        weak var _layout: InteractiveCollectionViewLayout?
        override var state: NSUIGestureRecognizer.State {
            didSet {
                guard isPinchable else { return }
                switch state {
                case .began:
                    initalColumns = columns
                    displayingIndexPaths = collectionView?.displayingIndexPaths() ?? []
                case .changed:
                    #if os(macOS)
                    columns = initalColumns + Int((magnification/(-0.5)).rounded())
                    #else
                    columns = initalColumns + Int((scale/(-0.5)).rounded())
                    #endif
                    scrollToDisplayingIndexPaths()
                default: break
                }
            }
        }
        
        func scrollToDisplayingIndexPaths() {
            guard !displayingIndexPaths.isEmpty, let collectionView = collectionView else { return }
            #if os(macOS)
            collectionView.scrollToItems(at: Set(displayingIndexPaths), scrollPosition: .centeredVertically)
            #else
            collectionView.scrollToItems(at: Set(displayingIndexPaths), at: .centeredVertically)
            #endif
        }
    }
}
#endif
#endif
