//
//  File.swift
//
//
//  Created by Florian Zand on 09.04.23.
//

#if os(macOS)
    import Cocoa
    import FZSwiftUtils

    public extension ToolbarItem {
        class Segmented: ToolbarItem {
            public typealias SwitchingMode = NSSegmentedControl.SwitchTracking
            public typealias Segment = NSSegmentedControl.Segment
            public typealias Style = NSSegmentedControl.Style

            internal let segmentedControl: NSSegmentedControl

            public var segments: [Segment] {
                get { segmentedControl.segments }
                set { segmentedControl.segments = newValue }
            }

            @discardableResult
            public func switchingMode(_ mode: SwitchingMode) -> Self {
                segmentedControl.trackingMode = mode
                return self
            }

            @discardableResult
            public func type(_ type: Style) -> Self {
                segmentedControl.segmentStyle = type
                return self
            }

            @discardableResult
            public func selectedSegmentBezelColor(_ color: NSColor?) -> Self {
                segmentedControl.selectedSegmentBezelColor = color
                return self
            }

            @discardableResult
            public func segments(_ segments: [Segment]) -> Self {
                segmentedControl.segments = segments
                return self
            }

            @discardableResult
            public func onSelection(_ handler: @escaping ([Segment]) -> Void) -> Self {
                item.actionBlock = { [weak self] _ in
                    guard let self = self else { return }
                    var selected = self.segments.filter { $0.isSelected }
                    if let index = selected.firstIndex(where: { $0.isLastSelected == true }) {
                        let lastSelected = selected.remove(at: index)
                        selected = lastSelected + selected
                    }
                    handler(selected)
                }
                return self
            }

            internal static func segmentedControl(segments: [Segment], switching: SwitchingMode, type: Style) -> NSSegmentedControl {
                let segmentedControl = NSSegmentedControl(segments: segments, switching: switching, style: type)
                segmentedControl.translatesAutoresizingMaskIntoConstraints = false
                segmentedControl.setContentHuggingPriority(.defaultHigh, for: .horizontal)
                segmentedControl.segmentDistribution = .fillEqually
                return segmentedControl
            }

            public convenience init(
                _ identifier: NSToolbarItem.Identifier,
                type: Style,
                switching: SwitchingMode = .selectAny,
                segmentWidths _: CGFloat? = nil,
                segments: [Segment]
            ) {
                let segmentedControl = Self.segmentedControl(segments: segments, switching: switching, type: type)
                self.init(identifier, segmentedControl: segmentedControl)
            }

            public convenience init(
                _ identifier: NSToolbarItem.Identifier,
                type: Style = .automatic,
                switching: SwitchingMode = .selectAny,
                segmentWidths: CGFloat? = nil,
                @NSSegmentedControl.Builder segments: () -> [Segment]
            ) {
                let segmentedControl = NSSegmentedControl(segments: segments(), switching: switching, style: type)
                self.init(identifier, segmentedControl: segmentedControl)
            }

            public init(_ identifier: NSToolbarItem.Identifier,
                        segmentedControl: NSSegmentedControl)
            {
                self.segmentedControl = segmentedControl
                super.init(identifier)
                self.segmentedControl.actionBlock = { [weak self] _ in
                    guard let self = self else { return }
                    self.item.actionBlock?(self.item)
                }
            }
        }
    }
#endif
