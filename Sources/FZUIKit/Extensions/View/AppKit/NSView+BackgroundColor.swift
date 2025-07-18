//
//  NSView+BackgroundColor.swift
//
//
//  Created by Florian Zand on 21.10.22.
//

#if os(macOS)
import AppKit
import FZSwiftUtils

public extension NSViewProtocol where Self: NSView {
    /**
     The background color of the view.
     
     Using this property turns the view into a layer-backed view. The value can be animated via `animator()`.
     */
    var backgroundColor: NSColor? {
        get { backgroundColorAnimatable }
        set {
            NSView.swizzleAnimationForKey()
            realSelf.dynamicColors.background = newValue
            backgroundColorAnimatable = animationColor(newValue, \.backgroundColor)
        }
    }
    
    /**
     Sets the background color of the view.
     
     Using this property turns the view into a layer-backed view.
     */
    @discardableResult
    func backgroundColor(_ color: NSUIColor?) -> Self {
        backgroundColor = color
        return self
    }
}

extension NSView {
    @objc var backgroundColorAnimatable: NSColor? {
        get { layer?.configurations.backgroundColor }
        set { optionalLayer?.configurations.backgroundColor = newValue }
    }
}
#endif
