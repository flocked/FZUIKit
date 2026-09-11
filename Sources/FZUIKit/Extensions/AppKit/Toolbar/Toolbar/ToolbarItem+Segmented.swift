//
//  ToolbarItem+Segmented.swift
//
//
//  Created by Florian Zand on 09.04.23.
//

#if os(macOS)
import AppKit
import FZSwiftUtils

extension Toolbar {
    /// A toolbar item that contains a segmented control.
    open class SegmentedControl: ToolbarItem {
        /// The segmented control of the toolbar item.
        public let segmentedControl: NSSegmentedControl
        
        /// The segments of the segmented control.
        open var segments: [NSSegment] {
            get { segmentedControl.segments }
            set {
                segmentedControl.segments = newValue
                segmentedControl.sizeToFit()
            }
        }
        
        /**
         The selected segments.
         
         To get the last selected segment, check the selected segment where ``NSSegment/isLastSelected`` is `true.`
         */
        open var selectedSegments: [NSSegment] {
            segmentedControl.selectedSegments
        }
        
        /// Sets the segments of the segmented control.
        @discardableResult
        open func segments(_ segments: [NSSegment]) -> Self {
            self.segments = segments
            return self
        }
        
        /// Sets the segments of the segmented control.
        @discardableResult
        open func segments(@NSSegmentedControl.Builder segments: () -> [NSSegment]) -> Self {
            self.segments = segments()
            return self
        }
        
        /// The selection mode of the segmented control.
        open var selectionMode: SelectionMode {
            get { .init(rawValue: segmentedControl.trackingMode.rawValue) ?? .selectOne }
            set { segmentedControl.trackingMode = .init(rawValue: newValue.rawValue) ?? .selectOne }
        }
        
        /// Sets the selection mode of the segmented control.
        @discardableResult
        open func selectionMode(_ mode: SelectionMode) -> Self {
            selectionMode = mode
            return self
        }
        
        /// The selection mode of a segmented control.
        public enum SelectionMode: UInt, Hashable, Codable {
            /// Only one segment can be selected at a time.
            case selectOne
            /// One or more segments can be selected at a time.
            case selectAny
            /// A segment is selected only when the user is pressing the mouse down. When the mouse is no longer down within the segment, the segment is automatically deselected.
            case momentary
            
            var groupSelectionMode: NSToolbarItemGroup.SelectionMode {
                switch self {
                case .selectOne: .selectOne
                case .selectAny: .selectAny
                case .momentary: .momentary
                }
            }
        }
        
        /// A Boolean value indicating whether the segmented control is bezeled.
        open var isBezeled: Bool {
            get { segmentedControl.segmentStyle != .roundRect }
            set { segmentedControl.segmentStyle = newValue ? .roundRect : .automatic }
        }
        
        /// Sets the Boolean value indicating whether the segmented control is bezeled.
        @discardableResult
        open func isBezeled(_ isBezeled: Bool) -> Self {
            self.isBezeled = isBezeled
            return self
        }
        
        /**
         Creates a segmented control toolbar item.
         
         - Note: The identifier is used for autosaving the item. When you don't specifiy an identifier an automatic identifier is used. It is recommended to specifiy an identifier, if you have multiple `Segmented` toolbar items.
         
         - Parameters:
            - identifier: The item identifier.
            - selectionMode: The segmented control selection mode.
            - segments: The segments of the segmented control.
         */
        public init(_ identifier: NSToolbarItem.Identifier? = nil, selectionMode: SelectionMode = .selectOne, @NSSegmentedControl.Builder segments: () -> [NSSegment]) {
            self.segmentedControl = NSSegmentedControl()
            super.init(identifier)
            sharedInit()
            self.selectionMode = selectionMode
            self.segments = segments()
        }
        
        /**
         Creates a segmented control toolbar item.
         
         - Note: The identifier is used for autosaving the item. When you don't specifiy an identifier an automatic identifier is used. It is recommended to specifiy an identifier, if you have multiple `Segmented` toolbar items.
         
         - Parameters:
            - identifier: The item identifier.
            - segmentedControl: The segmented control of the item.
         */
        public init(_ identifier: NSToolbarItem.Identifier? = nil, segmentedControl: NSSegmentedControl) {
            self.segmentedControl = segmentedControl
            super.init(identifier)
            sharedInit()
        }
        
        private func sharedInit() {
            item.view = segmentedControl
            segmentedControl.toolbarItem = item as? NSToolbarItemGroup
            segmentedControl.translatesAutoresizingMaskIntoConstraints = false
            segmentedControl.setContentHuggingPriority(.defaultHigh, for: .horizontal)
            segmentedControl.segmentDistribution = .fillEqually
        }
    }
}

extension Toolbar {
    open class LabeledSegmentedControl: SegmentedControl {
        lazy var groupItem = ValidateToolbarItemGroup(for: self)
        
        override var item: NSToolbarItem {
            groupItem
        }
    }
}


extension Toolbar.SegmentedControl {
    /// A toolbar item that displays a segmented control with individual labels below each segment.
    open class Labeled: ToolbarItem {
        lazy var groupItem = ValidateToolbarItemGroup(for: self)
        
        override var item: NSToolbarItem {
            groupItem
        }
        
        private let segmentedControl = NSSegmentedControl()
        
        /// The segments of the toolbar item.
        open var segments: [Segment] {
            didSet {
                for segment in segments {
                    if let toolbarItem = segment.toolbarItem, toolbarItem !== self {
                        toolbarItem.removeSegment(segment)
                    }
                }
                oldValue.filter { oldSegment in
                    !segments.contains { $0 === oldSegment }
                }.forEach { segment in
                    segment.toolbarItem = nil
                }
                segments.forEach { $0.toolbarItem = self }
                updateSegments()
            }
        }
        
        /// The selected segments.
        open var selectedSegments: [Segment] {
            selectedIndexes.compactMap { segments[safe: $0] }
        }
        
        /// The index values of the selected segments.
        open var selectedIndexes: [Int] {
            get { segmentedControl.indexesOfSelectedSegments }
            set {
                for index in 0..<segments.count {
                    let isSelected = newValue.contains(index)
                    segments[index].isSelected = isSelected
                    segmentedControl.setSelected(isSelected, forSegment: index)
                    groupItem.setSelected(isSelected, at: index)
                }
            }
        }
        
        /// The index of the most recently selected segment.
        open var lastSelectedIndex: Int? {
            segmentedControl.selectedSegment >= 0 && segmentedControl.selectedSegment < segments.count ? segmentedControl.selectedSegment : nil
        }
        
        /// The most recently selected segment.
        open var lastSelectedSegment: Segment? {
            segments[safe: lastSelectedIndex ?? -1]
        }
        
        /// The selection mode of the segmented control.
        open var selectionMode: SelectionMode {
            get { .init(rawValue: segmentedControl.trackingMode.rawValue) ?? .selectOne }
            set {
                segmentedControl.trackingMode = .init(rawValue: newValue.rawValue) ?? .selectOne
                groupItem.selectionMode = newValue.groupSelectionMode
            }
        }
        
        /// Sets the segments of the toolbar item.
        @discardableResult
        open func segments(_ segments: [Segment]) -> Self {
            self.segments = segments
            return self
        }
        
        /// Sets the segments of the toolbar item.
        @discardableResult
        open func segments(@Builder segments: () -> [Segment]) -> Self {
            self.segments = segments()
            return self
        }
        
        /// Returns the segment that matches the title.
        open func segment(withTitle title: String) -> Segment? {
            segments.first { $0.title == title }
        }
        
        /// Returns the segment that matches the tag.
        open func segment(withTag tag: Int) -> Segment? {
            segments.first { $0.tag == tag }
        }
        
        /// Returns the segment at the specified index.
        open func segment(at index: Int) -> Segment? {
            segments[safe: index]
        }
        
        /**
         Removes the specified segment from the toolbar item.
         
         If the segment is displayed in the toolbar item, it is detached and the
         indexes of the remaining segments update automatically.
         
         - Parameter segment: The segment to remove.
         */
        open func removeSegment(_ segment: Segment) {
            guard segment.toolbarItem === self else { return }
            guard let index = segment.index else { return }
            removeSegment(at: index)
        }
        
        /**
         Removes the segment at the specified index.
         
         The removed segment is detached from the toolbar item and the indexes
         of the remaining segments update automatically.
         
         - Parameter index: The index of the segment to remove.
         */
        open func removeSegment(at index: Int) {
            guard let segment = segments[safe: index] else { return }
            segment.toolbarItem = nil
            segments.remove(at: index)
        }
        
        /// Sets the index values of the selected segments.
        @discardableResult
        open func selectedIndexes(_ indexes: [Int]) -> Self {
            selectedIndexes = indexes
            return self
        }
        
        /// Sets the selection mode of the segmented control.
        @discardableResult
        open func selectionMode(_ mode: SelectionMode) -> Self {
            selectionMode = mode
            return self
        }
        
        /**
         Creates a labeled segmented control toolbar item.
         
         - Parameters:
            - identifier: The item identifier.
            - selectionMode: The segmented control selection mode.
            - segments: The segments of the toolbar item.
         */
        public init(_ identifier: NSToolbarItem.Identifier? = nil, selectionMode: SelectionMode = .selectOne, segments: [Segment]) {
            self.segments = segments
            super.init(identifier)
            sharedInit()
            self.selectionMode = selectionMode
            self.segments.forEach { $0.toolbarItem = self }
            updateSegments()
        }
        
        /**
         Creates a labeled segmented control toolbar item.
         
         - Parameters:
            - identifier: The item identifier.
            - selectionMode: The segmented control selection mode.
            - segments: The segments of the toolbar item.
         */
        public init(_ identifier: NSToolbarItem.Identifier? = nil, selectionMode: SelectionMode = .selectOne, @Builder segments: () -> [Segment]) {
            self.segments = segments()
            super.init(identifier)
            sharedInit()
            self.selectionMode = selectionMode
            self.segments.forEach { $0.toolbarItem = self }
            updateSegments()
        }
        
        private func sharedInit() {
            segmentedControl.translatesAutoresizingMaskIntoConstraints = false
            segmentedControl.setContentHuggingPriority(.defaultHigh, for: .horizontal)
            segmentedControl.segmentDistribution = .fillEqually
            segmentedControl.actionBlock = { [weak self] _ in
                guard let self else { return }
                self.syncSelectionFromControl()
                self.performAction()
            }
        }
        
        private func updateSegments() {
            groupItem.subitems = segments.map { $0.nsToolbarItem }
            segmentedControl.segments = segments.map { $0.segment }
            groupItem.view = segmentedControl
            // roupItem.label = label
            segmentedControl.sizeToFit()
        }
        
        private func syncSelectionFromControl() {
            let indexes = segmentedControl.indexesOfSelectedSegments
            for index in 0..<segments.count {
                let isSelected = indexes.contains(index)
                segments[index].isSelected = isSelected
                groupItem.setSelected(isSelected, at: index)
            }
        }
        
        fileprivate func updateSegment(_ segment: Segment) {
            guard let index = segment.index else { return }
            segmentedControl.setImage(segment.image, forSegment: index)
            if let subitem = groupItem.subitems[safe: index] {
                subitem.label = segment.title
            }
            segmentedControl.sizeToFit()
        }
        
        /// A segment displayed by a labeled segmented control toolbar item.
        open class Segment: NSObject {
            fileprivate weak var toolbarItem: Toolbar.SegmentedControl.Labeled?
            var groupItem: NSToolbarItem? {
                index.flatMap({ toolbarItem?.groupItem.subitems[safe: $0] })
            }
            
            /// The title displayed below the segment image.
            open var title: String {
                didSet { toolbarItem?.updateSegment(self) }
            }
            
            /// The image displayed by the segment.
            open var image: NSImage {
                didSet { toolbarItem?.updateSegment(self) }
            }
            
            /// A Boolean value indicating whether the segment is selected.
            open var isSelected: Bool = false {
                didSet { toolbarItem?.updateSegment(self) }
            }
            
            /// A Boolean value indicating whether the segment is enabled.
            open var isEnabled: Bool = true {
                didSet { toolbarItem?.updateSegment(self) }
            }
            
            /**
             The width of the segment.
             
             The default value is `0`, which indicates that the segment is sized automatically to fit the available space.
             */
            open var width: CGFloat = 0 {
                didSet {
                    width = width.clamped(min: 0)
                    toolbarItem?.updateSegment(self)
                }
            }
            
            /// The tooltip of the segment.
            open var toolTip: String? {
                didSet { toolbarItem?.updateSegment(self) }
            }
            
            /// The menu of the segment.
            open var menu: NSMenu? {
                didSet { toolbarItem?.updateSegment(self) }
            }
            
            /// A Boolean value indicating whether the segment shows a menu indicator.
            open var showsMenuIndicator: Bool = false {
                didSet { toolbarItem?.updateSegment(self) }
            }
            
            /// The tag of the segment.
            open var tag: Int = 0 {
                didSet { toolbarItem?.updateSegment(self) }
            }
            
            /**
             The object represented by the segment.
             
             The represented object functions as a more specific form of tag that allows you to associate any object, not just an arbitrary integer, with the segments in a segmented control.
             */
            open var representedObject: Any?
            
            /// The index of the segment, or `nil` if the segment isn't displayed in any labeled segmented control.
            open var index: Int? {
                toolbarItem?.segments.firstIndex { $0 === self }
            }
            
            /**
             Creates a labeled segment with the specified title and image.
             
             - Parameters:
             - title: The title displayed below the segment image.
             - image: The image displayed by the segment.
             */
            public init(_ title: String, image: NSImage) {
                self.title = title
                self.image = image
            }
            
            /**
             Creates a labeled segment with the specified title and image.
             
             - Parameters:
             - title: The title displayed below the segment image.
             - image: The image displayed by the segment.
             */
            public convenience init(title: String, image: NSImage) {
                self.init(title, image: image)
            }
            
            /**
             Creates a labeled segment with the specified title and system symbol image.
             
             - Parameters:
             - title: The title displayed below the segment image.
             - symbolName: The name of the system symbol image.
             */
            public convenience init?(title: String, symbolName: String) {
                guard let image = NSImage(systemSymbolName: symbolName) else { return nil }
                self.init(title, image: image)
            }
            
            /// Sets the title displayed below the segment image.
            @discardableResult
            open func title(_ title: String) -> Self {
                self.title = title
                return self
            }
            
            /// Sets the image displayed by the segment.
            @discardableResult
            open func image(_ image: NSImage) -> Self {
                self.image = image
                return self
            }
            
            /// Sets the symbol image displayed by the segment.
            @discardableResult
            open func symbolImage(_ symbolName: String) -> Self {
                if let image = NSImage(systemSymbolName: symbolName) {
                    self.image = image
                }
                return self
            }
            
            /// Sets the Boolean value indicating whether the segment is selected.
            @discardableResult
            open func isSelected(_ isSelected: Bool = true) -> Self {
                self.isSelected = isSelected
                return self
            }
            
            /// Sets the Boolean value indicating whether the segment is enabled.
            @discardableResult
            open func isEnabled(_ isEnabled: Bool) -> Self {
                self.isEnabled = isEnabled
                return self
            }
            
            /**
             Sets the width of the segment.
             
             A value of `0` indicates that the segment is sized automatically to fit the available space.
             */
            @discardableResult
            open func width(_ width: CGFloat) -> Self {
                self.width = width
                return self
            }
            
            /// Sets the tooltip of the segment.
            @discardableResult
            open func toolTip(_ toolTip: String?) -> Self {
                self.toolTip = toolTip
                return self
            }
            
            /// Sets the menu of the segment.
            @discardableResult
            open func menu(_ menu: NSMenu?) -> Self {
                self.menu = menu
                return self
            }
            
            /// Sets the Boolean value indicating whether the menu indicator is shown.
            @discardableResult
            open func showsMenuIndicator(_ shows: Bool) -> Self {
                showsMenuIndicator = shows
                return self
            }
            
            /// Sets the tag of the segment.
            @discardableResult
            open func tag(_ tag: Int) -> Self {
                self.tag = tag
                return self
            }
            
            /// Sets the object represented by the segment.
            @discardableResult
            open func representedObject(_ object: Any?) -> Self {
                representedObject = object
                return self
            }
            
            fileprivate var segment: NSSegment {
                NSSegment(image)
            }
            
            fileprivate var nsToolbarItem: NSToolbarItem {
                let item = NSToolbarItem(itemIdentifier: .init(UUID().uuidString))
                item.label = title
                return item
            }
        }
        
        /// A function builder type that produces an array of labeled segments.
        @resultBuilder
        public enum Builder {
            public static func buildBlock(_ components: [Segment]...) -> [Segment] {
                components.flatMap { $0 }
            }
            
            public static func buildExpression(_ expr: Segment) -> [Segment] {
                [expr]
            }
            
            public static func buildExpression(_ expr: Segment?) -> [Segment] {
                expr.map { [$0] } ?? []
            }
            
            public static func buildExpression(_ expr: [Segment]) -> [Segment] {
                expr
            }
            
            public static func buildOptional(_ component: [Segment]?) -> [Segment] {
                component ?? []
            }
            
            public static func buildEither(first component: [Segment]) -> [Segment] {
                component
            }
            
            public static func buildEither(second component: [Segment]) -> [Segment] {
                component
            }
            
            public static func buildArray(_ components: [[Segment]]) -> [Segment] {
                components.flatMap { $0 }
            }
        }
    }
}
#endif
