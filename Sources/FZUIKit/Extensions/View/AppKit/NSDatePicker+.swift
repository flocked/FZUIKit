//
//  NSDatePicker+.swift
//
//
//  Created by Florian Zand on 01.07.24.
//

#if os(macOS)
import AppKit

extension NSDatePicker {
    /// Sets the date selected by the date picker.
    @discardableResult
    public func date(_ date: Date) -> Self {
        dateValue = date
        return self
    }
    
    /// Sets the time interval selected by the date picker.
    @discardableResult
    public func timeInterval(_ timeInterval: TimeInterval) -> Self {
        self.timeInterval = timeInterval
        return self
    }
    
    /// Sets the date picker’s minimum date.
    @discardableResult
    public func minDate(_ date: Date?) -> Self {
        minDate = date
        return self
    }
    
    /// Sets the date picker’s maximum date.
    @discardableResult
    public func maxDate(_ date: Date?) -> Self {
        maxDate = date
        return self
    }
    
    /// Sets the date picker’s mode.
    @discardableResult
    public func mode(_ mode: Mode) -> Self {
        datePickerMode = mode
        return self
    }
    
    /// Sets the calendar used by the date picker.
    @discardableResult
    public func calendar(_ calendar: Calendar?) -> Self {
        self.calendar = calendar
        return self
    }
    
    /// Sets the date picker’s locale.
    @discardableResult
    public func locale(_ locale: Locale?) -> Self {
        self.locale = locale
        return self
    }
    
    /// Sets the time zone for the date picker.
    @discardableResult
    public func timeZone(_ timeZone: TimeZone?) -> Self {
        self.timeZone = timeZone
        return self
    }
    
    /// Sets the value that indicates which visual elements of the date picker are currently shown, and which won't be usable because they are hidden.
    @discardableResult
    public func datePickerElements(_ elements: NSDatePicker.ElementFlags) -> Self {
        datePickerElements = elements
        return self
    }
    
    /// Sets the Boolean value that indicates whether the date picker draws its background.
    @discardableResult
    public func drawsBackground(_ draws: Bool) -> Self {
        drawsBackground = draws
        return self
    }
        
    /// Sets the background color of the date picker.
    @discardableResult
    public func backgroundColor(_ color: NSColor?) -> Self {
        backgroundColor = color ?? .clear
        drawsBackground = color != nil
        return self
    }
    
    /// Sets the text color of the date picker.
    @discardableResult
    public func textColor(_ color: NSColor) -> Self {
        textColor = color
        return self
    }
    
    /// Sets the Boolean value that controls whether the date picker draws a solid black border around its contents.
    @discardableResult
    func isBordered(_ isBordered: Bool) -> Self {
        self.isBordered = isBordered
        return self
    }
    
    /// Sets the Boolean value that controls whether the date picker draws a bezeled background around its contents.
    @discardableResult
    func isBezeled(_ isBezeled: Bool) -> Self {
        self.isBezeled = isBezeled
        return self
    }
}
#endif
