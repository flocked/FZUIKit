//
//  NSProgressIndicator+.swift
//
//
//  Created by Florian Zand on 17.01.24.
//

#if os(macOS)
import AppKit
import FZSwiftUtils

extension NSProgressIndicator {
    
    /// Creates a spinning progress indicator.
    public static var spinning: Self { spinning() }
    
    /**
     Creates a spinning progress indicator.

     - Parameters:
        - size: The size of the progress indicator.
        - isDisplayedWhenStopped: A Boolean that indicates whether the progress indicator hides itself when it isn’t animating.
     */
    public static func spinning(size: NSControl.ControlSize = .regular, isDisplayedWhenStopped: Bool = true) -> Self {
        let progressIndicator = Self()
        progressIndicator.style = .spinning
        progressIndicator.isAnimating = true
        progressIndicator.controlSize = size
        progressIndicator.sizeToFit()
        progressIndicator.isDisplayedWhenStopped = isDisplayedWhenStopped
        return progressIndicator
    }

    /// Creates a circular progress indicator.
    public static var circular: Self { circular() }
    
    /**
     Creates a circular progress indicator.
     
     - Parameters:
        - minValue: The minimum value of the progress indicator.
        - maxValue: The maximum value of the progress indicator.
        - value: The current value of the progress indicator.
        - size: The size of the progress indicator.
     */
    public static func circular(minValue: Double = 0.0, maxValue: Double = 100.0, value: Double = 0.0, size: NSControl.ControlSize = .regular) -> Self {
        let progressIndicator = Self.spinning()
        progressIndicator.style = .spinning
        progressIndicator.isIndeterminate = false
        progressIndicator.minValue = minValue
        progressIndicator.maxValue = maxValue
        progressIndicator.doubleValue = value
        progressIndicator.controlSize = size
        progressIndicator.sizeToFit()
        return progressIndicator
    }
    
    /**
     Creates a circular progress indicator for the specified progress.
     
     - Parameters:
        -  progress: The progress.
        - size: The size of the progress indicator.
     */
    @available(macOS 14.0, *)
    public static func circular(progress: Progress, size: NSControl.ControlSize = .regular) -> Self {
        circular(size: size).observeredProgress(progress)
    }
    
    /// Creates a indeterminate bar progress indicator.
    public static var indeterminateBar: Self { indeterminateBar() }
    
    /**
     Creates a indeterminate bar progress indicator.
     
     - Parameters:
        - width: The width of the progress indicator.
        - size: The size of the progress indicator.
        - isActive: A Boolean value indicating whether the bar is animating.
        - isDisplayedWhenStopped: A Boolean that indicates whether the progress indicator hides itself when it isn’t animating.
     */
    public static func indeterminateBar(width: CGFloat = 200.0, size: NSControl.ControlSize = .regular, isActive: Bool = true, isDisplayedWhenStopped: Bool = true) -> Self {
        let progressIndicator = Self()
        progressIndicator.controlSize = size
        progressIndicator.sizeToFit()
        progressIndicator.frame.size.width = width
        progressIndicator.isAnimating = isActive
        progressIndicator.isDisplayedWhenStopped = isDisplayedWhenStopped
        return progressIndicator
    }
    
    /// Creates a bar progress indicator.
    public static var bar: Self { bar() }
    
    /**
     Creates a bar progress indicator.
     
     - Parameters:
        - minValue: The minimum value of the progress indicator.
        - maxValue: The maximum value of the progress indicator.
        - value: The current value of the progress indicator.
        - width: The width of the progress indicator.
        - size: The size of the progress indicator.
     */
    public static func bar(minValue: Double = 0.0, maxValue: Double = 100.0, value: Double = 0.0, width: CGFloat = 200, size: NSControl.ControlSize = .regular) -> Self {
        let progressIndicator = Self()
        progressIndicator.minValue = minValue
        progressIndicator.maxValue = maxValue
        progressIndicator.doubleValue = value
        progressIndicator.isIndeterminate = false
        progressIndicator.controlSize = size
        progressIndicator.sizeToFit()
        progressIndicator.frame.size.width = width
        return progressIndicator
    }
    
    /**
     Creates a bar progress indicator for the specified progress.
     
     - Parameters:
        -  progress: The progress.
        - width: The width of the progress indicator.
        - size: The size of the progress indicator.
     */
    @available(macOS 14.0, *)
    public static func bar(progress: Progress, width: CGFloat = 200.0, size: NSControl.ControlSize = .regular) -> Self {
        bar(width: width, size: size).observeredProgress(progress)
    }
    
    /// The color of the progress indicator.
    @objc public var color: NSColor {
        get { _color ?? .controlAccentColor }
        set {
            guard newValue != color else { return }
            _color = newValue != .controlAccentColor ? newValue : nil
            contentFilters.removeAll(where: { $0.name == "CIHueAdjust" || $0.name == "CIColorClamp" } )
            if style == .spinning {
                let rgb = newValue.rgb()
                contentFilters += CIFilter(name: "CIColorClamp", parameters: ["inputMinComponents": CIVector(x: rgb.red, y: rgb.green, z: rgb.blue, w: 0.0), "inputMaxComponents": CIVector(x: rgb.red, y: rgb.green, z: rgb.blue, w: 1.0)])
            } else {
                guard newValue != .controlAccentColor else { return }
                let baseHue = NSColor.controlAccentColor.usingColorSpace(.deviceRGB)?.hueComponent ?? 0
                let targetHue = newValue.usingColorSpace(.deviceRGB)?.hueComponent ?? 0
                let delta = (targetHue - baseHue).truncatingRemainder(dividingBy: 1)
                let shortest = delta > 0.5 ? delta - 1 : (delta < -0.5 ? delta + 1 : delta)
                let angle = Double(shortest * 2 * .pi)
                contentFilters += CIFilter(name: "CIHueAdjust", parameters: [kCIInputAngleKey: angle])
            }
        }
    }
    
    /// Sets the color of the progress indicator.
    @discardableResult
    @objc public func color(_ color: NSColor) -> Self {
        self.color = color
        return self
    }
    
    fileprivate var _color: NSColor? {
        get { getAssociatedValue("_color") }
        set { setAssociatedValue(newValue, key: "_color") }
    }
    
    /// The range of the progress indicator `[minValue...maxValue]`.
    public var range: ClosedRange<Double> {
         get { minValue...maxValue }
         set {
             let fractionCompleted = fractionCompleted
             minValue = newValue.lowerBound
             maxValue = newValue.upperBound
             self.fractionCompleted = fractionCompleted
         }
     }
    
    /// Sets the range of the progress indicator `[minValue...maxValue]`.
    @discardableResult
    public func range(_ range: ClosedRange<Double>) -> Self {
        self.range = range
        return self
    }
    
    /// The fraction completed of the progress indicator.
    public var fractionCompleted: Double {
        get {
            guard minValue != maxValue else { return 0 }
            let value = min(max(doubleValue, minValue), maxValue)
            return (value - minValue) / (maxValue - minValue)
        }
        set {
            guard minValue != maxValue else { return }
            doubleValue = minValue + min(max(newValue, 0), 1) * (maxValue - minValue)
        }
    }
    
    /// Sets the fraction completed of the progress indicator.
    @discardableResult
    public func fractionCompleted(_ fractionCompleted: Double) -> Self {
        self.fractionCompleted = fractionCompleted
        return self
    }
    
    /// A Boolean value indicating whetheer the progress indicator is animating.
    public var isAnimating: Bool {
        get { value(forKey: "_isAnimating") ?? false }
        set {
            guard newValue != isAnimating else { return }
            newValue ? startAnimation(self) : stopAnimation(self)
        }
    }
    
    /// Sets the Boolean value indicating whetheer the progress indicator is animating.
    @discardableResult
    public func isAnimating(_ isAnimating: Bool) -> Self {
        self.isAnimating = isAnimating
        return self
    }
    
    /// Sets the progress object to use for updating the progress indicator.
    @available(macOS 14.0, *)
    @discardableResult
    public func observeredProgress(_ progress: Progress?) -> Self {
        self.observedProgress = progress
        return self
    }
    
    /// Sets the minimum value for the progress indicator.
    @discardableResult
    public func minValue(_ minValue: Double) -> Self {
        self.minValue = minValue
        return self
    }
    
    /// Sets the maximum value for the progress indicator.
    @discardableResult
    public func maxValue(_ maxValue: Double) -> Self {
        self.maxValue = maxValue
        return self
    }
    
    /// Sets the value that indicates the current extent of the progress indicator.
    @discardableResult
    public func value(_ value: Double) -> Self {
        self.doubleValue = value
        return self
    }
    
    /// Sets the size of the progress indicator.
    @discardableResult
    public func size(_ size: NSControl.ControlSize) -> Self {
        self.controlSize = size
        return self
    }
    
    
    /// Sets the width of the progress indicator.
    @discardableResult
    public func width(_ width: CGFloat) -> Self {
        self.frame.size.width = width
        return self
    }
}

#endif
