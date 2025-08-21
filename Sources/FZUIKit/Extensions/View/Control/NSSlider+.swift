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
     Creates a linear slider with the specified orientation and size.
         
     - Parameters:
        - orientation: The orientation of the slider.
        - size: The size of the slider.
        - width: The width of the slider.
        - value: The current value of the slider.
        - minValue: The minimum value of the slider.
        - maxValue: The maximum value of the slider.
        - numberOfTickMarks: The number of tick marks of the slider.
        - allowsTickMarkValuesOnly: A Boolean value that indicates whether the slider fixes its values to those values represented by its tick marks.
        - action: The action handler of the slider.
     */
    static func linear(orientation: NSUserInterfaceLayoutOrientation = .horizontal, size: ControlSize = .regular, width: CGFloat = 200, value: Double = 0.0, minValue: Double = 0.0, maxValue: Double = 1.0, numberOfTickMarks: Int = 0, allowsTickMarkValuesOnly: Bool = false, action: ActionBlock? = nil) -> NSSlider {
        let slider = NSSlider(target: nil, action: nil)
        slider.isVertical = orientation == .vertical
        slider.doubleValue = value
        slider.minValue = minValue
        slider.maxValue = maxValue
        slider.controlSize = size
        slider.allowsTickMarkValuesOnly = allowsTickMarkValuesOnly
        slider.numberOfTickMarks = numberOfTickMarks
        slider.sizeToFit()
        if orientation == .horizontal {
            slider.frame.size.width = width
        } else {
            slider.frame.size.height = width
        }
        slider.actionBlock = action
        return slider
    }
        
    /**
     Creates a circular slider with the specified size.
         
     - Parameters:
        - size: The size of the slider.
        - value: The current value of the slider.
        - minValue: The minimum value of the slider.
        - maxValue: The maximum value of the slider.
        - numberOfTickMarks: The number of tick marks of the slider.
        - action: The action handler of the slider.
     */
    static func circular(size: ControlSize = .regular, value: Double = 0.0, minValue: Double = 0.0, maxValue: Double = 1.0, numberOfTickMarks: Int = 0, action: ActionBlock? = nil) -> NSSlider {
        let slider = NSSlider()
        slider.sliderType = .circular
        slider.doubleValue = value
        slider.minValue = minValue
        slider.maxValue = maxValue
        slider.numberOfTickMarks = numberOfTickMarks.clamped(min: 0)
        slider.allowsTickMarkValuesOnly = numberOfTickMarks > 0
        slider.controlSize = size
        slider.sizeToFit()
        slider.actionBlock = action
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
        
    /// Sets the Boolean value indicating whether the slider fixes its values to those values represented by its tick marks.
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
    
    /// Sets the value that determines where the slider’s tick marks are displayed.
    @discardableResult
    func tickMarkPosition(_ position: TickMarkPosition) -> Self {
        self.tickMarkPosition = position
        return self
    }
    
    /// The color of the unfilled portion of the slider.
    var unfilledColor: NSColor? {
        get { extendedCell?.unfilledColor }
        set {
            if newValue != nil {
                convertToExtendedCell()
            }
            extendedCell?.unfilledColor = newValue
        }
    }
    
    /// Sets the color of the unfilled portion of the slider.
    @discardableResult
    func unfilledColor(_ color: NSColor?) -> Self {
        self.unfilledColor = color
        return self
    }
    
    fileprivate var extendedCell: ExtendedSliderCell? {
        cell as? ExtendedSliderCell
    }
    
    fileprivate func convertToExtendedCell() {
        guard extendedCell == nil, let sliderCell = cell as? NSSliderCell else { return }
        do {
            cell = try sliderCell.archiveBasedCopy(as: ExtendedSliderCell.self)
        } catch {
            debugPrint(error)
        }
    }
    
    fileprivate class ExtendedSliderCell: NSSliderCell {
        var unfilledColor: NSColor?
        
        public override func drawBar(inside rect: NSRect, flipped: Bool) {
            guard sliderType == .linear, let unfilledColor = unfilledColor else {
                super.drawBar(inside: rect, flipped: flipped)
                return
            }
            let value = CGFloat((doubleValue - minValue) / (maxValue - minValue))
            let bgPath = NSBezierPath(roundedRect: rect, cornerRadius: isVertical ? rect.width / 2.0 : rect.height / 2.0)
            unfilledColor.setFill()
            bgPath.fill()
            var fillRect = rect
            if isVertical {
                let fillHeight = value * (rect.height - (knobThickness/2.0))
                fillRect.origin.y = rect.maxY - fillHeight
                fillRect.size.height = fillHeight
            } else {
                fillRect.size.width = value * (rect.width - (knobThickness/2.0))
            }
            let activePath = NSBezierPath(roundedRect: fillRect, cornerRadius: isVertical ? rect.width / 2.0 : rect.height / 2.0)
            ((controlView as? NSSlider)?.trackFillColor ?? .controlAccentColor).setFill()
            activePath.fill()
        }
        
        override init() {
            super.init()
        }
        
        required init(coder aDecoder: NSCoder) {
            super.init(coder: aDecoder)
        }
    }
}

#endif
