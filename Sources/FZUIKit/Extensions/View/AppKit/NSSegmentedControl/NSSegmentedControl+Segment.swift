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
        var tag: Int = UUID().hashValue

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

         Specify the value 0 if you want the segment to be sized to fit the available space automatically.
         */
        public var width: CGFloat = 0 {
            //    willSet { self.index = self.index }
            didSet { if let index = index {
                segmentedControl?.setWidth(width, forSegment: index)
            } }
        }

        /// The tooltip of the segment.
        public var toolTip: String? {
            //     willSet { self.index = self.index }
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

        /// Sets the title for the segment.
        public func title(_ value: String?) -> Self {
            title = value
            return self
        }

        /// Sets the title alignment for the segment.
        public func titleAlignment(_ value: NSTextAlignment) -> Self {
            titleAlignment = value
            return self
        }

        /// Sets the image for the segment.
        public func image(_ value: NSImage?) -> Self {
            image = value
            return self
        }

        /// Sets the image scaling for the segment.
        public func imageScaling(_ value: NSImageScaling) -> Self {
            imageScaling = value
            return self
        }

        /// Sets the menu for the segment.
        public func menu(_ value: NSMenu?) -> Self {
            menu = value
            return self
        }

        /// Sets whether the menu indicator is shown.
        public func showsMenuIndicator(_ value: Bool) -> Self {
            showsMenuIndicator = value
            return self
        }

        /// Sets whether the segment is selected.
        public func isSelected(_ value: Bool) -> Self {
            isSelected = value
            return self
        }

        /// Sets whether the segment is enabled.
        public func isEnabled(_ value: Bool) -> Self {
            isEnabled = value
            return self
        }

        /**
         Sets the width of the segment.

         Specify the value 0 if you want the segment to be sized to fit the available space automatically.
         */
        public func width(_ value: CGFloat) -> Self {
            width = value
            return self
        }

        /// Sets the tooltip for the segment.
        public func toolTip(_ value: String?) -> Self {
            toolTip = value
            return self
        }
        
        /// Sets the font for the segment.
        public func font(_ font: NSFont) -> Self {
            self.font = font
            return self
        }
        
        /// Sets the tag of the segment.
        public func tag(_ tag: Int) -> Self {
            self.tag = tag
            return self
        }

        /// The index of the segment, or `nil` if the segment isn't displayed in any segmented control.
        public var index: Int? {
            segmentedControl?.index(forTag: tag) ?? nil
        }

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

         - Parameters:
         - systemSymbolName: The name of the system symbol image.

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
            image = nil
        }

        init(title: String?, titleAlignment: NSTextAlignment = .left, image: NSImage?, imageScaling: NSImageScaling = .scaleProportionallyDown, menu: NSMenu? = nil, showsMenuIndicator: Bool = false, isSelected: Bool, isEnabled: Bool = true, width: CGFloat = .zero, toolTip: String? = nil, tag: Int? = nil, font: NSFont? = nil, segmentedControl: NSSegmentedControl? = nil) {
            self.title = title
            self.titleAlignment = titleAlignment
            self.image = image
            self.imageScaling = imageScaling
            self.menu = menu
            self.showsMenuIndicator = showsMenuIndicator
            self.isSelected = isSelected
            self.isEnabled = isEnabled
            self.width = width
            self.toolTip = toolTip
            self.tag = tag ?? UUID().hashValue
            self.segmentedControl = segmentedControl
            self.font = font ?? .systemFont
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

        /// Returns all segments that are selected.
        var selectedSegments: [NSSegment] {
            indexesOfSelectedItems.compactMap { segment(at: $0) }
        }

        /// Returns all segments displayed by the segmented control.
        var segments: [NSSegment] {
            get {
                let count = segmentCount - 1
                var segments: [NSSegment] = []
                for index in 0 ... count {
                    if let segment = segment(at: index) {
                        segments.append(segment)
                    }
                }
                return segments
            }
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
            let title = label(forSegment: index)
            let titleAlignment = alignment(forSegment: index)
            let image = image(forSegment: index)
            let imageScaling = imageScaling(forSegment: index)
            let menu = menu(forSegment: index)
            let showsMenuIndicator = showsMenuIndicator(forSegment: index)
            let isSelected = isSelected(forSegment: index)
            let isEnabled = isEnabled(forSegment: index)
            let width = width(forSegment: index)
            let toolTip = toolTip(forSegment: index)
            let tag = tag(forSegment: index)
            let font = font(forSegment: index)
            return NSSegment(title: title, titleAlignment: titleAlignment, image: image, imageScaling: imageScaling, menu: menu, showsMenuIndicator: showsMenuIndicator, isSelected: isSelected, isEnabled: isEnabled, width: width, toolTip: toolTip, tag: tag, font: font, segmentedControl: self)
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
        
        internal var segmentViews: [NSView] {
            subviews.filter({ NSStringFromClass(type(of: $0)) == "NSSegmentItemView" })
        }

        internal var indexesOfSelectedItems: [Int] {
            (0 ..< segmentCount).filter { self.isSelected(forSegment: $0) }
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
