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
        /// The selected segments.
        @State public private(set) var selectedSegments: [NSSegment] = []
        
        var segments: [NSSegment] = []
        var trackingMode: NSSegmentedControl.SwitchTracking = .selectOne
        var style: NSSegmentedControl.Style = .automatic
        @Environment(\.isEnabled) var isEnabled
        
        /// Sets the segments displayed by the segmented control.
        public func segments(@NSSegmentedControl.Builder segments: () -> [NSSegment]) -> Self {
            var view = self
            view.segments = segments()
            view.selectedSegments = segments().filter({$0.isSelected})
            return view
        }
        
        /// Sets the segments displayed by the segmented control.
        public func segments(_ segments: [NSSegment]) -> Self {
            var view = self
            view.segments = segments
            view.selectedSegments = segments.filter({$0.isSelected})
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

        /// Creates a segmented control view.
        public init() {
            
        }
        
        /**
         Creates a segmented control view with the specified segments.
         
         - Parameter segments: The segments displayed by the segmented control.
         */
        public init(@NSSegmentedControl.Builder segments: () -> [NSSegment]) {
            self.segments = segments()
        }
        
        public func makeNSView(context: Context) -> NSSegmentedControl {
            let segmentedControl = NSSegmentedControl(segments: segments)
            selectedSegments = segmentedControl.selectedSegments
            segmentedControl.trackingMode = trackingMode
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
        
        /// The coordinator of the segmented control.
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
