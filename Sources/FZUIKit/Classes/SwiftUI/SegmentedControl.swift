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

    /**
     Creates a segmented control view with the specified segments.

     - Parameter segments: The segments displayed by the segmented control.
     */
    public init(@NSSegmentedControl.Builder segments: () -> [NSSegment]) {
        self.segments = segments()
    }

    public func makeNSView(context: Context) -> NSSegmentedControl {
        let segmentedControl = NSSegmentedControl(segments: segments)
        updateNSView(segmentedControl, context: context)
        selectedSegments = segmentedControl.selectedSegments
        segmentedControl.target = context.coordinator
        segmentedControl.action = #selector(Coordinator.selectedIndexChanged(_:))
        return segmentedControl
    }

    public func updateNSView(_ segmentedControl: NSSegmentedControl, context: Context) {
        segmentedControl.segments = segments
        segmentedControl.trackingMode = trackingMode
        segmentedControl.segmentStyle = style
        segmentedControl.isEnabled = context.environment.isEnabled
        segmentedControl.sizeToFit()
    }

    public func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    /// The coordinator of the segmented control.
    public class Coordinator: NSObject {
        var parent: SegmentedControl
        init(_ parent: SegmentedControl) {
            self.parent = parent
        }

        @objc func selectedIndexChanged(_ sender: NSSegmentedControl) {
            parent.segments = sender.segments
            parent.selectedSegments = sender.selectedSegments
        }
    }
}

struct SegmentedControl_Preview: PreviewProvider {
    static var previews: some View {
        SegmentedControl() {
            NSSegment("Segment 1")
                .isSelected(true)
            NSSegment("Segment 2")
            NSSegment("Segment 3")
        }
        .trackingMode(.selectOne)
        .style(.texturedRounded)
        .previewLayout(PreviewLayout.sizeThatFits)
        .padding()
    }
}

#endif
