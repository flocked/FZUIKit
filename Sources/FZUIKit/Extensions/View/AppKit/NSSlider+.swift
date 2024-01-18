//
//  NSSlider+.swift
//
//
//  Created by Florian Zand on 18.08.22.
//

#if os(macOS)

    import AppKit
    import Foundation

    public extension NSSlider {
        /// The position of the slider knob.
        var knobPointPosition: CGFloat {
            let sliderOrigin = frame.origin.x + knobThickness / 2
            let sliderWidth = frame.width - knobThickness
            assert(maxValue > minValue)
            let knobPos = sliderOrigin + sliderWidth * CGFloat((doubleValue - minValue) / (maxValue - minValue))
            return knobPos
        }
    }

#endif
