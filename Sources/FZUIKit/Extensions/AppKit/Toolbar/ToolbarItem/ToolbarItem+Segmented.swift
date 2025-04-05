//
//  ToolbarItem+Segmented.swift
//
//
//  Created by Florian Zand on 09.04.23.
//

#if os(macOS)
    import AppKit
    import FZSwiftUtils

    public extension ToolbarItem {
        /**
         A toolbar item that contains a segmented control.

         The item can be used with ``Toolbar``.
         */
        class Segmented: ToolbarItem {
            
            lazy var groupItem = ValidateToolbarItemGroup(for: self)
            override var item: NSToolbarItem {
                groupItem
            }

            /// The segmented control of the toolbar item.
            public let segmentedControl: NSSegmentedControl

            /// The segments of the segmented control.
            public var segments: [NSSegment] {
                get { segmentedControl.segments }
                set { segmentedControl.segments = newValue }
            }
            
            /**
             The selected segments.
             
             To get the last selected segment, check the selected segment where ``NSSegment/isLastSelected`` is `true.`
             */
            public var selectedSegments: [NSSegment] {
                segmentedControl.selectedSegments
            }
            
            /// Sets the segments of the segmented control.
            @discardableResult
            public func segments(_ segments: [NSSegment]) -> Self {
                self.segments = segments
                return self
            }
            
            /// Sets the segments of the segmented control.
            @discardableResult
            public func segments(@NSSegmentedControl.Builder segments: () -> [NSSegment]) -> Self {
                self.segments = segments()
                return self
            }

            /// Sets rhe selection mode for the segmented control.
            @discardableResult
            public func selectionMode(_ mode: SelectionMode) -> Self {
                segmentedControl.trackingMode = mode.switchTracking
                return self
            }
            
            /// The selection mode for the segmented control.
            public enum SelectionMode: UInt, Hashable, Codable {
                /// Only one segment can be selected at a time.
                case selectOne
                /// One or more segments can be selected at a time.
                case selectAny
                /// A segment is selected only when the user is pressing the mouse down. When the mouse is no longer down within the segment, the segment is automatically deselected.
                case momentary
                
                var switchTracking: NSSegmentedControl.SwitchTracking {
                    NSSegmentedControl.SwitchTracking(rawValue: rawValue)!
                }
            }

            /// Sets the visual style used to display the segmented control.
            @discardableResult
            public func style(_ type: NSSegmentedControl.Style) -> Self {
                segmentedControl.segmentStyle = type
                return self
            }

            /// Sets the color of the selected segment's bezel, in appearances that support it.
            @discardableResult
            public func selectedSegmentBezelColor(_ color: NSColor?) -> Self {
                segmentedControl.selectedSegmentBezelColor = color
                return self
            }
            
            /**
             Sets the Boolean value that indicates whether the toolbar item is displayed as a group of individual toolbar items and labels for each segment.
             
             - Note: This property only works if you provide `image` for each segment.
             */
            @discardableResult
            public func displaysIndividualSegmentLabels(_ displays: Bool) -> Self {
                self.displaysIndividualSegmentLabels = displays
                return self
            }
            
            /**
             The Boolean value that indicates whether the toolbar item is displayed as a group of individual toolbar items and labels for each segment.

             - Note: This property only works if you provide both `title` and `image` for each segment.
             */
            public var displaysIndividualSegmentLabels: Bool = false {
                didSet {
                    guard oldValue != displaysIndividualSegmentLabels else { return }
                    updateSegments()
                }
            }
            
            func updateSegments() {
                if displaysIndividualSegmentLabels, !segments.contains(where: { $0.image == nil }) {
                    segmentedControl.segments = segments.compactMap({ $0.withoutTitle })
                    groupItem.subitems = segments.compactMap({ $0.toolbarItem(for: self) })
                } else {
                    groupItem.subitems = []
                    segmentedControl.segments = segments
                    if _label != "" {
                        groupItem.label = _label
                    }
                }
                segmentedControl.sizeToFit()
            }
            
            /// The handler that gets called when the user clicks the segmented control.
            var actionBlock: ((_ item: ToolbarItem.Segmented)->())? {
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
            public func onAction(_ handler: ((_ item: ToolbarItem.Segmented)->())?) -> Self {
                actionBlock = handler
                return self
            }
            
            /**
             Creates a segmented control toolbar item.

             - Parameters:
                - identifier: The item identifier.
                - switching: The segmented control switching mode. The default value is `selectOne`.
                - segments: The segments of the segmented control.
             */
            public convenience init(_ identifier: NSToolbarItem.Identifier? = nil,
                                    selectionMode: SelectionMode = .selectOne,
                                    style: NSSegmentedControl.Style = .automatic,
                                    @NSSegmentedControl.Builder segments: () -> [NSSegment]) {
                self.init(identifier, segmentedControl: NSSegmentedControl().style(style).trackingMode(selectionMode.switchTracking))
                self.segments = segments()
                updateSegments()
            }

            /**
             Creates a segmented control toolbar item.

             - Parameters:
                - identifier: The item identifier.
                - segmentedControl: The segmented control of the item.
             */
            public init(_ identifier: NSToolbarItem.Identifier? = nil,
                        segmentedControl: NSSegmentedControl) {
                self.segmentedControl = segmentedControl
                super.init(identifier)
                segmentedControl.toolbarItem = self
                segmentedControl.translatesAutoresizingMaskIntoConstraints = false
                segmentedControl.setContentHuggingPriority(.defaultHigh, for: .horizontal)
                segmentedControl.segmentDistribution = .fillEqually
                item.view = segmentedControl
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
#endif
