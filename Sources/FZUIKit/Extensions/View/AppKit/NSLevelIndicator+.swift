//
//  NSLevelIndicator+.swift
//  
//
//  Created by Florian Zand on 18.07.24.
//

#if os(macOS)

import AppKit

public extension NSLevelIndicator {
    /// Sets the indicator’s minimum value.
    @discardableResult
    func minValue(_ minValue: Double) -> Self {
        self.minValue = minValue
        return self
    }
    
    /// Sets the indicator’s maximum value.
    @discardableResult
    func maxValue(_ maxValue: Double) -> Self {
        self.maxValue = maxValue
        return self
    }
    
    /// Sets the indicator’s warning value.
    @discardableResult
    func warningValue(_ value: Double) -> Self {
        self.warningValue = value
        return self
    }
    
    /// Sets the indicator’s critical value.
    @discardableResult
    func criticalValue(_ value: Double) -> Self {
        self.criticalValue = value
        return self
    }
    
    /// Sets the value that determines how the indicator’s tick marks are aligned with it.
    @discardableResult
    func tickMarkPosition(_ position: NSSlider.TickMarkPosition) -> Self {
        self.tickMarkPosition = position
        return self
    }
    
    /// Sets the number of tick marks.
    @discardableResult
    func numberOfTickMarks(_ numberOfTickMarks: Int) -> Self {
        self.numberOfTickMarks = numberOfTickMarks
        return self
    }
    
    /// Sets the number of major tick marks.
    @discardableResult
    func numberOfMajorTickMarks(_ numberOfMajorTickMarks: Int) -> Self {
        self.numberOfMajorTickMarks = numberOfMajorTickMarks
        return self
    }
    
    /// Sets the appearance of the indicator.
    @discardableResult
    func style(_ style: Style) -> Self {
        self.levelIndicatorStyle = style
        return self
    }
    
    /// Sets the fill color of the indicator.
    @discardableResult
    func fillColor(_ color: NSColor) -> Self {
        self.fillColor = color
        return self
    }
    
    /// Sets the warning fill color of the indicator.
    @discardableResult
    func warningFillColor(_ color: NSColor) -> Self {
        self.warningFillColor = color
        return self
    }
    
    /// Sets the critical fill color of the indicator.
    @discardableResult
    func criticalFillColor(_ color: NSColor) -> Self {
        self.criticalFillColor = color
        return self
    }
    
    /// Sets the rating image of the indicator.
    @discardableResult
    func ratingImage(_ image: NSImage?) -> Self {
        self.ratingImage = image
        return self
    }
    
    /// Sets the rating placeholder image of the indicator.
    @discardableResult
    func ratingPlaceholderImage(_ image: NSImage?) -> Self {
        self.ratingPlaceholderImage = image
        return self
    }
    
    /// Sets the placeholder visibility of the indicator.
    @discardableResult
    func placeholderVisibility(_ visibility: PlaceholderVisibility) -> Self {
        self.placeholderVisibility = visibility
        return self
    }
    
    /// Sets the Boolean value indicating whether the indicator is editable.
    @discardableResult
    func isEditable(_ isEditable: Bool) -> Self {
        self.isEditable = isEditable
        return self
    }
    
    /// Sets the Boolean value indicating whether the indicator draws tiered capacity levels.
    @discardableResult
    func drawsTieredCapacityLevels(_ draws: Bool) -> Self {
        self.drawsTieredCapacityLevels = draws
        return self
    }
}
#endif
