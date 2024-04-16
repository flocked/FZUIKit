//
//  NSUICollectionViewLayout+Waterfall.swift
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
        #if os(macOS) || os(iOS)
        /**
         Creates a waterfall collection view layout with the specifed amount of columns.
         
         - Parameters:
            - columns: The amount of columns.
            - spacing: The spacing between the items.
            - insets: The layout insets.
            - itemSizeProvider: The handler that provides the item sizes..
         */
        static func waterfall(columns: Int = 2, spacing: CGFloat = 8.0, insets: NSUIEdgeInsets = .init(8.0), itemSizeProvider: @escaping (IndexPath) -> CGSize) -> CollectionViewWaterfallLayout {
            CollectionViewWaterfallLayout(columns: columns, isPinchable: false, spacing: spacing, insets: insets, itemSizeProvider: itemSizeProvider)
        }
        
        /**
         A interactive waterfall layout where the user can change the amount of columns by pinching the collection view.

         - Parameters:
            - columns: The amount of columns.
            - columnRange: The range of columns that the user can change to, if `isPinchable` or `isKeyDownControllable` is set to `true`.
            - isPinchable: A Boolean value that indicates whether the user can change the amount of columns by pinching the collection view.
            - isKeyDownControllable: A Boolean value that indicates whether the user can change the amount of columns by pressing the `plus` or `minus` key.
            - spacing: The spacing between the items.
            - insets: The layout insets.
            - itemSizeProvider: The handler that provides the item sizes..
         */
        static func waterfall(columns: Int = 2, columnRange: ClosedRange<Int> = 1...12, isPinchable: Bool = false, isKeyDownControllable: Bool = false, spacing: CGFloat = 8.0, insets: NSUIEdgeInsets = .init(8.0), itemSizeProvider: @escaping (IndexPath) -> CGSize) -> CollectionViewWaterfallLayout {
            CollectionViewWaterfallLayout(columns: columns, columnRange: columnRange, isPinchable: isPinchable, isKeyDownControllable: isKeyDownControllable, spacing: spacing, insets: insets, itemSizeProvider: itemSizeProvider)
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
        static func waterfall(columns: Int = 2, spacing: CGFloat = 8.0, insets: NSUIEdgeInsets = .init(8.0), itemSizeProvider: @escaping (IndexPath) -> CGSize) -> CollectionViewWaterfallLayout {
            let layout = CollectionViewWaterfallLayout(columns: columns, itemSizeProvider: itemSizeProvider)
            layout.minimumInteritemSpacing = spacing
            layout.minimumColumnSpacing = spacing
            layout.sectionInset = insets
            return layout
        }
        #endif
    }

public class SomeLayout: NSUICollectionViewLayout {
    init(value: Int) {
        super.init()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
}

public class CollectionViewWaterfallLayout: NSUICollectionViewLayout, PinchableCollectionViewLayout {
    /// Handler that provides the sizes for each item.
    public typealias ItemSizeProvider = (_ indexPath: IndexPath) -> CGSize

    public var keepItemOrder: Bool = true
    public var mappedItemColumns: [IndexPath: Int] = [:]
    
    #if os(macOS) || os(iOS)
    /**
     Creates a waterfall layout with the specified item size provider.
     
     - Parameters:
        - columns: The amount of columns.
        - columnRange: The range of columns that the user can change to, if `isPinchable` or `isKeyDownControllable` is set to `true`.
        - isPinchable: A Boolean value that indicates whether the user can change the amount of columns by pinching the collection view.
        - isKeyDownControllable: A Boolean value that indicates whether the user can change the amount of columns by pressing the `plus` or `minus` key.
        - itemSizeProvider: The handler that provides the sizes for each item.
     */
    public convenience init(columns: Int = 2, columnRange: ClosedRange<Int> = 1...12, isPinchable: Bool = false, isKeyDownControllable: Bool = false, spacing: CGFloat = 10, insets: NSUIEdgeInsets = .init(10.0), itemSizeProvider: @escaping ItemSizeProvider) {
        self.init()
        self.itemSizeProvider = itemSizeProvider
        self.columns = columns
        self.columnRange = columnRange
        self.isPinchable = isPinchable
        self.minimumInteritemSpacing = spacing
        self.minimumColumnSpacing = spacing
        self.sectionInset = insets
        self.keyDownColumnChangeAmount = isKeyDownControllable ? 1 : 0
        self.keyDownAltColumnChangeAmount = isKeyDownControllable ? -1 : 0
    }
    
    var itemAspectRatio: CGSize? = nil
    public convenience init(grid columns: Int, columnRange: ClosedRange<Int> = 1...12, isPinchable: Bool = false, isKeyDownControllable: Bool = false, spacing: CGFloat = 10, insets: NSUIEdgeInsets = .init(10.0), itemAspectRatio: CGSize = CGSize(1,1)) {
        self.init()
        self.columns = columns
        self.columnRange = columnRange
        self.isPinchable = isPinchable
        self.minimumInteritemSpacing = spacing
        self.minimumColumnSpacing = spacing
        self.sectionInset = insets
        self.itemAspectRatio = itemAspectRatio
        self.keyDownColumnChangeAmount = isKeyDownControllable ? 1 : 0
        self.keyDownAltColumnChangeAmount = isKeyDownControllable ? -1 : 0
    }
    #else
    public convenience init(columns: Int = 2, itemSizeProvider: @escaping ItemSizeProvider) {
        self.init()
        self.itemSizeProvider = itemSizeProvider
    }
    #endif
    
    func set<Value>(_ keyPath: ReferenceWritableKeyPath<CollectionViewWaterfallLayout, Value>, to value: Value) -> Self {
        self[keyPath: keyPath] = value
        return self
    }

    /// The handler that provides the sizes for each item.
    open var itemSizeProvider: ItemSizeProvider? {
        didSet { invalidateLayout() }
    }
    
    /// The amount of columns.
    open var columns: Int = 2 {
        didSet {
            columns = columns.clamped(to: columnRange)
            guard oldValue != columns else { return }
            invalidateLayout(animated: animationDuration ?? 0.0) }
    }
    
    /// Sets the amount of columns.
    @discardableResult
    public func columns(_ columns: Int) -> Self {
        set(\.columns, to: columns)
    }
    
    #if os(macOS) || os(iOS)
    /**
     A Boolean value that indicates whether the user can change the amount of columns by pinching the collection view.
     
     If the value is set to `true`, ``columnRange`` determinates the range of columns  that the user can change to.
     */
    open var isPinchable: Bool = false {
        didSet {
            collectionView?.setupPinchGestureRecognizer(needsPinchGestureRecognizer)
        }
    }
    
    /**
     Sets the Boolean value that indicates whether the user can change the amount of columns by pinching the collection view.
     
     If the value is set to `true`, ``columnRange`` determinates the range of columns  that the user can change to.
     */
    @discardableResult
    public func isPinchable(_ isPinchable: Bool) -> Self {
        set(\.isPinchable, to: isPinchable)
    }
    
    /// The amount of columns added or removed when the user presses the `plus` / `minus` key.
    open var keyDownColumnChangeAmount: Int = 0 {
        didSet {
            keyDownColumnChangeAmount.clamp(min: 0)
            collectionView?.setupPinchGestureRecognizer(needsPinchGestureRecognizer)
        }
    }
    
    /// Sets the amount of columns added or removed when the user presses the `plus` / `minus` key.
    @discardableResult
    public func keyDownColumnChangeAmount(_ amount: Int) -> Self {
        set(\.keyDownColumnChangeAmount, to: amount)
    }
    
    /**
     The amount of columns added or removed when the user presses the `plus` / `minus` key while holding `command`.
     
     A value of `-1`indicates the full column range.
     */
    open var keyDownAltColumnChangeAmount: Int = 0 {
        didSet {
            keyDownAltColumnChangeAmount.clamp(min: -1)
            collectionView?.setupPinchGestureRecognizer(needsPinchGestureRecognizer)
        }
    }
    
    /// Sets the amount of columns added or removed when the user presses the `plus` / `minus` key while holding `command`.
    @discardableResult
    public func keyDownAltColumnChangeAmount(_ amount: Int) -> Self {
        set(\.keyDownAltColumnChangeAmount, to: amount)
    }
    
    /**
     The amount of columns added or removed when the user presses the `plus` / `minus` key while holding `shift`.
     
     A value of `-1`indicates the full column range.
     */
    var keyDownAlt2ColumnChangeAmount: Int = 0 {
        didSet {
            keyDownAltColumnChangeAmount.clamp(min: -1)
            collectionView?.setupPinchGestureRecognizer(needsPinchGestureRecognizer)
        }
    }
    
    /// The range of columns that the user can change to, if ``isPinchable`` or ``isKeyDownControllable`` is set to `true`.
    open var columnRange: ClosedRange<Int> = 1...12 {
        didSet {
            columnRange = columnRange.clamped(min: 1)
            columns = columns.clamped(to: columnRange)
        }
    }
    
    /// Sets the range of columns that the user can change to, if ``isPinchable`` or ``isKeyDownControllable`` is set to `true`.
    @discardableResult
    public func columnRange(_ range: ClosedRange<Int>) -> Self {
        set(\.columnRange, to: range)
    }
    
    var needsPinchGestureRecognizer: Bool {
        isPinchable || keyDownColumnChangeAmount > 0 || keyDownAltColumnChangeAmount > 0
    }
    
    #else
    var isPinchable = false
    var keyDownColumnChangeAmount = 0
    var keyDownAltColumnChangeAmount = 0
    var keyDownAlt2ColumnChangeAmount = 0
    var columnRange = 1...12
    #endif
    
    /// The animation duration when changing the amount of columns, or `nil` for no animation.
    open var animationDuration: TimeInterval? = 0.2 {
        didSet { animationDuration?.clamp(min: 0.0) }
    }
    
    /// Sets the animation duration when changing the amount of columns, or `nil` for no animation.
    @discardableResult
    public func animationDuration(_ duration:  TimeInterval?) -> Self {
        set(\.animationDuration, to: duration)
    }

    /// The minimum spacing between the columns.
    open var minimumColumnSpacing: CGFloat = 10 {
        didSet {
            minimumColumnSpacing.clamp(min: 0)
            guard oldValue != minimumColumnSpacing else { return }
            minimumColumnSpacing = minimumColumnSpacing.clamped(min: 0)
            invalidateLayout()
        }
    }
    
    /// Sets the minimum spacing between the columns.
    @discardableResult
    public func minimumColumnSpacing(_ spacing:  CGFloat) -> Self {
        set(\.minimumColumnSpacing, to: spacing)
    }

    /// The minimum amount of space between the items
    open var minimumInteritemSpacing: CGFloat = 10 {
        didSet {
            minimumInteritemSpacing.clamp(min: 0)
            guard oldValue != minimumInteritemSpacing else { return }
            minimumInteritemSpacing = minimumInteritemSpacing.clamped(min: 0)
            invalidateLayout()
        }
    }
    
    /// Sets the minimum amount of space between the items
    @discardableResult
    public func minimumInteritemSpacing(_ spacing:  CGFloat) -> Self {
        set(\.minimumInteritemSpacing, to: spacing)
    }

    /// The height of the header.
    open var headerHeight: CGFloat = 0 {
        didSet {
            headerHeight.clamp(min: 0)
            guard oldValue != headerHeight else { return }
            headerHeight = headerHeight.clamped(min: 0)
            invalidateLayout()
        }
    }
    
    /// Sets the height of the header.
    @discardableResult
    public func headerHeight(_ height:  CGFloat) -> Self {
        set(\.headerHeight, to: height)
    }

    /// The height of the footer.
    open var footerHeight: CGFloat = 0 {
        didSet {
            footerHeight.clamp(min: 0)
            guard oldValue != footerHeight else { return }
            footerHeight = footerHeight.clamped(min: 0)
            invalidateLayout()
        }
    }
    
    /// Sets the height of the footer.
    @discardableResult
    public func footerHeight(_ height:  CGFloat) -> Self {
        set(\.footerHeight, to: height)
    }

    /// The order each item is displayed.
    open var itemRenderDirection: ItemSortOrder = .shortestColumn {
        didSet {
            guard oldValue != itemRenderDirection else { return }
            invalidateLayout()
        }
    }
    
    /// Sets the order each item is displayed.
    @discardableResult
    public func itemRenderDirection(_ direction:  ItemSortOrder) -> Self {
        set(\.itemRenderDirection, to: direction)
    }
    
    /// The order each item is displayed.
    public enum ItemSortOrder: Int {
        /// Each item is added to the shortest column.
        case shortestColumn
        /// The items are added to the columns from left to right.
        case leftToRight
        /// The items are added to the columns from right to left.
        case rightToLeft
    }
    
    /// The margins used to lay out content in a section.
    open var sectionInset: NSUIEdgeInsets = .init(10) {
        didSet {
            guard oldValue != sectionInset else { return }
            invalidateLayout()
        }
    }
    
    /// Sets the margins used to lay out content in a section.
    @discardableResult
    public func sectionInset(_ inset:  NSUIEdgeInsets) -> Self {
        set(\.sectionInset, to: inset)
    }
    
    /// A Boolean value that indicates whether to apply the ``sectionInset`` to the  safe area of the collection view.
    @available(macOS 11, iOS 13, *)
    public var sectionInsetUsesSafeArea: Bool {
        get { _sectionInsetUsesSafeArea }
        set { _sectionInsetUsesSafeArea = newValue }
    }
    
    /// Sets the Boolean value that indicates whether to apply the ``sectionInset`` to the  safe area of the collection view.
    @available(macOS 11, iOS 13, *)
    @discardableResult
    public func sectionInsetUsesSafeArea(_ useSafeArea: Bool) -> Self {
        set(\.sectionInsetUsesSafeArea, to: useSafeArea)
    }
    
    open var _sectionInsetUsesSafeArea: Bool = false

    private var columnHeights: [[CGFloat]] = []
    private var sectionItemAttributes: [[NSUICollectionViewLayoutAttributes]] = []
    private var allItemAttributes: [NSUICollectionViewLayoutAttributes] = []
    private var headersAttributes: [Int: NSUICollectionViewLayoutAttributes] = [:]
    private var footersAttributes: [Int: NSUICollectionViewLayoutAttributes] = [:]
    private var unionRects: [CGRect] = []
    private let unionSize = 20

    private func columns(forSection _: Int) -> Int {
        var cCount = columns
        if cCount == -1 {
            cCount = columns
        }
        return cCount
    }

    #if os(macOS)
        private var collectionViewContentWidth: CGFloat {
            guard let collectionView = collectionView else { return 0 }
            let insetsWidth: CGFloat
            if #available(macOS 11.0, *) {
                insetsWidth = (sectionInsetUsesSafeArea ? collectionView.safeAreaInsets : collectionView.enclosingScrollView?.contentInsets)?.width ?? 0
            } else {
                insetsWidth = collectionView.enclosingScrollView?.contentInsets.width ?? 0
            }
            return collectionView.bounds.size.width - insetsWidth
        }

    #elseif canImport(UIKit)
        private var collectionViewContentWidth: CGFloat {
            guard let collectionView = collectionView else { return 0 }
            let insetsWidth = sectionInsetUsesSafeArea ? collectionView.adjustedContentInset.width : collectionView.contentInset.width
            return collectionView.bounds.size.width - insetsWidth
        }
    #endif

    private func collectionViewContentWidth(ofSection section: Int) -> CGFloat {
        return collectionViewContentWidth - sectionInset.width
    }
    
    public func itemWidth(inSection section: Int) -> CGFloat {
        let columns = columns(forSection: section)
        let spaceColumCount = CGFloat(columns - 1)
        let width = collectionViewContentWidth(ofSection: section)
        return ((width - (spaceColumCount * minimumColumnSpacing)) / CGFloat(columns))
    }
    
    enum AutoColumnCount {
        case off
        case resizing
        case enabled
    }
    
    override public func prepare() {
        // Swift.print("prepare")
        super.prepare()
        #if os(macOS) || os(iOS)
        collectionView?.setupPinchGestureRecognizer(needsPinchGestureRecognizer)
        #endif
        prepareItemAttributes()
    }
    
    func prepareItemAttributes() {
        guard let collectionView = collectionView, collectionView.numberOfSections > 0  else { return }
        let numberOfSections = collectionView.numberOfSections

        headersAttributes = [:]
        footersAttributes = [:]
        unionRects = []
        allItemAttributes = []
        sectionItemAttributes = []
        columnHeights = (0 ..< numberOfSections).map { section in
            let columns = self.columns(forSection: section)
            let sectionColumnHeights = (0 ..< columns).map { CGFloat($0) }
            return sectionColumnHeights
        }

        var top: CGFloat = 0.0
        var attributes = NSUICollectionViewLayoutAttributes()

        for section in 0 ..< numberOfSections {
            // MARK: 1. Get section-specific metrics (minimumInteritemSpacing, sectionInset)

            let columns = columnHeights[section].count
            let itemWidth = itemWidth(inSection: section)

            // MARK: 2. Section header

            if headerHeight > 0 {
                attributes = NSUICollectionViewLayoutAttributes(forSupplementaryViewOfKind: NSUICollectionView.elementKindSectionHeader, with: IndexPath(item: 0, section: section))
                attributes.frame = CGRect(x: 0, y: top, width: collectionView.bounds.size.width, height: headerHeight)
                headersAttributes[section] = attributes
                allItemAttributes.append(attributes)
                top = attributes.frame.maxY
            }
            top += sectionInset.top
            columnHeights[section] = [CGFloat](repeating: top, count: columns)

            // MARK: 3. Section items

            let itemCount = collectionView.numberOfItems(inSection: section)
            var itemAttributes: [NSUICollectionViewLayoutAttributes] = []

            // Item will be put into shortest column.
            for idx in 0 ..< itemCount {
                let indexPath = IndexPath(item: idx, section: section)

                let columnIndex = nextColumnIndexForItem(indexPath)
                let xOffset = sectionInset.left + (itemWidth + minimumColumnSpacing) * CGFloat(columnIndex)
                mappedItemColumns[indexPath] = columnIndex

                let yOffset = columnHeights[section][columnIndex]
                var itemHeight: CGFloat = 0.0
                if let itemSize = itemSizeProvider?(indexPath),
                   itemSize.height > 0
                {
                    itemHeight = itemSize.height
                    if itemSize.width > 0 {
                        itemHeight = (itemHeight * itemWidth / itemSize.width)
                    } // else use default item width based on other parameters
                }
                if let itemAspectRatio = itemAspectRatio {
                    itemHeight = (itemAspectRatio.height / itemAspectRatio.width) * itemWidth
                }
                #if os(macOS)
                    attributes = NSUICollectionViewLayoutAttributes(forItemWith: indexPath)
                #elseif canImport(UIKit)
                    attributes = NSUICollectionViewLayoutAttributes(forCellWith: indexPath)
                #endif
                attributes.frame = CGRect(x: xOffset, y: yOffset, width: itemWidth, height: itemHeight)
                itemAttributes.append(attributes)
                allItemAttributes.append(attributes)
                columnHeights[section][columnIndex] = attributes.frame.maxY + minimumInteritemSpacing
            }
            sectionItemAttributes.append(itemAttributes)

            // MARK: 4. Section footer

            let columnIndex = longestColumnIndex(inSection: section)
            top = columnHeights[section][columnIndex] - minimumInteritemSpacing + sectionInset.bottom

            if footerHeight > 0 {
                attributes = NSUICollectionViewLayoutAttributes(forSupplementaryViewOfKind: NSUICollectionView.elementKindSectionFooter, with: IndexPath(item: 0, section: section))
                attributes.frame = CGRect(x: 0, y: top, width: collectionView.bounds.size.width, height: footerHeight)
                footersAttributes[section] = attributes
                allItemAttributes.append(attributes)
                top = attributes.frame.maxY
            }

            columnHeights[section] = [CGFloat](repeating: top, count: columns)
        }

        var idx = 0
        let itemCounts = allItemAttributes.count
        while idx < itemCounts {
            let rect1 = allItemAttributes[idx].frame
            idx = min(idx + unionSize, itemCounts) - 1
            let rect2 = allItemAttributes[idx].frame
            unionRects.append(rect1.union(rect2))
            idx += 1
        }
    }

    override public var collectionViewContentSize: CGSize {
        if collectionView!.numberOfSections == 0 {
            return .zero
        }

        var contentSize = collectionView!.bounds.size
        contentSize.width = collectionViewContentWidth

        if let height = columnHeights.last?.first {
            contentSize.height = height
            return contentSize
        }
        return .zero
    }

    override public func layoutAttributesForItem(at indexPath: IndexPath) -> NSUICollectionViewLayoutAttributes? {
        if indexPath.section >= sectionItemAttributes.count {
            return nil
        }
        let list = sectionItemAttributes[indexPath.section]
        if indexPath.item >= list.count {
            return nil
        }
        return list[indexPath.item]
    }
    
    var previousBounds: CGRect = .zero
    var isScrolling = false
    public override func shouldInvalidateLayout(forBoundsChange newBounds: NSRect) -> Bool {
        guard keepItemsCenteredWhenResizing else { return false }
        Swift.print("shouldInvalidate", newBounds.width != previousBounds.width, newBounds, previousBounds, collectionView?.displayingIndexPaths().compactMap({$0.item}).sorted() ?? [])
        guard let collectionView = collectionView else { return false }
        guard newBounds.width != previousBounds.width, !isScrolling else { return false }
        previousBounds = newBounds
        delayedVisibleItemsReset?.cancel()
        let task = DispatchWorkItem {
            self.displayingItems = nil
        }
        delayedVisibleItemsReset = task
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.6, execute: task)
        if displayingItems == nil {
            self.displayingItems = Set(collectionView.displayingIndexPaths())
        }
      //  if !isScrolling {
            isScrolling = true
            keepItemOrder = true
            invalidateLayout()
            collectionView.scrollToItems(at: displayingItems!, scrollPosition: .centeredVertically)
            keepItemOrder = false
            isScrolling = false
       // }
        
        return false
    }

    override public func layoutAttributesForSupplementaryView(ofKind elementKind: String, at indexPath: IndexPath) -> NSUICollectionViewLayoutAttributes {
        var attribute: NSUICollectionViewLayoutAttributes?
        if elementKind == NSUICollectionView.elementKindSectionHeader {
            attribute = headersAttributes[indexPath.section]
        } else if elementKind == NSUICollectionView.elementKindSectionFooter {
            attribute = footersAttributes[indexPath.section]
        }
        return attribute ?? NSUICollectionViewLayoutAttributes()
    }

    override public func layoutAttributesForElements(in rect: CGRect) -> [NSUICollectionViewLayoutAttributes] {
        var begin = 0, end = unionRects.count

        if let i = unionRects.firstIndex(where: { rect.intersects($0) }) {
            begin = i * unionSize
        }
        if let i = unionRects.lastIndex(where: { rect.intersects($0) }) {
            end = min((i + 1) * unionSize, allItemAttributes.count)
        }

        return allItemAttributes[begin ..< end]
            .filter { rect.intersects($0.frame) }
    }

    var displayingItems: Set<IndexPath>?
    var delayedVisibleItemsReset: DispatchWorkItem?
    public var keepItemsCenteredWhenResizing: Bool = true
        
    /*
    override public func shouldInvalidateLayout(forBoundsChange newBounds: CGRect) -> Bool {
        if let collectionView = collectionView {
            Swift.print("shouldInvalidateLayout")
            Swift.print("\t", newBounds, "newBounds")
            Swift.print("\t", collectionView.visibleRect, "visibleRect")
            Swift.print("\t", collectionView.contentOffset, "contentOffset")
            Swift.print("\t", collectionView.documentSize, "documentSize")
            Swift.print("\t", collectionView.visibleDocumentSize, "visibleDocumentSize")
            Swift.print("\t", collectionViewBounds, "collectionViewBounds")
        }
        if newBounds.width == collectionViewBounds.width {
            collectionViewBounds = collectionView?.visibleRect ?? .zero
            return false
        }
        if displayingItems == nil, let collectionView = collectionView {
            displayingItems = Set(collectionView.displayingIndexPaths(in: collectionViewBounds))
        }
        delayedVisibleItemsReset?.cancel()
        let task = DispatchWorkItem {
            self.displayingItems = nil
        }
        delayedVisibleItemsReset = task
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.6, execute: task)
        return true
        
        
        guard newBounds.width != (collectionView?.bounds.width ?? 0) else { return false }
        if displayingItems == nil, let collectionView = collectionView {
            displayingItems = Set(collectionView.displayingIndexPaths(in: CGRect(collectionViewContentOffset, collectionViewBoundsSize)))
        }
        
        guard keepItemsCenteredWhenResizing else { return false }
        if newBounds.size == collectionViewBoundsSize {
            collectionViewContentOffset = newBounds.origin
        }
        
        if let collectionView = collectionView {
            let displaying = collectionView.displayingIndexPaths(in: CGRect(collectionViewContentOffset, collectionViewBoundsSize)).compactMap({$0.item}).sorted()
            Swift.print("shouldInvalidateLayout", newBounds.origin, newBounds.size != collectionViewBoundsSize, collectionView.visibleRect == CGRect(collectionViewContentOffset, collectionViewBoundsSize), CGRect(collectionViewContentOffset, collectionViewBoundsSize), collectionView.contentOffset, collectionView.visibleRect,  displaying)
        }
        guard newBounds.size != collectionViewBoundsSize else {
            return false }
        
       
        if displayingItems == nil, let collectionView = collectionView {
            displayingItems = Set(collectionView.displayingIndexPaths(in: CGRect(collectionViewContentOffset, collectionViewBoundsSize)))
        }
        return true
    }
    */

    private func shortestColumnIndex(inSection section: Int) -> Int {
        columnHeights[section].enumerated()
            .min(by: { $0.element < $1.element })?
            .offset ?? 0
    }

    private func longestColumnIndex(inSection section: Int) -> Int {
        columnHeights[section].enumerated()
            .max(by: { $0.element < $1.element })?
            .offset ?? 0
    }

    private func nextColumnIndexForItem(_ indexPath: IndexPath) -> Int {
        if keepItemOrder, let mappedColumn = mappedItemColumns[indexPath] {
            return mappedColumn
        }
        var index = 0
        let columns = columns(forSection: indexPath.section)
        switch itemRenderDirection {
        case .shortestColumn:
            index = shortestColumnIndex(inSection: indexPath.section)
        case .leftToRight:
            index = indexPath.item % columns
        case .rightToLeft:
            index = (columns - 1) - (indexPath.item % columns)
        }
        return index
    }
}

/*
/// A layout that organizes items into a flexible and configurable arrangement.
public class CollectionViewWaterfallLayout: NSUICollectionViewLayout, PinchableCollectionViewLayout {
    /// Handler that provides the sizes for each item.
    public typealias ItemSizeProvider = (_ indexPath: IndexPath) -> CGSize

    public var keepItemsCenteredWhenResizing: Bool = true
    public var keepItemOrder: Bool = false
    public var layoutItemAttributes: [NSUICollectionViewLayoutAttributes] = []
    public var debug: Bool = true
    private var _sectionInsetUsesSafeArea: Bool = false
    private var columnHeights: [[CGFloat]] = []
    private var sectionItemAttributes: [[NSUICollectionViewLayoutAttributes]] = []
    private var allItemAttributes: [NSUICollectionViewLayoutAttributes] = []
    private var headersAttributes: [Int: NSUICollectionViewLayoutAttributes] = [:]
    private var footersAttributes: [Int: NSUICollectionViewLayoutAttributes] = [:]
    private var unionRects: [CGRect] = []
    private let unionSize = 20
    private var bounds: CGRect = .zero
    private var displayingItems: Set<IndexPath>?
    private var delayedVisibleItemsReset: DispatchWorkItem?
    private var isScrolling = false
    private var mappedItemColumns: [IndexPath: Int] = [:]
    
    #if os(macOS) || os(iOS)
    /**
     Creates a waterfall layout with the specified item size provider.
     
     - Parameters:
        - columns: The amount of columns.
        - columnRange: The range of columns that the user can change to, if `isPinchable` or `isKeyDownControllable` is set to `true`.
        - isPinchable: A Boolean value that indicates whether the user can change the amount of columns by pinching the collection view.
        - isKeyDownControllable: A Boolean value that indicates whether the user can change the amount of columns by pressing the `plus` or `minus` key.
        - itemSizeProvider: The handler that provides the sizes for each item.
     */
    public convenience init(columns: Int = 2, columnRange: ClosedRange<Int> = 1...12, isPinchable: Bool = false, isKeyDownControllable: Bool = false, spacing: CGFloat = 10, insets: NSUIEdgeInsets = .init(10.0), itemSizeProvider: @escaping ItemSizeProvider) {
        self.init()
        self.itemSizeProvider = itemSizeProvider
        self.columns = columns
        self.columnRange = columnRange
        self.isPinchable = isPinchable
        self.minimumInteritemSpacing = spacing
        self.minimumColumnSpacing = spacing
        self.sectionInset = insets
        self.keyDownColumnChangeAmount = isKeyDownControllable ? 1 : 0
        self.keyDownAltColumnChangeAmount = isKeyDownControllable ? -1 : 0
    }
    #else
    public convenience init(columns: Int = 2, itemSizeProvider: @escaping ItemSizeProvider) {
        self.init()
        self.itemSizeProvider = itemSizeProvider
    }
    #endif
    
    
    func print(_ items: Any...) {
        guard debug else { return }
        Swift.print(items)
    }
    
    func set<Value>(_ keyPath: ReferenceWritableKeyPath<CollectionViewWaterfallLayout, Value>, to value: Value) -> Self {
        self[keyPath: keyPath] = value
        return self
    }

    /// The handler that provides the sizes for each item.
    open var itemSizeProvider: ItemSizeProvider? {
        didSet { invalidateLayout() }
    }
    
    /// The amount of columns.
    open var columns: Int = 2 {
        didSet {
            columns = columns.clamped(to: columnRange)
            guard oldValue != columns else { return }
            invalidateLayout(animated: animationDuration ?? 0.0) }
    }
    
    /// Sets the amount of columns.
    @discardableResult
    public func columns(_ columns: Int) -> Self {
        set(\.columns, to: columns)
    }
    
    #if os(macOS) || os(iOS)
    /**
     A Boolean value that indicates whether the user can change the amount of columns by pinching the collection view.
     
     If the value is set to `true`, ``columnRange`` determinates the range of columns  that the user can change to.
     */
    open var isPinchable: Bool = false {
        didSet {
            collectionView?.setupPinchGestureRecognizer(needsPinchGestureRecognizer)
        }
    }
    
    /**
     Sets the Boolean value that indicates whether the user can change the amount of columns by pinching the collection view.
     
     If the value is set to `true`, ``columnRange`` determinates the range of columns  that the user can change to.
     */
    @discardableResult
    public func isPinchable(_ isPinchable: Bool) -> Self {
        set(\.isPinchable, to: isPinchable)
    }
    
    /// The amount of columns added or removed when the user presses the `plus` / `minus` key.
    open var keyDownColumnChangeAmount: Int = 0 {
        didSet {
            keyDownColumnChangeAmount.clamp(min: 0)
            collectionView?.setupPinchGestureRecognizer(needsPinchGestureRecognizer)
        }
    }
    
    /// Sets the amount of columns added or removed when the user presses the `plus` / `minus` key.
    @discardableResult
    public func keyDownColumnChangeAmount(_ amount: Int) -> Self {
        set(\.keyDownColumnChangeAmount, to: amount)
    }
    
    /**
     The amount of columns added or removed when the user presses the `plus` / `minus` key while holding `command`.
     
     A value of `-1`indicates the full column range.
     */
    open var keyDownAltColumnChangeAmount: Int = 0 {
        didSet {
            keyDownAltColumnChangeAmount.clamp(min: -1)
            collectionView?.setupPinchGestureRecognizer(needsPinchGestureRecognizer)
        }
    }
    
    /// Sets the amount of columns added or removed when the user presses the `plus` / `minus` key while holding `command`.
    @discardableResult
    public func keyDownAltColumnChangeAmount(_ amount: Int) -> Self {
        set(\.keyDownAltColumnChangeAmount, to: amount)
    }
    
    /**
     The amount of columns added or removed when the user presses the `plus` / `minus` key while holding `shift`.
     
     A value of `-1`indicates the full column range.
     */
    var keyDownAlt2ColumnChangeAmount: Int = 0 {
        didSet {
            keyDownAltColumnChangeAmount.clamp(min: -1)
            collectionView?.setupPinchGestureRecognizer(needsPinchGestureRecognizer)
        }
    }
    
    /// The range of columns that the user can change to, if ``isPinchable`` or ``isKeyDownControllable`` is set to `true`.
    open var columnRange: ClosedRange<Int> = 1...12 {
        didSet {
            columnRange = columnRange.clamped(min: 1)
            columns = columns.clamped(to: columnRange)
        }
    }
    
    /// Sets the range of columns that the user can change to, if ``isPinchable`` or ``isKeyDownControllable`` is set to `true`.
    @discardableResult
    public func columnRange(_ range: ClosedRange<Int>) -> Self {
        set(\.columnRange, to: range)
    }
    
    var needsPinchGestureRecognizer: Bool {
        isPinchable || keyDownColumnChangeAmount > 0 || keyDownAltColumnChangeAmount > 0
    }
    
    #else
    var isPinchable = false
    var keyDownColumnChangeAmount = 0
    var keyDownAltColumnChangeAmount = 0
    var keyDownAlt2ColumnChangeAmount = 0
    var columnRange = 1...12
    #endif
    
    /// The animation duration when changing the amount of columns, or `nil` for no animation.
    open var animationDuration: TimeInterval? = 0.2 {
        didSet { animationDuration?.clamp(min: 0.0) }
    }
    
    /// Sets the animation duration when changing the amount of columns, or `nil` for no animation.
    @discardableResult
    public func animationDuration(_ duration:  TimeInterval?) -> Self {
        set(\.animationDuration, to: duration)
    }

    /// The minimum spacing between the columns.
    open var minimumColumnSpacing: CGFloat = 10 {
        didSet {
            minimumColumnSpacing.clamp(min: 0)
            guard oldValue != minimumColumnSpacing else { return }
            minimumColumnSpacing = minimumColumnSpacing.clamped(min: 0)
            invalidateLayout()
        }
    }
    
    /// Sets the minimum spacing between the columns.
    @discardableResult
    public func minimumColumnSpacing(_ spacing:  CGFloat) -> Self {
        set(\.minimumColumnSpacing, to: spacing)
    }

    /// The minimum amount of space between the items
    open var minimumInteritemSpacing: CGFloat = 10 {
        didSet {
            minimumInteritemSpacing.clamp(min: 0)
            guard oldValue != minimumInteritemSpacing else { return }
            minimumInteritemSpacing = minimumInteritemSpacing.clamped(min: 0)
            invalidateLayout()
        }
    }
    
    /// Sets the minimum amount of space between the items
    @discardableResult
    public func minimumInteritemSpacing(_ spacing:  CGFloat) -> Self {
        set(\.minimumInteritemSpacing, to: spacing)
    }

    /// The height of the header.
    open var headerHeight: CGFloat = 0 {
        didSet {
            headerHeight.clamp(min: 0)
            guard oldValue != headerHeight else { return }
            headerHeight = headerHeight.clamped(min: 0)
            invalidateLayout()
        }
    }
    
    /// Sets the height of the header.
    @discardableResult
    public func headerHeight(_ height:  CGFloat) -> Self {
        set(\.headerHeight, to: height)
    }

    /// The height of the footer.
    open var footerHeight: CGFloat = 0 {
        didSet {
            footerHeight.clamp(min: 0)
            guard oldValue != footerHeight else { return }
            footerHeight = footerHeight.clamped(min: 0)
            invalidateLayout()
        }
    }
    
    /// Sets the height of the footer.
    @discardableResult
    public func footerHeight(_ height:  CGFloat) -> Self {
        set(\.footerHeight, to: height)
    }

    /// The order each item is displayed.
    open var itemRenderDirection: ItemSortOrder = .shortestColumn {
        didSet {
            guard oldValue != itemRenderDirection else { return }
            invalidateLayout()
        }
    }
    
    /// Sets the order each item is displayed.
    @discardableResult
    public func itemRenderDirection(_ direction:  ItemSortOrder) -> Self {
        set(\.itemRenderDirection, to: direction)
    }
    
    /// The order each item is displayed.
    public enum ItemSortOrder: Int {
        /// Each item is added to the shortest column.
        case shortestColumn
        /// The items are added to the columns from left to right.
        case leftToRight
        /// The items are added to the columns from right to left.
        case rightToLeft
    }
    
    /// The margins used to lay out content in a section.
    open var sectionInset: NSUIEdgeInsets = .init(10) {
        didSet {
            guard oldValue != sectionInset else { return }
            invalidateLayout()
        }
    }
    
    /// Sets the margins used to lay out content in a section.
    @discardableResult
    public func sectionInset(_ inset:  NSUIEdgeInsets) -> Self {
        set(\.sectionInset, to: inset)
    }
    
    /// A Boolean value that indicates whether to apply the ``sectionInset`` to the  safe area of the collection view.
    @available(macOS 11, iOS 13, *)
    public var sectionInsetUsesSafeArea: Bool {
        get { _sectionInsetUsesSafeArea }
        set { _sectionInsetUsesSafeArea = newValue }
    }
    
    /// Sets the Boolean value that indicates whether to apply the ``sectionInset`` to the  safe area of the collection view.
    @available(macOS 11, iOS 13, *)
    @discardableResult
    public func sectionInsetUsesSafeArea(_ useSafeArea: Bool) -> Self {
        set(\.sectionInsetUsesSafeArea, to: useSafeArea)
    }

    private func columns(forSection _: Int) -> Int {
        var cCount = columns
        if cCount == -1 {
            cCount = columns
        }
        return cCount
    }

    #if os(macOS)
        private var collectionViewContentWidth: CGFloat {
            guard let collectionView = collectionView else { return 0 }
            let insetsWidth: CGFloat
            if #available(macOS 11.0, *) {
                insetsWidth = (sectionInsetUsesSafeArea ? collectionView.safeAreaInsets : collectionView.enclosingScrollView?.contentInsets)?.width ?? 0
            } else {
                insetsWidth = collectionView.enclosingScrollView?.contentInsets.width ?? 0
            }
            return collectionView.bounds.size.width - insetsWidth
        }

    #elseif canImport(UIKit)
        private var collectionViewContentWidth: CGFloat {
            guard let collectionView = collectionView else { return 0 }
            let insetsWidth = sectionInsetUsesSafeArea ? collectionView.adjustedContentInset.width : collectionView.contentInset.width
            return collectionView.bounds.size.width - insetsWidth
        }
    #endif

    private func collectionViewContentWidth(ofSection section: Int) -> CGFloat {
        return collectionViewContentWidth - sectionInset.width
    }
    
    public func itemWidth(inSection section: Int) -> CGFloat {
        let columns = columns(forSection: section)
        let spaceColumCount = CGFloat(columns - 1)
        let width = collectionViewContentWidth(ofSection: section)
        return floor((width - (spaceColumCount * minimumColumnSpacing)) / CGFloat(columns))
    }

    override public func prepare() {
        guard let collectionView = collectionView else { return }
        let widthChanged = bounds.width != collectionView.bounds.width
        print("prepare", widthChanged, keepItemOrder, collectionView.bounds, bounds)
        super.prepare()
        #if os(macOS) || os(iOS)
        collectionView.setupPinchGestureRecognizer(needsPinchGestureRecognizer)
        #endif
        bounds.size.width = collectionView.bounds.width
        prepareItemAttributes(keepOrder: keepItemOrder)
        if widthChanged {
            // scrollToDisplayingItems()
        }
        keepItemOrder = false
    }
    
    func prepareItemAttributes(keepOrder: Bool = false) {
        guard let collectionView = collectionView, collectionView.numberOfSections > 0  else { return }
        let numberOfSections = collectionView.numberOfSections
        
        headersAttributes = [:]
        footersAttributes = [:]
        unionRects = []
        allItemAttributes = []
        sectionItemAttributes = []
        columnHeights = (0 ..< numberOfSections).map { section in
            let columns = self.columns(forSection: section)
            let sectionColumnHeights = (0 ..< columns).map { CGFloat($0) }
            return sectionColumnHeights
        }

        var top: CGFloat = 0.0
        var attributes = NSUICollectionViewLayoutAttributes()

        for section in 0 ..< numberOfSections {
            // MARK: 1. Get section-specific metrics (minimumInteritemSpacing, sectionInset)

            let columns = columnHeights[section].count
            let itemWidth = itemWidth(inSection: section)

            // MARK: 2. Section header

            if headerHeight > 0 {
                attributes = NSUICollectionViewLayoutAttributes(forSupplementaryViewOfKind: NSUICollectionView.elementKindSectionHeader, with: IndexPath(item: 0, section: section))
                attributes.frame = CGRect(x: 0, y: top, width: collectionView.bounds.size.width, height: headerHeight)
                headersAttributes[section] = attributes
                allItemAttributes.append(attributes)
                top = attributes.frame.maxY
            }
            top += sectionInset.top
            columnHeights[section] = [CGFloat](repeating: top, count: columns)

            // MARK: 3. Section items

            let itemCount = collectionView.numberOfItems(inSection: section)
            var itemAttributes: [NSUICollectionViewLayoutAttributes] = []
            
            // Item will be put into shortest column.
            for idx in 0 ..< itemCount {
                let indexPath = IndexPath(item: idx, section: section)

                let columnIndex = nextColumnIndexForItem(at: indexPath, keepOrder: keepOrder)
                let xOffset = sectionInset.left + (itemWidth + minimumColumnSpacing) * CGFloat(columnIndex)

                let yOffset = columnHeights[section][columnIndex]
                var itemHeight: CGFloat = 0.0
                if let itemSize = itemSizeProvider?(indexPath),
                   itemSize.height > 0
                {
                    itemHeight = itemSize.height
                    if itemSize.width > 0 {
                        itemHeight = floor(itemHeight * itemWidth / itemSize.width)
                    } // else use default item width based on other parameters
                }
                #if os(macOS)
                    attributes = NSUICollectionViewLayoutAttributes(forItemWith: indexPath)
                #elseif canImport(UIKit)
                    attributes = NSUICollectionViewLayoutAttributes(forCellWith: indexPath)
                #endif
                attributes.frame = CGRect(x: xOffset, y: yOffset, width: itemWidth, height: itemHeight)
                mappedItemColumns[indexPath] = columnIndex
                itemAttributes.append(attributes)
                allItemAttributes.append(attributes)
                columnHeights[section][columnIndex] = attributes.frame.maxY + minimumInteritemSpacing
            }
            sectionItemAttributes.append(itemAttributes)

            // MARK: 4. Section footer

            let columnIndex = longestColumnIndex(inSection: section)
            top = columnHeights[section][columnIndex] - minimumInteritemSpacing + sectionInset.bottom

            if footerHeight > 0 {
                attributes = NSUICollectionViewLayoutAttributes(forSupplementaryViewOfKind: NSUICollectionView.elementKindSectionFooter, with: IndexPath(item: 0, section: section))
                attributes.frame = CGRect(x: 0, y: top, width: collectionView.bounds.size.width, height: footerHeight)
                footersAttributes[section] = attributes
                allItemAttributes.append(attributes)
                top = attributes.frame.maxY
            }

            columnHeights[section] = [CGFloat](repeating: top, count: columns)
        }

        var idx = 0
        let itemCounts = allItemAttributes.count
        while idx < itemCounts {
            let rect1 = allItemAttributes[idx].frame
            idx = min(idx + unionSize, itemCounts) - 1
            let rect2 = allItemAttributes[idx].frame
            unionRects.append(rect1.union(rect2))
            idx += 1
        }
    }
    
    var scrollOffset: CGPoint? = nil
    func scrollToDisplayingItems() {
        guard !isScrolling, let collectionView = collectionView, let displayingItems = displayingItems else { return }
        let itemFrames = displayingItems.compactMap({ layoutAttributesForItem(at:$0)?.frame })
        print("scrollToDisplaying start", itemFrames.unionAlt().center.y, displayingItems.compactMap({$0.item}).sorted())
        isScrolling = true
        keepItemOrder = true
        if displayingItems.isEmpty {
            scrollOffset = nil
        } else {
            scrollOffset = itemFrames.unionAlt().center
        }
    //    scrollOffset = itemFrames.unionAlt().center
      //  collectionView.contentOffset.y =  itemFrames.unionAlt().center.y
        collectionView.scrollToItems(at: displayingItems, scrollPosition: .centeredVertically)
        Swift.print("scrollToDisplaying end")
        keepItemOrder = false
    }
    
    func setupDisplayingItems(_ rect: CGRect) {
        delayedVisibleItemsReset?.cancel()
        guard let collectionView = collectionView else { return }
        let task = DispatchWorkItem {
            self.displayingItems = nil
        }
        delayedVisibleItemsReset = task
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.6, execute: task)
        if displayingItems == nil {
            displayingItems = Set(collectionView.displayingIndexPaths(in: rect))
        }
    }
    
    /*
    override public func shouldInvalidateLayout(forBoundsChange newBounds: CGRect) -> Bool {
        guard keepItemsCenteredWhenResizing else { return false }
        print("shouldInvalidate",newBounds.width != bounds.width, newBounds, bounds )
        if newBounds.width != bounds.width {
            setupDisplayingItems(bounds)
            keepItemOrder = true
            isScrolling = false
            invalidateLayout()
            scrollToDisplayingItems()
            bounds.size = newBounds.size
            return false
        }
        bounds = newBounds
        scrollToDisplayingItems()
        return false
    }
     */

    override public var collectionViewContentSize: CGSize {
        if collectionView!.numberOfSections == 0 {
            return .zero
        }

        var contentSize = collectionView!.bounds.size
        contentSize.width = collectionViewContentWidth

        if let height = columnHeights.last?.first {
            contentSize.height = height
            return contentSize
        }
        return .zero
    }

    override public func layoutAttributesForItem(at indexPath: IndexPath) -> NSUICollectionViewLayoutAttributes? {
        if indexPath.section >= sectionItemAttributes.count {
            print("itemAttributes", indexPath.item)
            return nil
        }
        let list = sectionItemAttributes[indexPath.section]
        if indexPath.item >= list.count {
            print("itemAttributes", indexPath.item)
            return nil
        }
     //   allItemFrames.append(list[indexPath.item].frame)
        print("itemAttributes", indexPath.item, list[indexPath.item].frame)

        return list[indexPath.item]
    }
    

    
    public override func targetContentOffset(forProposedContentOffset proposedContentOffset: NSPoint) -> NSPoint {
        print("targetContentOffset",proposedContentOffset)
        return super.targetContentOffset(forProposedContentOffset: proposedContentOffset)
    }
    
    public override func targetContentOffset(forProposedContentOffset proposedContentOffset: NSPoint, withScrollingVelocity velocity: NSPoint) -> NSPoint {
        print("targetContentOffsetVelocity",proposedContentOffset, velocity)
        return super.targetContentOffset(forProposedContentOffset: proposedContentOffset, withScrollingVelocity: velocity)
    }

    override public func layoutAttributesForSupplementaryView(ofKind elementKind: String, at indexPath: IndexPath) -> NSUICollectionViewLayoutAttributes {
        var attribute: NSUICollectionViewLayoutAttributes?
        if elementKind == NSUICollectionView.elementKindSectionHeader {
            attribute = headersAttributes[indexPath.section]
        } else if elementKind == NSUICollectionView.elementKindSectionFooter {
            attribute = footersAttributes[indexPath.section]
        }
        return attribute ?? NSUICollectionViewLayoutAttributes()
    }

    override public func layoutAttributesForElements(in rect: CGRect) -> [NSUICollectionViewLayoutAttributes] {
        var begin = 0, end = unionRects.count

        if let i = unionRects.firstIndex(where: { rect.intersects($0) }) {
            begin = i * unionSize
        }
        if let i = unionRects.lastIndex(where: { rect.intersects($0) }) {
            end = min((i + 1) * unionSize, allItemAttributes.count)
        }
        layoutItemAttributes = (allItemAttributes[begin ..< end]
            .filter { rect.intersects($0.frame) }).sorted(by: \.indexPath?.item)
        
        print("elementAttributes", rect, layoutItemAttributes.compactMap({$0.indexPath?.item}), layoutItemAttributes.compactMap({$0.frame}))
        return layoutItemAttributes.sorted(by: \.indexPath?.item)
    }

    private func shortestColumnIndex(inSection section: Int) -> Int {
        columnHeights[section].enumerated()
            .min(by: { $0.element < $1.element })?
            .offset ?? 0
    }

    private func longestColumnIndex(inSection section: Int) -> Int {
        columnHeights[section].enumerated()
            .max(by: { $0.element < $1.element })?
            .offset ?? 0
    }
    
    public override func invalidateLayout() {
        print("invalidateLayout")
        super.invalidateLayout()
    }
    
    public override func invalidateLayout(with context: NSCollectionViewLayoutInvalidationContext) {
        print("invalidateLayoutContext")
        super.invalidateLayout(with: context)
    }
        
    public override func shouldInvalidateLayout(forPreferredLayoutAttributes preferredAttributes: NSCollectionViewLayoutAttributes, withOriginalAttributes originalAttributes: NSCollectionViewLayoutAttributes) -> Bool {
        print("shouldInvalidateAttributes", super.shouldInvalidateLayout(forPreferredLayoutAttributes: preferredAttributes, withOriginalAttributes: originalAttributes), preferredAttributes.frame, originalAttributes.frame)
        return super.shouldInvalidateLayout(forPreferredLayoutAttributes: preferredAttributes, withOriginalAttributes: originalAttributes)
    }
    
    private func nextColumnIndexForItem(at indexPath: IndexPath, keepOrder: Bool) -> Int {
        if keepOrder, let mappedColumn = mappedItemColumns[indexPath] {
            return mappedColumn
        }
        var index = 0
        let columns = columns(forSection: indexPath.section)
        switch itemRenderDirection {
        case .shortestColumn:
            index = shortestColumnIndex(inSection: indexPath.section)
        case .leftToRight:
            index = indexPath.item % columns
        case .rightToLeft:
            index = (columns - 1) - (indexPath.item % columns)
        }
        return index
    }
}
*/

protocol PinchableCollectionViewLayout: AnyObject {
    var columns: Int { get set }
    var columnRange: ClosedRange<Int> { get }
    var isPinchable: Bool { get }
    var keyDownColumnChangeAmount: Int { get }
    var keyDownAltColumnChangeAmount: Int { get }
    var keyDownAlt2ColumnChangeAmount: Int { get }
}

#if os(macOS) || os(iOS)
extension NSUICollectionViewLayout {
    var columnConfiguration: ColumnConfiguration? {
        get { getAssociatedValue("columnConfiguration", initialValue: nil) }
        set { setAssociatedValue(newValue, key: "columnConfiguration") }
    }
    
    struct ColumnConfiguration {
        let columns: Int
        let columnRange: ClosedRange<Int>
        let isPinchable: Bool
        let animated: Bool
        let changeAmount: Int
        let changeAmountAlt: Int
        let changeAmountAlt2: Int
        let invalidation: ((_ columns: Int)->(NSUICollectionViewLayout))
    }
}

extension NSUICollectionView {
    var pinchColumnsGestureRecognizer: PinchColumnsGestureRecognizer? {
        get { getAssociatedValue("pinchColumnsGestureRecognizer", initialValue: nil) }
        set { setAssociatedValue(newValue, key: "pinchColumnsGestureRecognizer") }
    }
    func setupPinchGestureRecognizer(_ needsRecognizer: Bool) {
        if needsRecognizer, pinchColumnsGestureRecognizer == nil {
            pinchColumnsGestureRecognizer = .init(target: nil, action: nil)
            addGestureRecognizer(pinchColumnsGestureRecognizer!)
        } else if !needsRecognizer, let gestureRecognizer = pinchColumnsGestureRecognizer {
            removeGestureRecognizer(gestureRecognizer)
            pinchColumnsGestureRecognizer = nil
        }
    }
    
    class PinchColumnsGestureRecognizer: NSUIMagnificationGestureRecognizer {
        
        var initalColumnCount: Int = 0
        var previousColumnCount: Int = 0
        var displayingIndexPaths: [IndexPath] = []
        var delayedDisplayingReset: DispatchWorkItem?
        var delayedCollectionViewScroll: DispatchWorkItem?
        let scrollDelay: TimeInterval = 0.1
        
        var collectionView: NSUICollectionView? {
            view as? NSUICollectionView
        }
        
        var collectionViewLayout: NSUICollectionViewLayout? {
            (view as? NSUICollectionView)?.collectionViewLayout
        }
        
        var configuration: NSUICollectionViewLayout.ColumnConfiguration? {
            collectionViewLayout?.columnConfiguration
        }
        
        var pinchLayout: PinchableCollectionViewLayout? {
            if let layout = collectionViewLayout as? PinchableCollectionViewLayout, layout.isPinchable {
                return layout
            }
            return nil
        }
        
        var columns: Int {
            get { pinchLayout?.columns ?? configuration?.columns ?? 2 }
            set {
                guard newValue != columns else { return }
                if let pinchLayout = pinchLayout {
                    pinchLayout.columns = newValue
                } else if let collectionView = collectionView, let layout = configuration?.invalidation(newValue) {
                    collectionView.setCollectionViewLayout(layout, animated: configuration?.animated == true)
                }
            }
        }
        
        var columnRange: ClosedRange<Int> {
            pinchLayout?.columnRange ?? configuration?.columnRange ?? 0...0
        }
        
        var isPinchable: Bool {
            let isPinchable = pinchLayout?.isPinchable ?? configuration?.isPinchable ?? false
            return isPinchable ? isPinchable : check(isPinchable)
        }
                
        var isKeyDownControllable: Bool {
            let isKeyDownControllable = keyDownColumnChangeAmount > 0 || keyDownColumnChangeAmount == -1 || keyDownAltColumnChangeAmount > 0 || keyDownAltColumnChangeAmount == -1 || keyDownAlt2ColumnChangeAmount > 0 || keyDownAlt2ColumnChangeAmount == -1
            return isKeyDownControllable ? isKeyDownControllable : check(isKeyDownControllable)
        }
        
        func check(_ value: Bool) -> Bool {
            guard let collectionView = collectionView, collectionViewLayout != nil, (isPinchable || isKeyDownControllable) else { return value }
            removeFromView()
            collectionView.pinchColumnsGestureRecognizer = nil
            return false
        }
        
        var keyDownColumnChangeAmount: Int {
            pinchLayout?.keyDownColumnChangeAmount ?? configuration?.changeAmount ?? 0
        }
        
        var keyDownAltColumnChangeAmount: Int {
            let amount = pinchLayout?.keyDownAltColumnChangeAmount ?? configuration?.changeAmountAlt ?? 0
            return amount == -1 ? columnRange.count : amount
        }
        
        var keyDownAlt2ColumnChangeAmount: Int {
            let amount = pinchLayout?.keyDownAlt2ColumnChangeAmount ?? configuration?.changeAmountAlt2 ?? 0
            return amount == -1 ? columnRange.count : amount
        }
                
        #if os(macOS)
        override func keyDown(with event: NSEvent) {
            super.keyDown(with: event)
            
            guard isKeyDownControllable, (event.keyCode == 44 || event.keyCode == 30) else { return }
            var addition = 0
            if event.keyCode == 44 {
                addition = event.modifierFlags.contains(.shift) ? keyDownAlt2ColumnChangeAmount : event.modifierFlags.contains(.command) ? keyDownAltColumnChangeAmount : keyDownColumnChangeAmount
            } else if event.keyCode == 30 {
                addition = event.modifierFlags.contains(.shift) ? -keyDownAlt2ColumnChangeAmount : event.modifierFlags.contains(.command) ? -keyDownAltColumnChangeAmount : -keyDownColumnChangeAmount
            }
            let newColumnCount = (columns + addition).clamped(to: columnRange)
            guard newColumnCount != columns else { return }
            updateDisplayingIndexPaths()
            columns = newColumnCount
            scrollToDisplayingIndexPaths()
            displayingIndexPaths.removeAll()
        }
        #endif
        
        var _isPinchable = true
        override var state: NSUIGestureRecognizer.State {
            didSet {
                switch state {
                case .began:
                    _isPinchable = isPinchable
                    guard _isPinchable else { return }
                    initalColumnCount = columns
                    previousColumnCount = initalColumnCount
                    updateDisplayingIndexPaths()
                case .changed:
                    guard _isPinchable else { return }
                    #if os(macOS)
                    let newCount = ((initalColumnCount + Int((magnification/(-0.5)).rounded())).clamped(to: columnRange))
                    #else
                    let newCount = ((initalColumnCount + Int((scale/(-0.5)).rounded())).clamped(to: columnRange))
                    #endif
                    delayedCollectionViewScroll?.cancel()
                    columns = newCount
                    guard !displayingIndexPaths.isEmpty else { return }
                    if newCount < previousColumnCount {
                        let task = DispatchWorkItem { [weak self] in
                            guard let self = self else { return }
                            self.scrollToDisplayingIndexPaths()
                        }
                        delayedCollectionViewScroll = task
                        DispatchQueue.main.asyncAfter(deadline: .now() + scrollDelay, execute: task)
                    } else if newCount > previousColumnCount {
                        scrollToDisplayingIndexPaths()
                    }
                    previousColumnCount = newCount
                case .cancelled, .failed, .ended:
                    guard _isPinchable, !displayingIndexPaths.isEmpty else { return }
                    let task = DispatchWorkItem { [weak self] in
                        guard let self = self else { return }
                        self.displayingIndexPaths.removeAll()
                    }
                    delayedDisplayingReset = task
                    DispatchQueue.main.asyncAfter(deadline: .now() + (scrollDelay + 0.02), execute: task)
                default: break
                }
            }
        }
        
        func updateDisplayingIndexPaths() {
            delayedCollectionViewScroll?.cancel()
            displayingIndexPaths = collectionView?.displayingIndexPaths() ?? []
        }
        
        func scrollToDisplayingIndexPaths() {
            guard !displayingIndexPaths.isEmpty, let collectionView = collectionView else { return }
            #if os(macOS)
            collectionView.scrollToItems(at: Set(self.displayingIndexPaths), scrollPosition: .centeredVertically)
            #else
            collectionView.scrollToItems(at: Set(self.displayingIndexPaths), at: .centeredVertically)
            #endif
        }
    }
}

struct KeyDownColumnChange {
    public var amount: Int = 0 {
        didSet { amount.clamp(min: -1) }
    }
    
    public var amountAlt: Int = 0 {
        didSet { amountAlt.clamp(min: -1) }
    }
    
    public var amountSecondaryAlt: Int = 0 {
        didSet { amountSecondaryAlt.clamp(min: -1) }
    }
    
    func test() {
        var keyDownColumnChange = KeyDownColumnChange()
        keyDownColumnChange.amount = 4
    }
    
    var needsGestureRecognizer: Bool {
        amount > 0 || amount == -1 || amountAlt > 0 || amountAlt == -1 || amountSecondaryAlt > 0 || amountSecondaryAlt == -1
    }
}

extension NSUICollectionView {
    /// Returns the index paths of the currently displayed items. Unlike `indexPathsForVisibleItems()`  it only returns the items with visible frame.
    public func displayingIndexPaths(in rect: CGRect) -> [IndexPath] {
        (displayingItems(in: rect).compactMap { self.indexPath(for: $0) }).sorted()
    }
    
    /// Returns an array of all displayed items. Unlike `visibleItems()` it only returns the items with visible frame.
    public func displayingItems(in rect: CGRect) -> [NSCollectionViewItem] {
        let visibleItems = visibleItems()
        return visibleItems.filter { $0.view.frame.intersects(rect) }
    }
}

#endif
#endif

