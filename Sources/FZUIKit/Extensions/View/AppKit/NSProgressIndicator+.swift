//
//  NSProgressIndicator+.swift
//
//
//  Created by Florian Zand on 17.01.24.
//

#if os(macOS)
import AppKit

extension NSProgressIndicator {
    /// Creates a spinning progress indicator.
    public static var spinning: NSProgressIndicator {
        let progressIndicator = NSProgressIndicator()
        progressIndicator.style = .spinning
        progressIndicator.startAnimation(nil)
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
     */
    public static func bar(minValue: Double = 0.0, maxValue: Double = 0.0, value: Double = 0.0, width: CGFloat = 200) -> NSProgressIndicator {
        let progressIndicator = NSProgressIndicator()
        progressIndicator.minValue = minValue
        progressIndicator.maxValue = maxValue
        progressIndicator.doubleValue = value
        progressIndicator.isIndeterminate = false
        progressIndicator.sizeToFit()
        progressIndicator.frame.size.width = width
        return progressIndicator

    }
}

#endif
