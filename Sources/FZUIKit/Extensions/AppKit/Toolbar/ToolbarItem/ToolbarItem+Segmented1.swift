//
//  ToolbarItem+Segmented1.swift
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
        class Segmented1: ToolbarItem {
            public enum LabelMode: Int, Hashable {
                case single
                case individual
            }
            
            /// Switching mode of the segmented control.
            public typealias SwitchingMode = NSSegmentedControl.SwitchTracking
            /// Style of the segmented control.
            public typealias Style = NSSegmentedControl.Style
            
            lazy var groupItem = NSToolbarItemGroup(identifier)
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
            
            public var labelMode: LabelMode = .single

            /// The type of tracking behavior the segmented control exhibits.
            @discardableResult
            public func switchingMode(_ mode: NSSegmentedControl.SwitchTracking) -> Self {
                segmentedControl.trackingMode = mode
                return self
            }

            /// The visual style used to display the segmented control.
            @discardableResult
            public func type(_ type: Style) -> Self {
                segmentedControl.segmentStyle = type
                return self
            }

            /// The color of the selected segment's bezel, in appearances that support it.
            @discardableResult
            public func selectedSegmentBezelColor(_ color: NSColor?) -> Self {
                segmentedControl.selectedSegmentBezelColor = color
                return self
            }

            /// The segments of the segmented control.
            @discardableResult
            public func segments(_ segments: [NSSegment]) -> Self {
                segmentedControl.segments = segments
                return self
            }

            /// The action block that is called when the selection of the segmented control changes.
            @discardableResult
            public func onSelection(_ handler: @escaping ([NSSegment]) -> Void) -> Self {
                segmentedControl.actionBlock = { [weak self] _ in
                    guard let self = self else { return }
                    var selected = self.segments.filter(\.isSelected)
                    if let index = selected.firstIndex(where: { $0.isLastSelected == true }) {
                        let lastSelected = selected.remove(at: index)
                        selected = lastSelected + selected
                    }
                    handler(selected)
                }

                /*
                 item.actionBlock = { [weak self] _ in
                     guard let self = self else { return }
                     var selected = self.segments.filter { $0.isSelected }
                     if let index = selected.firstIndex(where: { $0.isLastSelected == true }) {
                         let lastSelected = selected.remove(at: index)
                         selected = lastSelected + selected
                     }
                     handler(selected)
                 }
                 */
                return self
            }

            static func segmentedControl(switching: NSSegmentedControl.SwitchTracking, type: Style, @NSSegmentedControl.Builder segments: () -> [NSSegment]) -> NSSegmentedControl {
                let segmentedControl = NSSegmentedControl(switching: switching, style: type, segments: segments)
                segmentedControl.segmentDistribution = .fillEqually
                segmentedControl.translatesAutoresizingMaskIntoConstraints = false
                segmentedControl.setContentHuggingPriority(.defaultHigh, for: .horizontal)
                return segmentedControl
            }

            /**
             Creates a segmented control toolbar item.

             - Parameters:
                - identifier: An optional identifier of the item.
                - type: The segmented control type. The default value is `automatic`.
                - switching: The segmented control switching mode. The default value is `selectOne`.
                - segmentWidths: The segmented control width. The default value is `nil`, which idicates no specific width.
                - segments: The segments of the segmented control.
             */
            public convenience init(_ identifier: NSToolbarItem.Identifier? = nil,
                                    type: Style = .automatic,
                                    switching: NSSegmentedControl.SwitchTracking = .selectOne,
                                    segmentWidths: CGFloat? = nil,
                                    @NSSegmentedControl.Builder segments: () -> [NSSegment])
            {
                let segmentedControl = NSSegmentedControl(switching: switching, style: type, segments: segments)
                self.init(identifier, segmentedControl: segmentedControl)
            }

            /**
             Creates a segmented control toolbar item.

             - Parameters:
                - identifier: An optional identifier of the item.
                - segmentedControl: The segmented control of the item.
             */
            public init(_ identifier: NSToolbarItem.Identifier? = nil,
                        segmentedControl: NSSegmentedControl)
            {
                self.segmentedControl = segmentedControl
                super.init(identifier ?? .random)
                self.segmentedControl.translatesAutoresizingMaskIntoConstraints = false
                self.segmentedControl.setContentHuggingPriority(.defaultHigh, for: .horizontal)
                self.segmentedControl.segmentDistribution = .fillEqually
                item.view = self.segmentedControl
                self.segmentedControl.actionBlock = { [weak self] _ in
                    guard let self = self else { return }
                    self.item.actionBlock?(self.item)
                }
            }
        }
    }
#endif
