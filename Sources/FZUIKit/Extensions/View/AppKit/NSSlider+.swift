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
    /**
     Creates a continuous horizontal slider that represents values over the specified range.
         
     - Parameters:
        - value: The initial value.
        - range: The range.
        - action: The action handler.
         
     - Returns: An initialized slider control.
     */
    convenience init(value: Double, range: ClosedRange<Double>, action: ActionBlock? = nil) {
        self.init(value: value, minValue: range.lowerBound, maxValue: range.upperBound, target: nil, action: nil)
        actionBlock = action
    }
        
    /**
     Creates a linear slider with the specified orientation and size.
         
     - Parameters:
        - orientation: The orientation of the slider.
        - size: The size of the slider.
     */
    static func linear(orientation: NSUserInterfaceLayoutOrientation = .horizontal, size: ControlSize = .regular) -> NSSlider {
        let slider = NSSlider(target: nil, action: nil)
        slider.isVertical = orientation == .vertical
        slider.controlSize = size
        return slider
    }
        
    /**
     Creates a circular slider with the specified size.
         
     - Parameter size: The size of the slider.
     */
    static func circular(size: ControlSize = .regular) -> NSSlider {
        let slider = NSSlider()
        slider.sliderType = .circular
        slider.controlSize = size
        return slider
    }
        
    /// The range of the slider.
    var range: ClosedRange<Double> {
        get { minValue...maxValue }
        set {
            minValue = newValue.lowerBound
            maxValue = newValue.upperBound
        }
    }
        
    /// Sets the range of the slider.
    @discardableResult
    func range(_ range: ClosedRange<Double>) -> Self {
        self.range = range
        return self
    }
        
    /// The rectangle in which the bar is drawn.
    var barRect: CGRect {
        (cell as? NSSliderCell)?.barRect(flipped: isFlipped) ?? .zero
    }
        
    /// The rectangle in which the knob is drawn.
    var knobRect: CGRect {
        (cell as? NSSliderCell)?.knobRect(flipped: isFlipped) ?? .zero
    }
        
    /// The position of the slider knob.
    var knobPointPosition: CGFloat {
        let sliderOrigin = frame.origin.x + knobThickness / 2
        let sliderWidth = frame.width - knobThickness
        assert(maxValue > minValue)
        let knobPos = sliderOrigin + sliderWidth * CGFloat((doubleValue - minValue) / (maxValue - minValue))
        return knobPos
    }
        
    /// Sets the minimum value the slider can send to its target.
    @discardableResult
    func minValue(_ minValue: Double) -> Self {
        self.minValue = minValue
        return self
    }
        
    /// Sets the maximum value the slider can send to its target.
    @discardableResult
    func maxValue(_ maxValue: Double) -> Self {
        self.maxValue = maxValue
        return self
    }
        
    /// Sets the amount by which the slider changes its value when the user Option-drags the slider knob.
    @discardableResult
    func altIncrementValue(_ value: Double) -> Self {
        self.altIncrementValue = value
        return self
    }
        
    /// Sets the orientaiton of the slider.
    @discardableResult
    func orientation(_ orientation: NSUserInterfaceLayoutOrientation) -> Self {
        self.isVertical = orientation == .vertical
        return self
    }
        
    /// Sets the type of the slider, such as vertical or circular.
    @discardableResult
    func type(_ type: SliderType) -> Self {
        self.sliderType = type
        return self
    }
        
    /// Sets the color of the filled portion of the slider track, in appearances that support it.
    @discardableResult
    func trackFillColor(_ color: NSColor?) -> Self {
        self.trackFillColor = color
        return self
    }
        
    /// Sets the Boolean value that indicates whether the slider fixes its values to those values represented by its tick marks.
    @discardableResult
    func allowsTickMarkValuesOnly(_ allows: Bool) -> Self {
        self.allowsTickMarkValuesOnly = allows
        return self
    }
        
    /// Sets the number of tick marks associated with the slider.
    @discardableResult
    func numberOfTickMarks(_ numberOfTickMarks: Int) -> Self {
        self.numberOfTickMarks = numberOfTickMarks
        return self
    }
}

#endif
