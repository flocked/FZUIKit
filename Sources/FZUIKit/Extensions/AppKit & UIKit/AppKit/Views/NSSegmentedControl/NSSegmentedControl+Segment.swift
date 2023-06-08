//
//  NSSegmentedControl+.swift
//  FZExtensions
//
//  Created by Florian Zand on 18.08.22.
//

#if os(macOS)

import AppKit

public extension NSUISegmentedControl {
    /// A segment of a NSSegmentedControll.
    class Segment: ExpressibleByStringLiteral {
        internal weak var segmentedControl: NSSegmentedControl? = nil
        internal var tag: Int = UUID().hashValue

        /// The title of the segment.
        public var title: String? {
            didSet { if let index = index {
                segmentedControl?.setLabel(title ?? "", forSegment: index)
            } }
        }

        /// The title alignemnt of the segment.
        public var titleAlignment: NSTextAlignment = .left {
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
        public var menu: NSMenu? = nil {
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
        public var toolTip: String? = nil {
            //     willSet { self.index = self.index }
            didSet { if let index = index {
                segmentedControl?.setToolTip(toolTip, forSegment: index)
            } }
        }

        /// The title alignemnt of the segment.
        public var contentOffset: CGSize = .zero {
            didSet { if let index = index {
                segmentedControl?.setAlignment(titleAlignment, forSegment: index)
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

        /**
         The index of the segment.

         Returns nil if the segment isn't displayed in any NSSegmentedControl.
         */
        public var index: Int? {
            segmentedControl?.index(forTag: tag) ?? nil
        }

        /// A Boolean value that indicates whether the segment is the last selected segment.
        public var isLastSelected: Bool {
            return segmentedControl?.selectedSegment ?? -2 == index
        }

        /*
         public func tag(_ value: Int) -> Self {
             self.tag = value
             return self
         }
          */

        /**
         Creates a new segment with the specified title.

         - Parameters:
            - title: The title of the segment.

         - Returns: A NSSegmentedControl.Segment object.
         */
        public init(_ title: String, isSelected: Bool = false) {
            self.title = title
            self.isSelected = isSelected
            self.image = nil
        }

        /**
         Creates a new segment with the specified title.

         - Parameters:
            - title: The title of the segment.

         - Returns: A NSSegmentedControl.Segment object.
         */
        public init(title: String, isSelected: Bool = false) {
            self.title = title
            self.image = nil
            self.isSelected = isSelected
        }

        /**
         Creates a new segment with the specified title.

         - Parameters:
            - image: The image of the segment.

         - Returns: A NSSegmentedControl.Segment object.
         */
        public init(image: NSImage, isSelected: Bool = false) {
            self.title = nil
            self.image = image
            self.isSelected = isSelected
        }

        /**
         Creates a new segment with the specified image.

         - Parameters:
            - image: The image of the segment.

         - Returns: A NSSegmentedControl.Segment object.
         */
        public init(_ image: NSImage, isSelected: Bool = false) {
            self.title = nil
            self.image = image
            self.isSelected = isSelected
        }

        @available(macOS 11.0, *)
        /**
         Creates a new segment with the specified system symbol name.

         - Parameters:
            - systemSymbolName: The name of the system symbol image.

         - Returns: A NSSegmentedControl.Segment object with a image based on the name you specify,  otherwise nil if the method couldn’t find a suitable image with the system symbol name.
         */
        public init?(symbolName: String, isSelected: Bool = false) {
            guard let image = NSImage(systemSymbolName: symbolName) else {
                return nil
            }
            self.title = nil
            self.image = image
            self.isSelected = isSelected
        }

        /**
         Creates a new segment with the specified title and image.

         - Parameters:
            - title: The title of the segment.
            - image: The image of the segment.

         - Returns: A NSSegmentedControl.Segment object.
         */
        public init(title: String, image: NSImage, isSelected: Bool = false) {
            self.title = title
            self.image = image
            self.isSelected = isSelected
        }

        /**
         Creates a new segment with the specified title.

         - Parameters:
            - stringLiteral: The title of the segment.

         - Returns: A NSSegmentedControl.Segment object.
         */
        public required init(stringLiteral value: String) {
            self.title = value
            self.image = nil
        }

        internal init(title: String?, titleAlignment: NSTextAlignment = .left, image: NSImage?, imageScaling: NSImageScaling = .scaleProportionallyDown, menu: NSMenu? = nil, showsMenuIndicator: Bool = false, isSelected: Bool, isEnabled: Bool = true, width: CGFloat = .zero, toolTip: String? = nil, tag: Int? = nil, segmentedControl: NSSegmentedControl? = nil) {
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
        }
    }
}

public extension NSSegmentedControl {
    /**
     Creates a segmented control with segments.

     - Parameters:
        - segments: An array of NSSegmentedControl.Segment objects.
        - switching: The type of tracking behavior the control exhibits.
        - style: The visual style used to display the control.

     - Returns: A NSSegmentedControl object.
     */
    convenience init(segments: [Segment], switching: NSSegmentedControl.SwitchTracking = .selectOne, style: NSSegmentedControl.Style = .automatic) {
        self.init(frame: .zero)
        segmentStyle = style
        trackingMode = switching
        self.segments = segments
    }

    /**
     Creates a segmented control with segments.

     - Parameters:
        -  frame: The frame rectangle for the view, measured in points.
        - segments: An array of NSSegmentedControl.Segment objects.
        - switching: The type of tracking behavior the control exhibits.
        - style: The visual style used to display the control.

     - Returns: A NSSegmentedControl object.
     */
    convenience init(frame: CGRect, segments: [Segment], switching: NSSegmentedControl.SwitchTracking = .selectOne, style: NSSegmentedControl.Style = .automatic) {
        self.init(frame: frame)
        segmentStyle = style
        trackingMode = switching
        self.segments = segments
    }

    /// Returns all segments displayed by the segmented control.
    var segments: [Segment] {
        get {
            let count = segmentCount - 1
            var segments: [Segment] = []
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

    /// Returns the segment that matches the title.
    func segment(withTitle title: String) -> Segment? {
        segments.first(where: { $0.title == title })
    }

    /// Returns the segment at the specified index.
    func segment(at index: Int) -> Segment? {
        guard index < segmentCount else { return nil }
        let title = label(forSegment: index)
        let titleAlignment = alignment(forSegment: index)
        let image = self.image(forSegment: index)
        let imageScaling = self.imageScaling(forSegment: index)
        let menu = self.menu(forSegment: index)
        let showsMenuIndicator = self.showsMenuIndicator(forSegment: index)
        let isSelected = self.isSelected(forSegment: index)
        let isEnabled = self.isEnabled(forSegment: index)
        let width = self.width(forSegment: index)
        let toolTip = self.toolTip(forSegment: index)
        let tag = self.tag(forSegment: index)
        return Segment(title: title, titleAlignment: titleAlignment, image: image, imageScaling: imageScaling, menu: menu, showsMenuIndicator: showsMenuIndicator, isSelected: isSelected, isEnabled: isEnabled, width: width, toolTip: toolTip, tag: tag, segmentedControl: self)
    }

    /**
     Applies the values to the segment at the specified index.

     - Parameters:
        - segment: The segment
        - index: The index of the segment
     */
    func setSegment(_ segment: Segment, for index: Int) {
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
        if segment.width != .zero {
            setWidth(segment.width, forSegment: index)
        }
        setToolTip(segment.toolTip, forSegment: index)
        setTag(segment.tag, forSegment: index)
    }

    internal func segment(withTag tag: Int) -> Segment? {
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
