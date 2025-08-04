//
//  NSStepper+.swift
//  
//
//  Created by Florian Zand on 18.07.24.
//

#if os(macOS)

import AppKit
public extension NSStepper {
    /// Sets the stepper’s minimum value.
    @discardableResult
    func minValue(_ minValue: Double) -> Self {
        self.minValue = minValue
        return self
    }
    
    /// Sets the stepper’s maximum value.
    @discardableResult
    func maxValue(_ maxValue: Double) -> Self {
        self.maxValue = maxValue
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
