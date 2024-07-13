//
//  SegmentedControl.swift
//
//
//  Created by Florian Zand on 02.02.23.
//

#if os(macOS)
    import AppKit
    import SwiftUI

    public struct SegmentedControl: NSViewRepresentable {
        public class Coordinator: NSObject {
            var parent: SegmentedControl
            init(segmentedControl: SegmentedControl) {
                parent = segmentedControl
            }

            @objc func selectedIndexChanged(_ sender: NSSegmentedControl) {
                parent.segments = sender.segments
                parent.selectedSegments = sender.selectedSegments
            }
        }

        public typealias NSViewType = NSSegmentedControl

        /// Sets the segments displayed by the segmented control.
        public func segments(@NSSegmentedControl.Builder segments: () -> [NSSegment]) -> Self {
            var view = self
            view.segments = segments()
            return view
        }
        
        /// Sets the segments displayed by the segmented control.
        public func segments(_ segments: [NSSegment]) -> Self {
            var view = self
            view.segments = segments
            return view
        }

        /// Sets the type of tracking behavior the control exhibits.
        public func trackingMode(_ trackingMode: NSSegmentedControl.SwitchTracking) -> Self {
            var view = self
            view.trackingMode = trackingMode
            return view
        }

        /// Sets the visual style used to display the control.
        public func style(_ style: NSSegmentedControl.Style) -> Self {
            var view = self
            view.style = style
            return view
        }
        
        /// Sets the visual style used to display the control.
        public func menu(_ menu: NSMenu?) -> Self {
            var view = self
            view.menu = menu
            return view
        }

        /// The segments displayed by the segmented control.
        public private(set) var segments: [NSSegment]
        /// The type of tracking behavior the control exhibits.
        public private(set) var trackingMode: NSSegmentedControl.SwitchTracking
        /// The selected segments.
        @State public private(set) var selectedSegments: [NSSegment] = []
        /// The visual style used to display the control.
        public private(set) var style: NSSegmentedControl.Style
        /// The menu.
        public private(set) var menu: NSMenu?
        /// A Boolean value that indicates whether the segmented control reacts to mouse events.
        @Environment(\.isEnabled) public var isEnabled

        public init(segments: [NSSegment] = [], trackingMode: NSSegmentedControl.SwitchTracking = .selectOne, style: NSSegmentedControl.Style = .automatic, menu: NSMenu? = nil) {
            self.segments = segments
            self.trackingMode = trackingMode
            self.style = style
            self.menu = menu
            //
        }
        
        public func makeNSView(context: Context) -> NSSegmentedControl {
            let segmentedControl = NSSegmentedControl(segments: segments)
            selectedSegments = segmentedControl.selectedSegments
            segmentedControl.trackingMode = trackingMode
            segmentedControl.menu = menu
            segmentedControl.segmentStyle = style
            segmentedControl.isEnabled = isEnabled
            segmentedControl.target = context.coordinator
            segmentedControl.action = #selector(Coordinator.selectedIndexChanged(_:))
            segmentedControl.sizeToFit()
            return segmentedControl
        }

        public func updateNSView(_ nsView: NSSegmentedControl, context _: Context) {
            nsView.segments = segments
            nsView.trackingMode = trackingMode
            nsView.segmentStyle = style
            nsView.isEnabled = isEnabled
            nsView.sizeToFit()
        }

        public func makeCoordinator() -> Coordinator {
            Coordinator(segmentedControl: self)
        }
    }

    struct SegmentedControl_Preview: PreviewProvider {
        static var previews: some View {
            SegmentedControl()
                .trackingMode(.selectOne)
                .style(.texturedRounded)
                .segments {
                    NSSegment("Segment 1")
                        .isSelected(true)
                    NSSegment("Segment 2")
                    NSSegment("Segment 3")
                }
                .previewLayout(PreviewLayout.sizeThatFits)
                .padding()
        }
    }

#endif
