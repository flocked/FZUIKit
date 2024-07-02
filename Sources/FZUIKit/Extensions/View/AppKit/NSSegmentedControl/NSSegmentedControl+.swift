//
//  NSSegmentedControl+.swift
//
//
//  Created by Florian Zand on 18.08.22.
//

#if os(macOS)

    import AppKit

    public extension NSSegmentedControl {
        /// Selects all segments.
        func selectAll() {
            let count = segmentCount - 1
            for index in 0 ... count {
                setSelected(true, forSegment: index)
            }
        }

        /// Deselects all segments.
        func deselectAll() {
            let count = segmentCount - 1
            for index in 0 ... count {
                setSelected(false, forSegment: index)
            }
        }
        
        /// Sets the type of tracking behavior the control exhibits.
        @discardableResult
        func trackingMode(_ mode: SwitchTracking) -> Self {
            self.trackingMode = mode
            return self
        }
        
        /// Sets the visual style used to display the control.
        @discardableResult
        func style(_ style: Style) -> Self {
            self.segmentStyle = style
            return self
        }
    }
#endif
