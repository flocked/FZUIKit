//
//  NSSegmentedControl+Segment.swift
//
//
//  Created by Florian Zand on 18.08.22.
//

#if os(macOS)

    import AppKit

    /// A segment of a NSSegmentedControll.
    public class NSSegment: ExpressibleByStringLiteral {
        weak var segmentedControl: NSSegmentedControl?

        /// The title of the segment.
        public var title: String? {
            didSet { if let index = index {
                segmentedControl?.setLabel(title ?? "", forSegment: index)
            } }
        }

        /// The title alignemnt of the segment.
        public var titleAlignment: NSTextAlignment = .center {
            didSet { if let index = index {
                segmentedControl?.setAlignment(titleAlignment, forSegment: index)
            } }
        }

        /// The image of the segment.
        public var image: NSImage? {
            didSet { if let index = index {
                segmentedControl?.setImage(image, forSegment: index)
            } }
        }

        /// The image scaling of the segment.
        public var imageScaling: NSImageScaling = .scaleProportionallyDown {
            didSet { if let index = index {
                segmentedControl?.setImageScaling(imageScaling, forSegment: index)
            } }
        }

        /// The menu of the segment.
        public var menu: NSMenu? {
            didSet { if let index = index {
                segmentedControl?.setMenu(menu, forSegment: index)
            } }
        }

        /// A Boolean value that indicates whether the segment shows a menu indicator.
        public var showsMenuIndicator: Bool = false {
            didSet { if let index = index {
                segmentedControl?.setShowsMenuIndicator(showsMenuIndicator, forSegment: index)
            } }
        }

        /// A Boolean value that indicates whether the segment is selected.
        public var isSelected: Bool = false {
            didSet { if let index = index {
                segmentedControl?.setSelected(isSelected, forSegment: index)
            } }
        }

        /// A Boolean value that indicates whether the segment is enabled.
        public var isEnabled: Bool = true {
            didSet { if let index = index {
                segmentedControl?.setEnabled(isEnabled, forSegment: index)
            } }
        }

        /**
         The width of the segment.

         A value of `0` indicates that the segments is sized to fit the available space automatically.
         */
        public var width: CGFloat = 0 {
            didSet { if let index = index {
                segmentedControl?.setWidth(width, forSegment: index)
            } }
        }

        /// The tooltip of the segment.
        public var toolTip: String? {
            didSet { if let index = index {
                segmentedControl?.setToolTip(toolTip, forSegment: index)
            } }
        }
        
        /// The font of the segment.
        public var font: NSFont = .systemFont {
            didSet { if let index = index {
                segmentedControl?.setFont(font, forSegment: index)
            } }
        }
        
        /// The tag of the segment.
        public var tag: Int = 0 {
            didSet { if let index = index {
                segmentedControl?.setTag(tag, forSegment: index)
            } }
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

        /// Sets the Boolean value that indicates whether the menu indicator is shown.
        @discardableResult
        public func showsMenuIndicator(_ shows: Bool) -> Self {
            showsMenuIndicator = shows
            return self
        }

        /// Sets the Boolean value that indicates whether the segment is selected.
        @discardableResult
        public func isSelected(_ isSelected: Bool) -> Self {
            self.isSelected = isSelected
            return self
        }

        /// Sets the Boolean value that indicates whether the segment is enabled.
        @discardableResult
        public func isEnabled(_ isEnabled: Bool) -> Self {
            self.isEnabled = isEnabled
            return self
        }

        /**
         Sets the width of the segment.
         
         A value of `0` indicates that the segments is sized to fit the available space automatically.
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
        public func font(_ font: NSFont) -> Self {
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

        /// A Boolean value that indicates whether the segment is the last selected segment.
        public var isLastSelected: Bool {
            segmentedControl?.selectedSegment ?? -2 == index
        }

        /**
         Creates a new segment with the specified title.

         - Parameters:
         - title: The title of the segment.

         - Returns: A `NSSegmentedControl.Segment` object.
         */
        public init(_ title: String) {
            self.title = title
            image = nil
        }

        /**
         Creates a new segment with the specified image.

         - Parameters:
         - image: The image of the segment.

         - Returns: A `NSSegmentedControl.Segment` object.
         */
        public init(_ image: NSImage) {
            title = nil
            self.image = image
        }

        @available(macOS 11.0, *)
        /**
         Creates a new segment with the specified system symbol name.

         - Parameter symbolName: The name of the system symbol image.

         - Returns: A `NSSegmentedControl.Segment` object with a image based on the name you specify,  otherwise `nil` if the method couldn’t find a suitable image with the system symbol name.
         */
        public init?(symbolName: String) {
            guard let image = NSImage(systemSymbolName: symbolName) else {
                return nil
            }
            title = nil
            self.image = image
        }

        /**
         Creates a new segment with the specified title and image.

         - Parameters:
         - title: The title of the segment.
         - image: The image of the segment.

         - Returns: A `NSSegmentedControl.Segment` object.
         */
        public init(title: String, image: NSImage) {
            self.title = title
            self.image = image
        }

        /**
         Creates a new segment with the specified title.

         - Parameters:
         - stringLiteral: The title of the segment.

         - Returns: A `NSSegmentedControl.Segment` object.
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
            self.font = segmentedControl.font(forSegment: index) ?? segmentedControl.font ?? .systemFont
            self.index = index
            self.segmentedControl = segmentedControl
        }
    }

    public extension NSSegmentedControl {
        /**
         Creates a segmented control with the specified segments.

         - Parameters:
         - switching: The tracking behavior of the segmented control.
         - style: The visual style of the segmented control.
         - segments: An array of segments.

         - Returns: An initialized `NSSegmentedControl` object.
         */
        convenience init(
            switching: NSSegmentedControl.SwitchTracking = .selectOne,
            style: NSSegmentedControl.Style = .automatic,
            segments: [NSSegment]
        ) {
            self.init(frame: .zero)
            segmentStyle = style
            trackingMode = switching
            self.segments = segments
        }

        /**
         Creates a segmented control with the specified segments.

         - Parameters:
         - switching: The tracking behavior of the segmented control.
         - style: The visual style of the segmented control.
         - segments: The segments.

         - Returns: An initialized `NSSegmentedControl` object.
         */
        convenience init(
            switching: NSSegmentedControl.SwitchTracking = .selectOne,
            style: NSSegmentedControl.Style = .automatic,
            @Builder segments: () -> [NSSegment]
        ) {
            self.init(frame: .zero)
            segmentStyle = style
            trackingMode = switching
            self.segments = segments()
        }

        /**
         The selected segments.
         
         To get the last selected segment, check the selected segment where ``NSSegment/isLastSelected`` is `true`.
         */
        var selectedSegments: [NSSegment] {
            indexesOfSelectedSegments.compactMap { segment(at: $0) }
        }

        /// The segments displayed by the segmented control.
        var segments: [NSSegment] {
            get { (0..<segmentCount).compactMap {segment(at: $0)} }
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
            if segment.width != .zero {
                setWidth(segment.width, forSegment: index)
            }
            setToolTip(segment.toolTip, forSegment: index)
            setTag(segment.tag, forSegment: index)
        }
        
        /**
         Returns the font of the specified segment.

         - Parameter segment:The index of the segment whose font you want to get.
         */
        func font(forSegment segment: Int) -> NSFont? {
            segmentViews[safe: segment]?.value(forKey: "font") as? NSFont
        }
        
        /**
         Sets the font for the specified segment.
         
         - Parameters:
            - font: The label for the segment.
            - index: The index of the segment whose label you want to set.
         */
        func setFont(_ font: NSFont, forSegment segment: Int) {
            segmentViews[safe: segment]?.setValue(font, forKey: "font")
        }
        
        /// The indexes of the selected segments.
        var indexesOfSelectedSegments: [Int] {
            (0..<segmentCount).filter { isSelected(forSegment: $0) }
        }
        
        internal var segmentViews: [NSView] {
            subviews.filter({ NSStringFromClass(type(of: $0)) == "NSSegmentItemView" })
        }

        internal func segment(withTag tag: Int) -> NSSegment? {
            segments.first(where: { $0.tag == tag })
        }

        internal func index(forTag tag: Int) -> Int? {
            var count = 0
            for i in 0 ..< segmentCount {
                if tag == self.tag(forSegment: i) {
                    return count
                }
                count += 1
            }
            return nil
        }
    }
#endif
