//
//  NSStepper+.swift
//  
//
//  Created by Florian Zand on 18.07.24.
//

#if os(macOS)

import AppKit
public extension NSStepper {
    /// Sets the minimum value of the stepper.
    @discardableResult
    func minValue(_ minValue: Double) -> Self {
        self.minValue = minValue
        return self
    }
    
    /// Sets the maximum value of the stepper.
    @discardableResult
    func maxValue(_ maxValue: Double) -> Self {
        self.maxValue = maxValue
        return self
    }
    
    /// The range of the stepper.
    var range: ClosedRange<Double> {
        get { minValue...maxValue }
        set {
            minValue = newValue.lowerBound
            maxValue = newValue.upperBound
        }
    }
    
    /// Sets the range of the stepper.
    @discardableResult
    func range(_ range: ClosedRange<Double>) -> Self {
        self.range = range
        return self
    }
    
    /// Sets the amount by which the stepper changes with each increment or decrement.
    @discardableResult
    func increment(_ increment: Double) -> Self {
        self.increment = increment
        return self
    }
    
    /// Sets the Boolean value indicating how the stepper responds to mouse events.
    @discardableResult
    func autorepeat(_ autorepeat: Bool) -> Self {
        self.autorepeat = autorepeat
        return self
    }
    
    /// Sets the Boolean value indicating whether the stepper wraps around the minimum and maximum values.
    @discardableResult
    func valueWraps(_ wraps: Bool) -> Self {
        self.valueWraps = wraps
        return self
    }
}
#endif
