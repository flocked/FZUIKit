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
            self.segments = segments()
            return self
        }
        
        /// Sets the segments displayed by the segmented control.
        public func segments(_ segments: [NSSegment]) -> Self {
            self.segments = segments
            return self
        }

        /// Sets the type of tracking behavior the control exhibits.
        public func trackingMode(_ trackingMode: NSSegmentedControl.SwitchTracking) -> Self {
            self.trackingMode = trackingMode
            return self
        }

        /// Sets the visual style used to display the control.
        public func style(_ style: NSSegmentedControl.Style) -> Self {
            self.style = style
            return self
        }
        
        /// Sets the visual style used to display the control.
        public func menu(_ menu: NSMenu?) -> Self {
            self.menu = menu
            return self
        }

        /// The segments displayed by the segmented control.
        @State public private(set) var segments: [NSSegment] = []
        /// The type of tracking behavior the control exhibits.
        @State public private(set) var trackingMode: NSSegmentedControl.SwitchTracking = .selectOne
        /// The selected segments.
        @State public private(set) var selectedSegments: [NSSegment] = []
        /// The visual style used to display the control.
        @State public private(set) var style: NSSegmentedControl.Style = .automatic
        /// The menu.
        @State public private(set) var menu: NSMenu? = nil
        /// The menu.
        @State public private(set) var disabled: Bool = false
        /// A Boolean value that indicates whether the segmented control reacts to mouse events.
        @Environment(\.isEnabled) public var isEnabled

        public init() {
            
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
            return segmentedControl
        }

        public func updateNSView(_ nsView: NSSegmentedControl, context _: Context) {
            nsView.segments = segments
            nsView.trackingMode = trackingMode
            nsView.segmentStyle = style
            nsView.isEnabled = isEnabled
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
