//
//  ToolbarItem+Segmented.swift
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

        public let segmentedControl: NSSegmentedControl

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
            self.segmentedControl.actionBlock = { [weak self] segment in
                guard let self = self else { return }
                var selected = self.segments.filter { $0.isSelected }
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

        internal static func segmentedControl(switching: SwitchingMode, type: Style, @NSSegmentedControl.Builder segments: () -> [Segment]) -> NSSegmentedControl {
            let segmentedControl = NSSegmentedControl(switching: switching, style: type, segments: segments)
            segmentedControl.segmentDistribution = .fit
            segmentedControl.translatesAutoresizingMaskIntoConstraints = false
            segmentedControl.setContentHuggingPriority(.defaultHigh, for: .horizontal)
            return segmentedControl
        }

        public convenience init(
            _ identifier: NSToolbarItem.Identifier,
            type: Style = .automatic,
            switching: SwitchingMode = .selectOne,
            segmentWidths: CGFloat? = nil,
            @NSSegmentedControl.Builder segments: () -> [Segment]
        ) {
            let segmentedControl = NSSegmentedControl(switching: switching, style: type, segments: segments)
            self.init(identifier, segmentedControl: segmentedControl)
        }

        public init(_ identifier: NSToolbarItem.Identifier,
                    segmentedControl: NSSegmentedControl)
        {
            self.segmentedControl = segmentedControl
            super.init(identifier)
            self.segmentedControl.translatesAutoresizingMaskIntoConstraints = false
            self.segmentedControl.setContentHuggingPriority(.defaultHigh, for: .horizontal)
            self.item.view = self.segmentedControl
            self.segmentedControl.actionBlock = { [weak self] _ in
                guard let self = self else { return }
                self.item.actionBlock?(self.item)
            }
        }
    }
}
#endif
