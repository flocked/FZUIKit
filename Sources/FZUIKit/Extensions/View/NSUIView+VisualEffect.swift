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
    #if os(macOS)
    /**
     The visual effect of the view.
     
     The property adds a [NSVisualEffectView](https://developer.apple.com/documentation/appkit/nsvisualeffectview) as background to the view.
     
     The default value is `nil`.
     */
    @objc open var visualEffect: VisualEffectConfiguration? {
        get { (self as? NSUIVisualEffectView)?.configuration ?? visualEffectBackgroundView?.configuration }
        set {
            if let newValue = newValue {
                if let view = self as? NSUIVisualEffectView {
                    view.configuration = newValue
                } else {
                    if visualEffectBackgroundView == nil {
                        visualEffectBackgroundView = BackgroundVisualEffectView()
                    }
                    visualEffectBackgroundView?.configuration = newValue
                    appearance = newValue.appearance ?? appearance
                }
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
    #else
    /**
     The visual effect of the view.
     
     The property adds a [UIVisualEffectView](https://developer.apple.com/documentation/uikit/uivisualeffectview) as background to the view.
     
     The default value is `nil`.
     */
    @objc open var visualEffect: UIVisualEffect? {
        get { (self as? NSUIVisualEffectView)?.effect ?? visualEffectBackgroundView?.effect }
        set {
            if let newValue = newValue {
                if let view = self as? NSUIVisualEffectView {
                    view.effect = newValue
                } else {
                    if visualEffectBackgroundView == nil {
                        visualEffectBackgroundView = BackgroundVisualEffectView()
                    }
                    visualEffectBackgroundView?.effect = newValue
                }
            } else {
                visualEffectBackgroundView = nil
            }
        }
    }
    
    /// Sets the visual effect of the view.
    @discardableResult
    @objc open func visualEffect(_ visualEffect: UIVisualEffect?) -> Self {
        self.visualEffect = visualEffect
        return self
    }
    #endif
    
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

class BackgroundVisualEffectView: NSUIVisualEffectView {
    var observer: KeyValueObserver<NSUIVisualEffectView>!
        
    init() {
        #if os(macOS)
        super.init(frame: .zero)
        #else
        super.init(effect: nil)
        tag = 3_443_024
        #endif
        zPosition = -.greatestFiniteMagnitude
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
    override func hitTest(_ point: NSPoint) -> NSView? {
        return nil
    }
    
    override var acceptsFirstResponder: Bool { false }
    
    override var tag: Int { 3_443_024 }
    #endif
}
#endif
