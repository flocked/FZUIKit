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
                parent.indexOfSelectedSegment = sender.indexOfSelectedItem
            }
        }

        public typealias NSViewType = NSSegmentedControl

        public func segments(@NSSegmentedControl.Builder segments: () -> [NSSegment]) -> Self {
            self.segments = segments()
            return self
        }

        public func trackingMode(_ trackingMode: NSSegmentedControl.SwitchTracking) -> Self {
            self.trackingMode = trackingMode
            return self
        }

        public func style(_ style: NSSegmentedControl.Style) -> Self {
            self.style = style
            return self
        }

        @State public private(set) var segments: [NSSegment] = []
        @State public private(set) var trackingMode: NSSegmentedControl.SwitchTracking = .selectOne
        @State public private(set) var indexOfSelectedSegment: Int = 0
        @State public private(set) var style: NSSegmentedControl.Style = .automatic

        public func makeNSView(context: Context) -> NSSegmentedControl {
            let segmentedControl = NSSegmentedControl(segments: segments)
            segmentedControl.trackingMode = trackingMode
            segmentedControl.segmentStyle = style
            if indexOfSelectedSegment >= 0 {
                segmentedControl.setSelected(true, forSegment: indexOfSelectedSegment)
            }
            segmentedControl.target = context.coordinator
            segmentedControl.action = #selector(Coordinator.selectedIndexChanged(_:))
            return segmentedControl
        }

        public func updateNSView(_ nsView: NSSegmentedControl, context _: Context) {
            nsView.segments = segments
            nsView.trackingMode = trackingMode
            nsView.segmentStyle = style
            if indexOfSelectedSegment >= 0 {
                nsView.setSelected(true, forSegment: indexOfSelectedSegment)
            }
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
