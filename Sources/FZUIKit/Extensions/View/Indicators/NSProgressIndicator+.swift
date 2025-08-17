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
    /**
     Creates a spinning progress indicator.

     - Parameters:
        - size: The size of the progress indicator.
        - isDisplayedWhenStopped: A Boolean that indicates whether the progress indicator hides itself when it isn’t animating.
     */
    public static func spinning(size: NSControl.ControlSize = .regular, isDisplayedWhenStopped: Bool = true) -> NSProgressIndicator {
        let progressIndicator = NSProgressIndicator()
        progressIndicator.style = .spinning
        progressIndicator.startAnimation(nil)
        progressIndicator.controlSize = size
        progressIndicator.sizeToFit()
        progressIndicator.isDisplayedWhenStopped = isDisplayedWhenStopped
        return progressIndicator
    }
    
    /**
     Creates a circular progress indicator.
     
     - Parameters:
        - minValue: The minimum value of the progress indicator.
        - maxValue: The maximum value of the progress indicator.
        - value: The current value of the progress indicator.
        - size: The size of the progress indicator.
        - isDisplayedWhenStopped: A Boolean that indicates whether the progress indicator hides itself when it isn’t animating.
     */
    public static func circular(minValue: Double = 0.0, maxValue: Double = 1.0, value: Double = 0.0, size: NSControl.ControlSize = .regular, isDisplayedWhenStopped: Bool = true) -> NSProgressIndicator {
        let progressIndicator = NSProgressIndicator.spinning()
        progressIndicator.isIndeterminate = false
        progressIndicator.minValue = minValue
        progressIndicator.maxValue = maxValue
        progressIndicator.doubleValue = value
        progressIndicator.controlSize = size
        progressIndicator.sizeToFit()
        progressIndicator.isDisplayedWhenStopped = isDisplayedWhenStopped
        return progressIndicator
    }
    
    /**
     Creates a circular progress indicator for the specified progress.
     
     - Parameters:
        -  progress: The progress.
        - size: The size of the progress indicator.
        - isDisplayedWhenStopped: A Boolean that indicates whether the progress indicator hides itself when it isn’t animating.
     */
    @available(macOS 14.0, *)
    public static func circular(progress: Progress, size: NSControl.ControlSize = .regular, isDisplayedWhenStopped: Bool = true) -> NSProgressIndicator {
        let progressIndicator = NSProgressIndicator.circular(size: size, isDisplayedWhenStopped: isDisplayedWhenStopped)
        progressIndicator.observedProgress = progress
        return progressIndicator
    }
    
    /**
     Creates a indeterminate bar progress indicator.
     
     - Parameters:
        - width: The width of the progress indicator.
        - size: The size of the progress indicator.
        - isDisplayedWhenStopped: A Boolean that indicates whether the progress indicator hides itself when it isn’t animating.
     */
    public static func indeterminateBar(width: CGFloat = 200.0, size: NSControl.ControlSize = .regular, isDisplayedWhenStopped: Bool = true) -> NSProgressIndicator {
        let progressIndicator = NSProgressIndicator()
        progressIndicator.controlSize = size
        progressIndicator.sizeToFit()
        progressIndicator.frame.size.width = width
        progressIndicator.isDisplayedWhenStopped = isDisplayedWhenStopped
        return progressIndicator
    }
    
    /**
     Creates a bar progress indicator.
     
     - Parameters:
        - minValue: The minimum value of the progress indicator.
        - maxValue: The maximum value of the progress indicator.
        - value: The current value of the progress indicator.
        - width: The width of the progress indicator.
        - size: The size of the progress indicator.
        - isDisplayedWhenStopped: A Boolean that indicates whether the progress indicator hides itself when it isn’t animating.
     */
    public static func bar(minValue: Double = 0.0, maxValue: Double = 1.0, value: Double = 0.0, width: CGFloat = 200, size: NSControl.ControlSize = .regular, isDisplayedWhenStopped: Bool = true) -> NSProgressIndicator {
        let progressIndicator = NSProgressIndicator()
        progressIndicator.minValue = minValue
        progressIndicator.maxValue = maxValue
        progressIndicator.doubleValue = value
        progressIndicator.isIndeterminate = false
        progressIndicator.controlSize = size
        progressIndicator.sizeToFit()
        progressIndicator.frame.size.width = width
        progressIndicator.isDisplayedWhenStopped = isDisplayedWhenStopped
        return progressIndicator
    }
    
    /**
     Creates a bar progress indicator for the specified progress.
     
     - Parameters:
        -  progress: The progress.
        - width: The width of the progress indicator.
        - size: The size of the progress indicator.
        - isDisplayedWhenStopped: A Boolean that indicates whether the progress indicator hides itself when it isn’t animating.
     */
    @available(macOS 14.0, *)
    public static func bar(progress: Progress, width: CGFloat = 200.0, size: NSControl.ControlSize = .regular, isDisplayedWhenStopped: Bool = true) -> NSProgressIndicator {
        let progressIndicator = NSProgressIndicator.bar(width: width, size: size, isDisplayedWhenStopped: isDisplayedWhenStopped)
        progressIndicator.observedProgress = progress
        return progressIndicator
    }
    
    /// The color of the progress indicator.
    public var color: NSColor {
        get { _color ?? .controlAccentColor }
        set {
            guard newValue != color else { return }
            _color = newValue != .controlAccentColor ? newValue : nil
            contentFilters.removeAll(where: { $0.name == "CIHueAdjust" || $0.name == "CIColorClamp" } )
            if style == .spinning {
                let rgb = newValue.rgbaComponents()
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
    public func color(_ color: NSColor) -> Self {
        self.color = color
        return self
    }
    
    fileprivate var _color: NSColor? {
        get { getAssociatedValue("_color") }
        set { setAssociatedValue(newValue, key: "_color") }
    }
}

#endif
