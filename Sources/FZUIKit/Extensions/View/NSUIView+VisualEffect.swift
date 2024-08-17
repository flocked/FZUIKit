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
import FZSwiftUtils

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
                    if visualEffectBackgroundView == nil {
                        visualEffectBackgroundView = BackgroundVisualEffectView()
                    }
                    visualEffectBackgroundView?.configuration = newValue
                    appearance = newValue.appearance ?? appearance
                }
            #else
                if let view = self as? UIVisualEffectView {
                    view.configuration = newValue
                } else {
                    if visualEffectBackgroundView == nil {
                        visualEffectBackgroundView = BackgroundVisualEffectView()
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
    
    var visualEffectBackgroundView: BackgroundVisualEffectView? {
        get { viewWithTag(3_443_024) as? BackgroundVisualEffectView }
        set {
            visualEffectBackgroundView?.removeFromSuperview()
            if let newValue = newValue {
                insertSubview(withConstraint: newValue, at: 0)
            }
        }
    }
}

import FZSwiftUtils
class BackgroundVisualEffectView: NSUIVisualEffectView {
    var observer: KeyValueObserver<NSUIVisualEffectView>!

    init() {
        #if os(macOS)
        super.init(frame: .zero)
        #else
        super.init(effect: nil)
        tag = 3_443_024
        #endif
        optionalLayer?.zPosition = -.greatestFiniteMagnitude
        clipsToBounds = true
        observer = KeyValueObserver(self)
        #if os(macOS)
        observer.add(\.superview?.layer?.cornerCurve) { [weak self] old, new in
            guard let self = self, let new = new else { return }
            self.cornerCurve = new
        }
        observer.add(\.superview?.layer?.cornerRadius) { [weak self] old, new in
            guard let self = self, let new = new else { return }
            self.cornerRadius = new
        }
        #else
        observer.add(\.superview?.layer.cornerCurve) { [weak self] old, new in
            guard let self = self, let new = new else { return }
            self.cornerCurve = new
        }
        observer.add(\.superview?.layer.cornerRadius) { [weak self] old, new in
            guard let self = self, let new = new else { return }
            self.cornerRadius = new
        }
        #endif
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    #if os(macOS)
    static var Tag: Int { 3_443_024 }
    override var tag: Int { Self.Tag }
    #endif
}
#if os(iOS) || os(tvOS)
extension UIVisualEffectView {
    var configuration: VisualEffectConfiguration {
        get { VisualEffectConfiguration(effect: effect) }
        set { effect = newValue.effect }
    }
}
#endif
#endif
