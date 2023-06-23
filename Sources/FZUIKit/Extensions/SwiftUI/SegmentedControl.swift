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

    public func segments(_ segments: [NSSegmentedControl.Segment]) -> Self {
        self.segments = segments
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

    @State public var segments: [NSSegmentedControl.Segment] = []
    @State public var trackingMode: NSSegmentedControl.SwitchTracking = .selectOne
    @State public var indexOfSelectedSegment: Int = 0
    @State public var style: NSSegmentedControl.Style = .automatic

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
        return Coordinator(segmentedControl: self)
    }

    /*
     public init(segments: [NSSegmentedControl.Segment] = [], trackingMode: NSSegmentedControl.SwitchTracking = .selectOne, indexOfSelectedSegment: Int = 0, style: NSSegmentedControl.Style = .automatic) {

         self.segments = segments
         self.trackingMode = trackingMode
         self.indexOfSelectedSegment = indexOfSelectedSegment
         self.style = style

     }
     */
}

struct SegmentedControl_Preview: PreviewProvider {
    static var previews: some View {
        SegmentedControl(segments: ["Segment 1", "Segment 2"])
            .previewLayout(PreviewLayout.sizeThatFits)
            .padding()
        //   .previewDisplayName("Default preview")
    }
}

#endif
