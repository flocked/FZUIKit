//
//  InnerShadowLayer.swift
//  FZExtensions
//
//  Created by Florian Zand on 16.09.21.
//


import Foundation
#if os(macOS)
import AppKit
#elseif canImport(UIKit)
import UIKit
#endif
import FZSwiftUtils

public class InnerShadowLayer: CALayer {
    override public var opacity: Float {
        get { return shadowOpacity }
        set { shadowOpacity = newValue }
    }
    
    internal var superlayerObserver: KeyValueObserver<CALayer>? = nil

    override public init() {
        super.init()
    }
    
    public func setupSuperlayerObservation() {
        if let superlayer = superlayer {
            if superlayerObserver?.observedObject != superlayer {
                superlayerObserver = nil
                superlayerObserver = KeyValueObserver(superlayer)
                superlayerObserver?.add(\.cornerRadius) { [weak self] old, new in
                    Swift.print("superlayer cornerRadius changed")
                    guard let self = self, old != new else { return }
                    self.superlayerDidUpdate()
                }
                superlayerObserver?.add(\.bounds) { [weak self] old, new in
                    Swift.print("superlayer bounds changed")
                    guard let self = self, old != new else { return }
                    self.superlayerDidUpdate()
                }
            }
            self.superlayerDidUpdate()
        } else {
            superlayerObserver = nil
        }
    }
    
    internal func superlayerDidUpdate() {
        if let superlayer = superlayer {
            self.isUpdating = true
            self.bounds = superlayer.bounds
            self.cornerRadius = superlayer.cornerRadius
            self.update()
            self.isUpdating = false
        }
    }

    public init(configuration: ContentConfiguration.Shadow) {
        super.init()
        self.configuration = configuration
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }

    public var radius: CGFloat {
        get { shadowRadius }
        set { shadowRadius = newValue
            update()
        }
    }

    public var offset: CGSize {
        get { shadowOffset }
        set { shadowOffset = newValue
            update()
        }
    }

    public var color: NSUIColor? {
        get { if let cgColor = shadowColor {
            return NSUIColor(cgColor: cgColor)
        }
        return nil
        }
        set { shadowColor = newValue?.cgColor }
    }

    public var configuration: ContentConfiguration.Shadow {
        get { ContentConfiguration.Shadow(color: self.color, opacity: CGFloat(self.opacity), radius: self.radius, offset: CGPoint(x: self.offset.width, y: self.offset.height))  }
        set {
            self.color = newValue.color
            self.opacity = Float(newValue.opacity)
            self.offset = CGSize(width: newValue.offset.x, height: newValue.offset.y)
            self.radius = newValue.radius
        }
    }


    internal var isUpdating: Bool = false
    override public var frame: CGRect {
        didSet { if !isUpdating, oldValue != frame {
            update() } }
    }
    
    override public var bounds: CGRect {
        didSet { if !isUpdating, oldValue != bounds {
            update() } }
    }
    
    public override var cornerRadius: CGFloat {
        didSet { if !isUpdating, oldValue != cornerRadius {
            update() } }
    }

    private func update() {
        if superlayer != nil {
            var path = NSUIBezierPath(rect: bounds.insetBy(dx: -20, dy: -20))
            #if os(macOS)
            var innerPart = NSUIBezierPath(rect: bounds).reversed
            #else
            var innerPart = NSUIBezierPath(rect: bounds).reversing()
            #endif
            if cornerRadius != 0.0 {
                path = NSUIBezierPath(roundedRect: bounds.insetBy(dx: -20, dy: -20), cornerRadius: cornerRadius)
                #if os(macOS)
                innerPart = NSUIBezierPath(roundedRect: bounds, cornerRadius: cornerRadius).reversed
                #else
                innerPart = NSUIBezierPath(roundedRect: bounds, cornerRadius: cornerRadius).reversing()
                #endif
            }
            path.append(innerPart)
            shadowPath = path.cgPath
            masksToBounds = true

            backgroundColor = .clear
        }
    }

    override public func draw(in ctx: CGContext) {
        super.draw(in: ctx)
        update()
    }

    override public func display() {
        super.display()
        update()
    }
}

