//
//  NSSegmentedControl+Segment.swift
//
//
//  Created by Florian Zand on 18.08.22.
//

#if os(macOS)

import AppKit

/// A segment of a [NSSegmentedControl](https://developer.apple.com/documentation/appkit/nssegmentedcontrol).
public class NSSegment: NSObject, ExpressibleByStringLiteral {
    internal weak var segmentedControl: NSSegmentedControl?
    private weak var toolbarItem: Toolbar.SegmentedControl?
    
    /// The title of the segment.
    public var title: String? {
        didSet {
            guard let index = index else { return }
            segmentedControl?.setLabel(title ?? "", forSegment: index)
        }
    }
    
    /// The title alignment of the segment.
    public var titleAlignment: NSTextAlignment = .center {
        didSet {
            guard let index = index else { return }
            segmentedControl?.setAlignment(titleAlignment, forSegment: index)
        }
    }
    
    /// The image of the segment.
    public var image: NSImage? {
        didSet {
            guard let index = index else { return }
            segmentedControl?.setImage(image, forSegment: index)
        }
    }
    
    /// The image scaling of the segment.
    public var imageScaling: NSImageScaling = .scaleProportionallyDown {
        didSet {
            guard let index = index else { return }
            segmentedControl?.setImageScaling(imageScaling, forSegment: index)
        }
    }
    
    /// The menu of the segment.
    public var menu: NSMenu? {
        didSet {
            guard let index = index else { return }
            segmentedControl?.setMenu(menu, forSegment: index)
        }
    }
    
    /// A Boolean value indicating whether the segment shows a menu indicator.
    public var showsMenuIndicator: Bool = false {
        didSet {
            guard let index = index else { return }
            segmentedControl?.setShowsMenuIndicator(showsMenuIndicator, forSegment: index)
        }
    }
    
    /// A Boolean value indicating whether the segment is selected.
    public var isSelected: Bool = false {
        didSet {
            guard let index = index else { return }
            segmentedControl?.setSelected(isSelected, forSegment: index)
        }
    }
    
    /// A Boolean value indicating whether the segment is enabled.
    public var isEnabled: Bool = true {
        didSet {
            guard let index = index else { return }
            segmentedControl?.setEnabled(isEnabled, forSegment: index)
            toolbarItem?.groupItem.subitems[safe: index]?.isEnabled = isEnabled
        }
    }
    
    /**
     The width of the segment.
     
     The default value is `0`, which indicates that the segment is sized automatically to fit the available space.
     */
    public var width: CGFloat = 0 {
        didSet {
            width = width.clamped(min: 0)
            guard let index = index else { return }
            segmentedControl?.setWidth(width, forSegment: index)
        }
    }
    
    /// The tooltip of the segment.
    public var toolTip: String? {
        didSet {
            guard let index = index else { return }
            segmentedControl?.setToolTip(toolTip, forSegment: index)
        }
    }
    
    /// The font of the segment.
    var font: NSFont = .system {
        didSet {
            guard let index = index else { return }
            segmentedControl?.setFont(font, forSegment: index)
        }
    }
    
    /// The tag of the segment.
    public var tag: Int = 0 {
        didSet {
            guard let index = index else { return }
            segmentedControl?.setTag(tag, forSegment: index)
        }
    }
    
    /// Sets the title of the segment.
    @discardableResult
    public func title(_ title: String?) -> Self {
        self.title = title
        return self
    }
    
    /// Sets the title alignment of the segment.
    @discardableResult
    public func titleAlignment(_ titleAlignment: NSTextAlignment) -> Self {
        self.titleAlignment = titleAlignment
        return self
    }
    
    /// Sets the image of the segment.
    @discardableResult
    public func image(_ image: NSImage?) -> Self {
        self.image = image
        return self
    }
    
    /// Sets the symbol image of the segment.
    @available(macOS 11.0, *)
    public func symbolImage(_ symbolName: String?) -> Self {
        if let symbolName = symbolName {
            return image(.symbol(symbolName))
        } else {
            return image(nil)
        }
    }
    
    /// Sets the image scaling of the segment.
    @discardableResult
    public func imageScaling(_ imageScaling: NSImageScaling) -> Self {
        self.imageScaling = imageScaling
        return self
    }
    
    /// Sets the menu of the segment.
    @discardableResult
    public func menu(_ menu: NSMenu?) -> Self {
        self.menu = menu
        return self
    }
    
    /// Sets the menu of the segment with the specified menu items.
    @discardableResult
    public func menu(@MenuBuilder _ items: () -> [NSMenuItem]) -> Self {
        self.menu = NSMenu(items)
        return self
    }
    
    /// Sets the Boolean value indicating whether the menu indicator is shown.
    @discardableResult
    public func showsMenuIndicator(_ shows: Bool) -> Self {
        showsMenuIndicator = shows
        return self
    }
    
    /// Sets the Boolean value indicating whether the segment is selected.
    @discardableResult
    public func isSelected(_ isSelected: Bool) -> Self {
        self.isSelected = isSelected
        return self
    }
    
    /// Sets the Boolean value indicating whether the segment is enabled.
    @discardableResult
    public func isEnabled(_ isEnabled: Bool) -> Self {
        self.isEnabled = isEnabled
        return self
    }
    
    /**
     Sets the width of the segment.
     
     A value of `0` indicates that the segment is sized automatically to fit the available space.
     */
    @discardableResult
    public func width(_ width: CGFloat) -> Self {
        self.width = width
        return self
    }
    
    /// Sets the tooltip of the segment.
    @discardableResult
    public func toolTip(_ toolTip: String?) -> Self {
        self.toolTip = toolTip
        return self
    }
    
    /// Sets the font of the segment.
    @discardableResult
    func font(_ font: NSFont) -> Self {
        self.font = font
        return self
    }
    
    /// Sets the tag of the segment.
    @discardableResult
    public func tag(_ tag: Int) -> Self {
        self.tag = tag
        return self
    }
    
    /// The index of the segment, or `nil` if the segment isn't displayed in any segmented control.
    public internal(set) var index: Int? = nil
    
    /// A Boolean value indicating whether the segment is the last selected segment.
    public var isLastSelected: Bool {
        segmentedControl?.selectedSegment ?? -2 == index
    }
    
    /**
     Creates a new segment with the specified title.
     
     - Parameter title: The title of the segment.
     */
    public init(_ title: String) {
        self.title = title
    }
    
    /**
     Creates a new segment with the specified image.
     
     - Parameter image: The image of the segment.
     */
    public init(_ image: NSImage) {
        self.image = image
    }
    
    /**
     Creates a new segment with the specified system symbol name.
     
     - Parameter symbolName: The name of the system symbol image.
     
     - Returns: A `NSSegmentedControl.Segment` object with a symbol image,  or `nil` if no image with the specified symbol name could be found.
     */
    @available(macOS 11.0, *)
    public init?(symbolName: String) {
        guard let image = NSImage(systemSymbolName: symbolName) else {
            return nil
        }
        self.image = image
    }
    
    /**
     Creates a new segment with the specified title and image.
     
     - Parameters:
        - title: The title of the segment.
        - image: The image of the segment.
     */
    public init(title: String, image: NSImage) {
        self.title = title
        self.image = image
    }
    
    /**
     Creates a new segment with the specified title.
     
     - Parameter value: The title of the segment.
     */
    public required init(stringLiteral value: String) {
        title = value
    }
    
    init(segmentedControl: NSSegmentedControl, index: Int) {
        self.title = segmentedControl.label(forSegment: index)
        self.titleAlignment = segmentedControl.alignment(forSegment: index)
        self.image = segmentedControl.image(forSegment: index)
        self.imageScaling = segmentedControl.imageScaling(forSegment: index)
        self.menu = segmentedControl.menu(forSegment: index)
        self.showsMenuIndicator = segmentedControl.showsMenuIndicator(forSegment: index)
        self.isSelected = segmentedControl.isSelected(forSegment: index)
        self.isEnabled = segmentedControl.isEnabled(forSegment: index)
        self.width = segmentedControl.width(forSegment: index)
        self.toolTip = segmentedControl.toolTip(forSegment: index)
        self.tag = segmentedControl.tag(forSegment: index)
        self.font = segmentedControl.font(forSegment: index) ?? segmentedControl.font ?? .system
        self.index = index
        self.segmentedControl = segmentedControl
        self.toolbarItem = segmentedControl.toolbarItem
    }
}

public extension NSSegmentedControl {
    /**
     Creates a segmented control with the specified segments.
     
     - Parameters:
        - switching: The tracking behavior of the segmented control.
        - style: The visual style of the segmented control.
        - segments: The segments of the segmented control.
     */
    convenience init(switching: SwitchTracking = .selectOne, style: Style = .automatic, segments: [NSSegment]) {
            self.init(frame: .zero)
            segmentStyle = style
            trackingMode = switching
            self.segments = segments
            sizeToFit()
        }
    
    /**
     Creates a segmented control with the specified segments.
     
     - Parameters:
        - switching: The tracking behavior of the segmented control.
        - style: The visual style of the segmented control.
        - segments: The segments of the segmented control.
     */
    convenience init(switching: SwitchTracking = .selectOne, style: Style = .automatic, @Builder segments: () -> [NSSegment]) {
        self.init(switching: switching, style: style, segments: segments())
    }
    
    /**
     The selected segments.
     
     To get the last selected segment, check the selected segment where ``NSSegment/isLastSelected`` is `true`.
     */
    var selectedSegments: [NSSegment] {
        indexesOfSelectedSegments.compactMap { segment(at: $0) }
    }
    
    /// The segments displayed by the segmented control.
    @objc dynamic var segments: [NSSegment] {
        get { (0..<segmentCount).compactMap { segment(at: $0) } }
        set {
            segmentCount = newValue.count
            for (index, segment) in newValue.enumerated() {
                setSegment(segment, for: index)
            }
        }
    }
    
    /// Sets the segments displayed by the segmented control.
    @discardableResult
    func segments(@Builder segments: () -> [NSSegment]) -> Self {
        self.segments = segments()
        return self
    }
    
    /// Returns the segment that matches the title.
    func segment(withTitle title: String) -> NSSegment? {
        segments.first(where: { $0.title == title })
    }
    
    /// Returns the segment at the specified index.
    func segment(at index: Int) -> NSSegment? {
        guard index < segmentCount else { return nil }
        return NSSegment(segmentedControl: self, index: index)
    }
    
    /**
     Applies the values to the segment at the specified index.
     
     - Parameters:
        - segment: The segment
        - index: The index of the segment
     */
    func setSegment(_ segment: NSSegment, for index: Int) {
        guard index < segmentCount else { return }
        segment.segmentedControl = self
        segment.index = index
        setLabel(segment.title ?? "", forSegment: index)
        setAlignment(segment.titleAlignment, forSegment: index)
        setImage(segment.image, forSegment: index)
        setImageScaling(segment.imageScaling, forSegment: index)
        setMenu(segment.menu, forSegment: index)
        setShowsMenuIndicator(segment.showsMenuIndicator, forSegment: index)
        setSelected(segment.isSelected, forSegment: index)
        setEnabled(segment.isEnabled, forSegment: index)
        setFont(segment.font, forSegment: index)
        setWidth(segment.width, forSegment: index)
        setToolTip(segment.toolTip, forSegment: index)
        setTag(segment.tag, forSegment: index)
    }
    
    internal func segment(withTag tag: Int) -> NSSegment? {
        segments.first(where: { $0.tag == tag })
    }
    
    internal func index(forTag tag: Int) -> Int? {
        (0 ..< segmentCount).first(where: { self.tag(forSegment: $0) == tag })
    }
    
    internal var toolbarItem: Toolbar.SegmentedControl? {
        get { getAssociatedValue("toolbarItem") }
        set { setAssociatedValue(weak: newValue, key: "toolbarItem")}
    }
    
    /// A function builder type that produces an array of segments.
    @resultBuilder
    enum Builder {
        public static func buildBlock(_ block: [NSSegment]...) -> [NSSegment] {
            block.flatMap { $0 }
        }
        
        public static func buildOptional(_ item: NSSegment?) -> [NSSegment] {
            item != nil ? [item!] : []
        }
        
        public static func buildEither(first: [NSSegment]) -> [NSSegment] {
            first
        }
        
        public static func buildEither(second: [NSSegment]) -> [NSSegment] {
            second
        }
        
        public static func buildArray(_ components: [[NSSegment]]) -> [NSSegment] {
            components.flatMap { $0 }
        }
        
        public static func buildExpression(_ expr: NSSegment?) -> [NSSegment] {
            expr.map { [$0] } ?? []
        }
        
        public static func buildExpression(_ expr: NSImage) -> [NSSegment] {
            [NSSegment(expr)]
        }
        
        public static func buildExpression(_ expr: [NSImage]) -> [NSSegment] {
            expr.map { NSSegment($0) }
        }
        
        public static func buildExpression(_ expr: String) -> [NSSegment] {
            [NSSegment(expr)]
        }
        
        public static func buildExpression(_ expr: [String]) -> [NSSegment] {
            expr.map { NSSegment($0) }
        }
    }
}
#endif
