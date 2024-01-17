//
//  NSProgressIndicator+.swift
//
//
//  Created by Florian Zand on 17.01.24.
//

#if os(macOS)
import AppKit

extension NSProgressIndicator {
    /**
     Creates a spinning progress indicator.

     - Parameter size: The size of the progress indicator. The default value is `regular`.
     */
    public static func spinning(size: NSControl.ControlSize = .regular) -> NSProgressIndicator {
        let progressIndicator = NSProgressIndicator()
        progressIndicator.style = .spinning
        progressIndicator.startAnimation(nil)
        progressIndicator.controlSize = size
        progressIndicator.sizeToFit()
        return progressIndicator
    }
    
    /**
     Creates a circular progress indicator.
     
     - Parameters:
        - minValue: The minimum value. The default value is `0`.
        - maxValue: The maximum value.  The default value is `100.0`.
        - value: The value.  The default value is `0`.
        - size: The size of the progress indicator. The default value is `regular`.
     */
    public static func circular(minValue: Double = 0.0, maxValue: Double = 0.0, value: Double = 0.0, size: NSControl.ControlSize = .regular) -> NSProgressIndicator {
        let progressIndicator = NSProgressIndicator.spinning()
        progressIndicator.isIndeterminate = false
        progressIndicator.minValue = minValue
        progressIndicator.maxValue = maxValue
        progressIndicator.doubleValue = value
        progressIndicator.controlSize = size
        progressIndicator.sizeToFit()
        return progressIndicator

    }
    
    /**
     Creates a bar progress indicator.
     
     - Parameters:
        - minValue: The minimum value. The default value is `0`.
        - maxValue: The maximum value.  The default value is `100.0`.
        - value: The value.  The default value is `0`.
        - width: The width of the progress indicator. The default value is `200.0`.
        - size: The size of the progress indicator. The default value is `regular`.
     */
    public static func bar(minValue: Double = 0.0, maxValue: Double = 0.0, value: Double = 0.0, width: CGFloat = 200, size: NSControl.ControlSize = .regular) -> NSProgressIndicator {
        let progressIndicator = NSProgressIndicator()
        progressIndicator.minValue = minValue
        progressIndicator.maxValue = maxValue
        progressIndicator.doubleValue = value
        progressIndicator.isIndeterminate = false
        progressIndicator.controlSize = size
        progressIndicator.sizeToFit()
        progressIndicator.frame.size.width = width
        return progressIndicator

    }
}

#endif
