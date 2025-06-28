//
//  ToolbarItem+Segmented.swift
//
//
//  Created by Florian Zand on 09.04.23.
//

#if os(macOS)
import AppKit
import FZSwiftUtils

extension ToolbarItem {
    /// A toolbar item that contains a segmented control.
    open class Segmented: ToolbarItem {
        
        lazy var groupItem: ValidateSegmentedToolbarItem = {
            let item = ValidateSegmentedToolbarItem(for: self)
            item.view = segmentedControl
            return item
        }()
        
        override var item: NSToolbarItem {
            groupItem
        }
        
        /// The segmented control of the toolbar item.
        public let segmentedControl: NSSegmentedControl
        
        /// The segments of the segmented control.
        open var segments: [NSSegment] {
            get { segmentedControl.segments }
            set {
                segmentedControl.segments = newValue
                updateSegments()
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
         The Boolean value that indicates whether the toolbar item is displayed as a group of individual toolbar items and labels for each segment.
         
         - Note: This property only works if you provide both `title` and `image` for each segment.
         */
        open var displaysIndividualSegmentLabels: Bool = false {
            didSet {
                guard oldValue != displaysIndividualSegmentLabels else { return }
                updateSegments()
            }
        }
        
        /**
         Sets the Boolean value that indicates whether the toolbar item is displayed as a group of individual toolbar items and labels for each segment.
         
         - Note: This property only works if you provide `image` for each segment.
         */
        @discardableResult
        open func displaysIndividualSegmentLabels(_ displays: Bool) -> Self {
            self.displaysIndividualSegmentLabels = displays
            return self
        }
        
        func updateSegments() {
            if displaysIndividualSegmentLabels, !segments.contains(where: { $0.image == nil }) {
                groupItem.label = ""
                let subitems = segments.compactMap({ $0.toolbarItem(for: self) })
                segmentedControl.segments = segments.compactMap({ $0.withoutTitle })
                groupItem.subitems = subitems
            } else {
                for val in zip(segmentedControl.segments, groupItem.subitems) {
                    val.0.title = val.1.label
                }
                groupItem.subitems = []
                segmentedControl.segments = segments
                if label != "" {
                    groupItem.label = label
                }
            }
            segmentedControl.sizeToFit()
        }
        
        /// The handler that gets called when the user clicks the segmented control.
        open var actionBlock: ((_ item: ToolbarItem.Segmented)->())? {
            didSet {
                if let actionBlock = actionBlock {
                    segmentedControl.actionBlock = { [weak self] _ in
                        guard let self = self else { return }
                        actionBlock(self)
                    }
                } else {
                    segmentedControl.actionBlock = nil
                }
            }
        }
        
        /// Sets the handler that gets called when the user clicks the segmented control.
        @discardableResult
        open func onAction(_ handler: ((_ item: ToolbarItem.Segmented)->())?) -> Self {
            actionBlock = handler
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
            segmentedControl.toolbarItem = self
            segmentedControl.translatesAutoresizingMaskIntoConstraints = false
            segmentedControl.setContentHuggingPriority(.defaultHigh, for: .horizontal)
            segmentedControl.segmentDistribution = .fillEqually
        }
    }
}

fileprivate extension NSSegment {
    func toolbarItem(for groupItem: ToolbarItem.Segmented) -> NSToolbarItem {
        let item = NSToolbarItem(itemIdentifier: .init(title ?? .random()))
        item.label = title ?? ""
        item.autovalidates = false
        item.isEnabled = isEnabled
        item.toolTip = toolTip
        item.actionBlock = { [weak self] _ in
            guard self != nil else { return }
            groupItem.actionBlock?(groupItem)
        }
        if let image = image {
            item.menuFormRepresentation = NSMenuItem(title, image: image)
        } else if let title = title {
            item.menuFormRepresentation = NSMenuItem(title)
        }
        return item
    }
    
    var withoutTitle: NSSegment {
        let segment = NSSegment("")
        segment.title = nil
        segment.titleAlignment = titleAlignment
        segment.image = image
        segment.imageScaling = imageScaling
        segment.menu = menu
        segment.showsMenuIndicator = showsMenuIndicator
        segment.isSelected = isSelected
        segment.isEnabled = isEnabled
        segment.width = width
        segment.toolTip = toolTip
        segment.tag = tag
        segment.font = font
        segment.index = index
        segment.segmentedControl = segmentedControl
        return segment
    }
}

class ValidateSegmentedToolbarItem: NSToolbarItemGroup {
    weak var item: ToolbarItem.Segmented?
    
    init(for item: ToolbarItem.Segmented) {
        super.init(itemIdentifier: item.identifier)
        self.item = item
    }
    
    override func validate() {
        super.validate()
        guard let item = item else { return }
        item.validate()
        item.validateHandler?(item)
    }
}
#endif
