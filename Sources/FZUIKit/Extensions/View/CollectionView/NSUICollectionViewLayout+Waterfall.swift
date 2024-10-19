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
    /**
     A interactive waterfall layout where the user can change the amount of columns by pinching the collection view.

     - Parameters:
        - columns: The amount of columns.
        - spacing: The spacing between the columns and items.
        - insets: The layout insets.
        - orientation: The orientation of the layout.
        - itemSizeProvider: The handler that provides the item sizes..
     */
    public static func waterfall(columns: Int, spacing: CGFloat = 10, insets: NSUIEdgeInsets = .init(10.0), orientation: NSUIUserInterfaceLayoutOrientation = .horizontal, itemSizeProvider: @escaping (_ indexPath: IndexPath) -> CGSize) -> CollectionViewColumnLayout {
        let layout = CollectionViewColumnLayout.init(columns: columns, orientation: orientation, spacing: spacing, insets: insets)
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
    public static func grid(columns: Int, orientation: NSUIUserInterfaceLayoutOrientation = .horizontal, spacing: CGFloat = 10, insets: NSUIEdgeInsets = .init(10.0), itemAspectRatio: CGSize = CGSize(1,1)) -> CollectionViewColumnLayout {
        let layout = CollectionViewColumnLayout.init(columns: columns, orientation: orientation, spacing: spacing, insets: insets)
        layout.itemLayout = .grid(itemAspectRatio)
        return layout
    }
}

/// A layout that organizes items into columns (either as `waterfall` or `grid`).
public class CollectionViewColumnLayout: NSCollectionViewFlowLayout, InteractiveCollectionViewLayout {
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
    public enum ItemSortOrder: Int {
        /// Each item is added to the shortest column.
        case shortestColumn
        /// The items are added to the columns from left to right.
        case leftToRight
        /// The items are added to the columns from right to left.
        case rightToLeft
    }
    
    /// The sizing for each column.
    public enum ColumnSizing: Hashable {
        /// Fixed column size.
        case fixed(CGFloat)
        /// Fixed column size.
        case relative(CGFloat)
        /// Each column size.
        case automatic
    }
    
    /// The amount of columns.
    @objc dynamic open var columns: Int = 3 {
        didSet { columns = columns.clamped(to: columnRange) }
    }
    
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
        public var animationDuration: CGFloat = 0.2
        
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
    
    /// User interaction options for changing the amount of columns by pinching the collection view and pressing the `plus` or `minus` key.
    public var userInteraction: UserInteraction = .init()
    
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
    open func isPinchable(_ isPinchable: Bool) -> Self {
        self.isPinchable = isPinchable
        return self
    }
    
    #if os(macOS)
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
    
    /// The amount of columns added or removed when the user presses the `plus` / `minus` key.
    public var keyDownColumnControl: KeyDownColumnControl = .disabled {
        didSet {
            keyDownColumnControl = keyDownColumnControl.clamped
            collectionView?.setupPinchGestureRecognizer(needsPinchGestureRecognizer)
        }
    }
    
    /// Sets the amount of columns added or removed when the user presses the `plus` / `minus` key.
    @discardableResult
    open func keyDownColumnControl(_ keyDownColumnControl: KeyDownColumnControl = .disabled ) -> Self {
        self.keyDownColumnControl = keyDownColumnControl
        return self
    }
    
    /// The amount of columns added or removed when the user presses the `plus` / `minus` key while holding `command`.
    public var keyDownColumnControlCommand: KeyDownColumnControl = .disabled {
        didSet {
            keyDownColumnControlCommand = keyDownColumnControlCommand.clamped
            collectionView?.setupPinchGestureRecognizer(needsPinchGestureRecognizer)
        }
    }
    
    /// Sets the amount of columns added or removed when the user presses the `plus` / `minus` key while holding `command`.
    @discardableResult
    open func keyDownColumnControlCommand(_ keyDownColumnControl: KeyDownColumnControl = .disabled ) -> Self {
        self.keyDownColumnControlCommand = keyDownColumnControl
        return self
    }
    
    /// The amount of columns added or removed when the user presses the `plus` / `minus` key while holding `shift`.
    public var keyDownColumnControlShift: KeyDownColumnControl = .disabled {
        didSet {
            keyDownColumnControlShift = keyDownColumnControlShift.clamped
            collectionView?.setupPinchGestureRecognizer(needsPinchGestureRecognizer)
        }
    }
    
    /// Sets the amount of columns added or removed when the user presses the `plus` / `minus` key while holding `shift`.
    @discardableResult
    open func keyDownColumnControlShift(_ keyDownColumnControl: KeyDownColumnControl = .disabled ) -> Self {
        self.keyDownColumnControlShift = keyDownColumnControl
        return self
    }
    
    /// The amount of columns added or removed when the user presses the `plus` / `minus` key.
    var keyDownColumnChangeAmount: Int {
        keyDownColumnControl.value
    }
    
    var keyDownAltColumnChangeAmount: Int  {
        keyDownColumnControlCommand.value
        
    }
    
    var keyDownAlt2ColumnChangeAmount: Int {
        keyDownColumnControlShift.value
    }
    #else
    let keyDownColumnChangeAmount = 0
    let keyDownAltColumnChangeAmount = 0
    let keyDownAlt2ColumnChangeAmount = 0
    #endif
    
    /// The minimum amount of columns that the user can change to, if ``isPinchable`` or ``keyDownColumnControl`` is enabled.
    open var minColumns: Int = 1
    
    /// Sets the minimum amount of columns that the user can change to, if ``isPinchable`` or ``keyDownColumnControl`` is enabled.
    @discardableResult
    open func minColumns(_ minimum: Int) -> Self {
        minColumns = minimum
        return self
    }
    
    /// The maximum amount of columns that the user can change to, if ``isPinchable`` or ``keyDownColumnControl`` is enabled.
    open var maxColumns: Int = 12
    
    /// Sets the maximum amount of columns that the user can change to, if ``isPinchable`` or ``keyDownColumnControl`` is enabled.
    @discardableResult
    open func maxColumns(_ maximum: Int) -> Self {
        maxColumns = maximum
        return self
    }
    
    var columnRange: ClosedRange<Int> {
        minColumns...maxColumns
    }
    
    /**
     The animation duration when the user changes the amount of columns via pinch gesture or `plus` / `minus` key.
     
     The value is only used, if ``isPinchable`` or ``keyDownColumnControl-swift.property`` is enabled.
     
     A value of `0.0` changes the columns amount without any animation.
     */
    open var animationDuration: TimeInterval = 0.2 {
        didSet { animationDuration.clamp(min: 0.0) }
    }
    
    /**
     Sets the animation duration when the user changes the amount of columns via pinch gesture or `plus` / `minus` key.
     
     The value is only used, if ``isPinchable`` or ``keyDownColumnControl-swift.property`` is enabled.
     
     A value of `0.0` changes the columns amount without any animation.
     */
    @discardableResult
    open func animationDuration(_ duration:  TimeInterval) -> Self {
        animationDuration = duration
        return self
    }
    
    var needsPinchGestureRecognizer: Bool {
        isPinchable || (keyDownColumnChangeAmount == -1 || keyDownColumnChangeAmount  > 0) || (keyDownAltColumnChangeAmount == -1 || keyDownAltColumnChangeAmount  > 0) || (keyDownAlt2ColumnChangeAmount == -1 || keyDownAlt2ColumnChangeAmount  > 0)
    }
    
#else
    var isPinchable = false
    var keyDownColumnChangeAmount = 0
    var keyDownAltColumnChangeAmount = 0
    var keyDownAlt2ColumnChangeAmount = 0
    var columnRange = 2...12
    var animationDuration: TimeInterval = 0.2
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
    
    public struct HeaderFooterAttributes {
        /// The height of the header/footer.
        public var height: CGFloat = 0.0
        
        /// The inset of the header/footer.
        public var inset: NSEdgeInsets = .zero
        
        /// A Boolean value indicating whether the header/footer is floating.
        public var floats: Bool = false
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
    public var columnSizing: ColumnSizing = .automatic {
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
    open func columnSizing(_ columnSizing: ColumnSizing) -> Self {
        self.columnSizing = columnSizing
        return self
    }
    
    /*
    /// The margins used to lay out content in a section.
    open var sectionInset: NSUIEdgeInsets = NSUIEdgeInsets(10)
     */
    
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
    private var headersAttributes: [Int: NSUICollectionViewLayoutAttributes] = [:]
    private var footersAttributes: [Int: NSUICollectionViewLayoutAttributes] = [:]
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
        if #available(macOS 11.0, *), sectionInsetUsesSafeArea {
            size.width -= collectionView.enclosingScrollView?.safeAreaInsets.width ?? 0
            size.height -= collectionView.enclosingScrollView?.safeAreaInsets.height ?? 0
        } else {
            size.width -= collectionView.enclosingScrollView?.contentInsets.width ?? 0
            size.height -= collectionView.enclosingScrollView?.contentInsets.height ?? 0
        }
        #else
        size.width -= (sectionInsetUsesSafeArea ? collectionView.adjustedContentInset : collectionView.contentInsets).width
        size.height -= (sectionInsetUsesSafeArea ? collectionView.adjustedContentInset : collectionView.contentInsets).height
        #endif
        if includingSectionInset {
            size.width -= sectionInset.width
            size.height -= sectionInset.height
        }
        size.height -= (header.height + header.inset.height + footer.height + footer.inset.height)
        
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
        super.prepare()
        if didCalcuateItemAttributes == false {
            #if os(macOS) || os(iOS)
            collectionView?.setupPinchGestureRecognizer(needsPinchGestureRecognizer)
            #endif
            prepareItemAttributes()
        } else {
            didCalcuateItemAttributes = false
        }
    }
    
    func prepareItemAttributes(keepItemOrder: Bool = false) {
        guard let collectionView = collectionView, collectionView.numberOfSections > 0  else { return }
        let numberOfSections = collectionView.numberOfSections

        headersAttributes = [:]
        footersAttributes = [:]
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
                attributes = NSUICollectionViewLayoutAttributes(forSupplementaryViewOfKind: NSUICollectionView.elementKindSectionHeader, with: IndexPath(item: 0, section: section))
                attributes.frame = CGRect(x: header.inset.left, y: CGFloat(top), width: collectionView.frame.size.width - (header.inset.left + header.inset.right), height: CGFloat(header.height))
                
                headersAttributes[section] = attributes
                allItemAttributes.append(attributes)
                
                top = attributes.frame.maxY + header.inset.bottom
            }
            
            top += sectionInset.top
            columnSizes[section] = [CGFloat](repeating: top, count: columns)

            // MARK: 3. Section items

            let itemCount = collectionView.numberOfItems(inSection: section)
            var itemAttributes: [NSUICollectionViewLayoutAttributes] = []

            // Item will be put into shortest column.
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
                attributes = NSUICollectionViewLayoutAttributes(forSupplementaryViewOfKind: NSUICollectionView.elementKindSectionFooter, with: IndexPath(item: 0, section: section))
                attributes.frame = CGRect(x: footer.inset.left, y: CGFloat(top), width: collectionView.frame.size.width - (footer.inset.left + footer.inset.right), height: CGFloat(footer.height))
                
                footersAttributes[section] = attributes
                allItemAttributes.append(attributes)
                
                top = attributes.frame.maxY + footer.inset.bottom
            }

            columnSizes[section] = [CGFloat](repeating: top, count: columns)
        }

        var idx = 0
        while idx < allItemAttributes.count {
            let rect1 = allItemAttributes[idx].frame
            idx = min(idx + unionSize, allItemAttributes.count) - 1
            let rect2 = allItemAttributes[idx].frame
            unionRects.append(rect1.union(rect2))
            idx += 1
        }
    }
    
    override open var collectionViewContentSize: CGSize {
        guard let collectionView = collectionView, collectionView.numberOfSections > 0, let size = columnSizes.last?.first else {
            return .zero
        }
        return orientation == .horizontal ? CGSize(collectionView.bounds.width, size) : CGSize(size, collectionView.bounds.height)
    }
    
    /*
    @objc var scrollDirection: NSUICollectionView.ScrollDirection {
        orientation == .horizontal ? .vertical : .horizontal
    }
     */

    override open func layoutAttributesForItem(at indexPath: IndexPath) -> NSUICollectionViewLayoutAttributes? {
        sectionItemAttributes[safe: indexPath.section]?[safe: indexPath.item]
    }
    
    override open func layoutAttributesForSupplementaryView(ofKind elementKind: String, at indexPath: IndexPath) -> NSUICollectionViewLayoutAttributes {
        var attribute: NSUICollectionViewLayoutAttributes?
        if elementKind == NSUICollectionView.elementKindSectionHeader, let attribute = headersAttributes[indexPath.section] {
            updateHeaderFooterAttributes(attribute, isHeader: true)
            return attribute
        } else if elementKind == NSUICollectionView.elementKindSectionFooter, let attribute = footersAttributes[indexPath.section] {
            updateHeaderFooterAttributes(attribute, isHeader: false)
            return attribute
        }
        return attribute ?? NSUICollectionViewLayoutAttributes()
    }
    
    open override func shouldInvalidateLayout(forBoundsChange newBounds: CGRect) -> Bool {
        guard orientation == .horizontal && previousBounds.width != newBounds.width || orientation == .vertical && previousBounds.height != newBounds.height || ((header.floats || footer.floats) && previousBounds.y != newBounds.y) else { return false }
        previousBounds = newBounds
        return true
    }
    
    open override func invalidationContext(forBoundsChange newBounds: CGRect) -> NSUICollectionViewLayoutInvalidationContext {
        let context = super.invalidationContext(forBoundsChange: newBounds)
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
        return context
    }
    
    public override func invalidationContext(forPreferredLayoutAttributes preferredAttributes: NSCollectionViewLayoutAttributes, withOriginalAttributes originalAttributes: NSCollectionViewLayoutAttributes) -> NSCollectionViewLayoutInvalidationContext {
        let context = super.invalidationContext(forPreferredLayoutAttributes: preferredAttributes, withOriginalAttributes: originalAttributes)
        let oldSize = collectionViewContentSize

        
        return context
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
        
        if header.floats {
            attributes.filter({$0.representedElementKind == NSUICollectionView.elementKindSectionHeader}).forEach({ updateHeaderFooterAttributes($0, isHeader: true) })
        }
        
        if footer.floats {
            attributes.filter({$0.representedElementKind == NSUICollectionView.elementKindSectionFooter}).forEach({ updateHeaderFooterAttributes($0, isHeader: false) })
        }

        return attributes
    }
    
    private func updateHeaderFooterAttributes(_ attributes: NSUICollectionViewLayoutAttributes, isHeader: Bool) {
        guard let collectionView = collectionView, (isHeader && header.floats) || (!isHeader && footer.floats) else { return }
        attributes.zIndex = 1
        attributes.isHidden = false
        var yCenterOffset = isHeader ? (collectionView.bounds.y + attributes.size.height/2.0) : (collectionView.bounds.y + collectionView.bounds.height - attributes.size.height/2.0)
        attributes.frame.center = CGPoint(collectionView.bounds.midX, yCenterOffset)
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
    
    public func invalidateLayout(animated: Bool, keepScrollPosition: Bool) {
        guard let collectionView = collectionView else { return }
        // collectionView.setCollectionViewLayout(copied(), animated: animated)
        let displayingIndexPaths: [IndexPath] = keepScrollPosition ? collectionView.displayingIndexPaths() : []
        let animationDuration = animated ? animationDuration : 0.0
        NSAnimationContext.runAnimationGroup({ context in
            context.duration = animationDuration
            collectionView.animator(animated).collectionViewLayout = copied(columns: columns)
            guard !displayingIndexPaths.isEmpty else { return }
            #if os(macOS)
            collectionView.scrollToItems(at: Set(displayingIndexPaths), scrollPosition: .centeredVertically)
            #else
            collectionView.scrollToItems(at: Set(displayingIndexPaths), at: .centeredVertically)
            #endif
        })
    }
    
    func copied(columns: Int? = nil) -> NSUICollectionViewLayout {
        let layout = CollectionViewColumnLayout()
        layout.minColumns = minColumns
        layout.maxColumns = maxColumns
        layout.columns = columns ?? self.columns
        layout.columnSpacing = columnSpacing
        layout.columnSizing = columnSizing
        layout.itemSpacing = itemSpacing
        layout.orientation = orientation
        layout.itemLayout = itemLayout
        layout.sectionInset = sectionInset
        layout.header = header
        layout.footer = footer
        layout.isPinchable = isPinchable
        layout.keyDownColumnControl = keyDownColumnControl
        layout.keyDownColumnControlCommand = keyDownColumnControlCommand
        layout.keyDownColumnControlShift = keyDownColumnControlShift
        layout.animationDuration = animationDuration
        layout.itemOrder = itemOrder
        layout._sectionInsetUsesSafeArea = _sectionInsetUsesSafeArea
        return layout
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
    public static func waterfall(columnsCount columns: Int, spacing: CGFloat = 10, insets: NSUIEdgeInsets = .init(10.0), orientation: NSUIUserInterfaceLayoutOrientation = .horizontal, itemSizeProvider: @escaping ItemSizeProvider) -> CollectionViewColumnLayout {
        let layout = CollectionViewColumnLayout()
        layout.columns = columns
        layout.orientation = orientation
        layout.itemSpacing = spacing
        layout.columnSpacing = spacing
        layout.itemLayout = .waterfall(itemSizeProvider)
        layout.sectionInset = insets
        return layout
    }
    
    /*
    public override func invalidateLayout(with context: NSCollectionViewLayoutInvalidationContext) {
        Swift.print("invalidateLayout(with", context.invalidateEverything, context.invalidateDataSourceCounts, context.invalidatedItemIndexPaths?.count ?? "nil")
        return super.invalidateLayout(with: context)
    }
     */
    
    /**
     Creates a grid collection view layout.
     
     - Parameters:
        - columnsCount: The amount of columns for the grid.
        - spacing: The spacing between the columns and items.
        - insets: The insets of the layout.
        - orientation: The orientation of the layout.
        - itemAspectRatio: The aspect ratio of the items.
     */
    public static func grid(columnsCount: Int, orientation: NSUIUserInterfaceLayoutOrientation = .horizontal, spacing: CGFloat = 10, insets: NSUIEdgeInsets = .init(10.0), itemAspectRatio: CGSize = CGSize(1,1)) -> CollectionViewColumnLayout {
        let layout = CollectionViewColumnLayout()
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


protocol InteractiveCollectionViewLayout {
    var columns: Int { get set }
    var columnRange: ClosedRange<Int> { get }
    var isPinchable: Bool { get }
    var keyDownColumnChangeAmount: Int { get }
    var keyDownAltColumnChangeAmount: Int { get }
    var keyDownAlt2ColumnChangeAmount: Int { get }
    var animationDuration: TimeInterval { get }
    func copied(columns: Int?) -> NSUICollectionViewLayout
}

#if os(macOS) || os(iOS)
extension NSUICollectionView {
    var pinchColumnsGestureRecognizer: PinchColumnsGestureRecognizer? {
        get { getAssociatedValue("pinchColumnsGestureRecognizer") }
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
        
        var initalColumns: Int = 0
        var displayingIndexPaths: [IndexPath] = []
        
        var collectionView: NSUICollectionView? {
            view as? NSUICollectionView
        }
        
        var collectionViewLayout: NSUICollectionViewLayout? {
            collectionView?.collectionViewLayout
        }
        
        var configuration: InteractiveCollectionViewLayout? {
            collectionViewLayout as? InteractiveCollectionViewLayout
        }
                
        var columns: Int {
            get { configuration?.columns ?? 2 }
            set {
                let newValue = newValue.clamped(to: columnRange)
                guard newValue != columns, let configuration = configuration, let collectionView = collectionView else { return }
                collectionView.setCollectionViewLayout(configuration.copied(columns: newValue), animated: true)
                /*
                
                guard newValue != columns, let layout = collectionViewLayout as? CollectionViewColumnLayout, let collectionView = collectionView else { return }
                layout.columns = newValue
              //  let context = NSCollectionViewLayoutInvalidationContext()
                
                let displayingIndexPaths = Set(collectionView.displayingIndexPaths())
                layout.invalidateLayout()
                collectionView.scrollToItems(at: displayingIndexPaths, scrollPosition: .centeredVertically)
                /*
               let union = collectionView.displayingIndexPaths().compactMap({ layout.layoutAttributesForItem(at: $0)?.frame }).union()
                
                
                layout.prepareItemAttributes()
                let context = layout.invalidationContext(forBoundsChange: union)
                layout.invalidateLayout(with: context)
                 */
             //   layout.invalidateLayoutAnimated()
                /*
                guard newValue != columns, let configuration = configuration, collectionView = collectionView else { return }
                collectionView.setCollectionViewLayout(configuration.copied(columns: newValue), animated: true)
                 */
                 */
            }
        }
        
        var columnRange: ClosedRange<Int> {
            configuration?.columnRange ?? 1...12
        }
        
        var isPinchable: Bool {
            configuration?.isPinchable ?? false
        }
                
        #if os(macOS)
        override func keyDown(with event: NSEvent) {
            super.keyDown(with: event)
            guard event.keyCode == 44 || event.keyCode == 30, let configuration = configuration else { return }
            var addition = event.modifierFlags.contains(.shift) ? configuration.keyDownAlt2ColumnChangeAmount : event.modifierFlags.contains(.command) ? configuration.keyDownAltColumnChangeAmount : configuration.keyDownColumnChangeAmount
            displayingIndexPaths = collectionView?.displayingIndexPaths() ?? []
            if addition == -1 {
                columns = event.keyCode == 44 ? columnRange.upperBound : columnRange.lowerBound
            } else {
                columns += event.keyCode == 44 ? addition : -addition
            }
            scrollToDisplayingIndexPaths()
        }
        #endif
                
        override var state: NSUIGestureRecognizer.State {
            didSet {
                switch state {
                case .began:
                    initalColumns = isPinchable ? columns : -1
                    displayingIndexPaths = isPinchable ? collectionView?.displayingIndexPaths() ?? [] : []
                case .changed:
                    guard initalColumns != -1 else { return }
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

extension NSUICollectionView {
    /// Returns the index paths of the currently displayed items. Unlike `indexPathsForVisibleItems()`  it only returns the items with visible frame.
    public func displayingIndexPaths(in rect: CGRect) -> [IndexPath] {
        #if os(macOS)
        return (displayingItems(in: rect).compactMap { self.indexPath(for: $0) }).sorted()
        #else
        return (displayingCells(in: rect).compactMap { self.indexPath(for: $0) }).sorted()
        #endif
    }
    
    #if os(macOS)
    /// Returns an array of all displayed items. Unlike `visibleItems()` it only returns the items with visible frame.
    public func displayingItems(in rect: CGRect) -> [NSCollectionViewItem] {
        let visibleItems = visibleItems()
        return visibleItems.filter { $0.view.frame.intersects(rect) }
    }
    #else
    /// Returns an array of all displayed items. Unlike `visibleItems()` it only returns the items with visible frame.
    public func displayingCells(in rect: CGRect) -> [UICollectionViewCell] {
        let visibleItems = visibleCells
        return visibleItems.filter { $0.frame.intersects(rect) }
    }
    #endif
}
#endif
#endif
