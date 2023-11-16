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
    /// A toolbar item that contains a segmented control.
    class Segmented: ToolbarItem {
        public typealias SwitchingMode = NSSegmentedControl.SwitchTracking
        public typealias Style = NSSegmentedControl.Style

        /// The segmented control of the toolbar item.
        public let segmentedControl: NSSegmentedControl

        /// The segments of the segmented control.
        public var segments: [NSSegment] {
            get { segmentedControl.segments }
            set { segmentedControl.segments = newValue }
        }

        @discardableResult
        /// The type of tracking behavior the segmented control exhibits.
        public func switchingMode(_ mode: SwitchingMode) -> Self {
            segmentedControl.trackingMode = mode
            return self
        }

        @discardableResult
        /// The visual style used to display the segmented control.
        public func type(_ type: Style) -> Self {
            segmentedControl.segmentStyle = type
            return self
        }

        @discardableResult
        /// The color of the selected segment's bezel, in appearances that support it.
        public func selectedSegmentBezelColor(_ color: NSColor?) -> Self {
            segmentedControl.selectedSegmentBezelColor = color
            return self
        }

        @discardableResult
        /// The segments of the segmented control.
        public func segments(_ segments: [NSSegment]) -> Self {
            segmentedControl.segments = segments
            return self
        }

        @discardableResult
        /// The action block that is called when the selection of the segmented control changes.
        public func onSelection(_ handler: @escaping ([NSSegment]) -> Void) -> Self {
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

        internal static func segmentedControl(switching: SwitchingMode, type: Style, @NSSegmentedControl.Builder segments: () -> [NSSegment]) -> NSSegmentedControl {
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
            @NSSegmentedControl.Builder segments: () -> [NSSegment]
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
