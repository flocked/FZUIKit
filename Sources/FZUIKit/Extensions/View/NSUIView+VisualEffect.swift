//
//  NSUIView+VisualEffect.swift
//
//
//  Created by Florian Zand on 03.02.23.
//

#if os(macOS) || os(iOS) || os(tvOS)
#if os(macOS)
import AppKit
#elseif canImport(UIKit)
import UIKit
#endif

extension NSUIView {
    /**
     The visual effect of the view.
     
     The property adds a `VisualEffectView` as background to the view. The default value is `nil`.
     */
    @objc open var visualEffect: VisualEffectConfiguration? {
        get {
            #if os(macOS)
            (self as? NSVisualEffectView)?.configuration ?? visualEffectBackgroundView?.configuration
            #else
            (self as? UIVisualEffectView)?.configuration ?? visualEffectBackgroundView?.configuration
            #endif
        }
        set {
            if let newValue = newValue {
            #if os(macOS)
                if let view = self as? NSVisualEffectView {
                    view.configuration = newValue
                } else {
                    let shadow = outerShadow
                    if visualEffectBackgroundView == nil {
                        visualEffectBackgroundView = TaggedVisualEffectView()
                    }
                    visualEffectBackgroundView?.configuration = newValue
                    if let appearance = newValue.appearance {
                        self.appearance = appearance
                    }
                    visualEffectBackgroundView?.cornerRadius = cornerRadius
                    visualEffectBackgroundView?.roundedCorners = roundedCorners
                    //   visualEffectBackgroundView?.cornerShape = cornerShape
                    outerShadow = shadow
                    
                }
            #else
                if let view = self as? UIVisualEffectView {
                    view.configuration = newValue
                } else {
                    if visualEffectBackgroundView == nil {
                        visualEffectBackgroundView = TaggedVisualEffectView()
                    }
                    visualEffectBackgroundView?.configuration = newValue
                }
            #endif
            } else {
                visualEffectBackgroundView = nil
            }
        }
    }
    
    /// Sets the visual effect of the view.
    @discardableResult
    @objc open func visualEffect(_ visualEffect: VisualEffectConfiguration?) -> Self {
        self.visualEffect = visualEffect
        return self
    }
    
    var visualEffectBackgroundView: TaggedVisualEffectView? {
        get { viewWithTag(TaggedVisualEffectView.Tag) as? TaggedVisualEffectView }
        set {
            if visualEffectBackgroundView != newValue {
                visualEffectBackgroundView?.removeFromSuperview()
            }
            if let newValue = newValue {
                insertSubview(newValue, at: 0)
                newValue.constraint(to: self)
            }
        }
    }
}

#if os(macOS)
class TaggedVisualEffectView: NSVisualEffectView {
    static var Tag: Int { 3_443_024 }
    
    override var tag: Int { Self.Tag }
}
#else
class TaggedVisualEffectView: UIVisualEffectView {
    static var Tag: Int { 3_443_024 }
    
    override var tag: Int {
        get { Self.Tag }
        set { }
    }
}

extension UIVisualEffectView {
    var configuration: VisualEffectConfiguration {
        get { VisualEffectConfiguration(effect: effect) }
        set { effect = newValue.effect }
    }
}
#endif
#endif
